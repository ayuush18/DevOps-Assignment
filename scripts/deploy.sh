#!/bin/bash

# Deployment script for Calculator CI Project
# This script deploys the application to different environments

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}[DEPLOY]${NC} $1"
}

# Check if environment is provided
if [ -z "$1" ]; then
    print_error "Usage: $0 <environment> [version]"
    print_error "Environments: development, staging, production"
    exit 1
fi

ENVIRONMENT=$1
VERSION=${2:-"latest"}
APP_NAME="calculator-ci"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

print_header "Starting deployment to $ENVIRONMENT environment"
print_status "Application: $APP_NAME"
print_status "Version: $VERSION"
print_status "Timestamp: $TIMESTAMP"

# Environment-specific configurations
case $ENVIRONMENT in
    "development")
        DEPLOY_PATH="/opt/apps/dev/$APP_NAME"
        PORT="8081"
        PROFILE="dev"
        REPLICAS=1
        ;;
    "staging")
        DEPLOY_PATH="/opt/apps/staging/$APP_NAME"
        PORT="8082"
        PROFILE="staging"
        REPLICAS=2
        ;;
    "production")
        DEPLOY_PATH="/opt/apps/prod/$APP_NAME"
        PORT="8080"
        PROFILE="prod"
        REPLICAS=3
        # Additional security checks for production
        print_warning "Production deployment detected - performing additional checks"
        ;;
    *)
        print_error "Unknown environment: $ENVIRONMENT"
        print_error "Valid environments: development, staging, production"
        exit 1
        ;;
esac

print_status "Deploy path: $DEPLOY_PATH"
print_status "Port: $PORT"
print_status "Profile: $PROFILE"
print_status "Replicas: $REPLICAS"

# Create deployment directory if it doesn't exist
print_status "Creating deployment directory..."
sudo mkdir -p $DEPLOY_PATH/{current,releases,shared/logs,shared/config}

# Create release directory with timestamp
RELEASE_DIR="$DEPLOY_PATH/releases/$TIMESTAMP"
print_status "Creating release directory: $RELEASE_DIR"
sudo mkdir -p $RELEASE_DIR

# Copy application files
print_status "Copying application files..."
if [ -f "target/$APP_NAME-1.0.0.jar" ]; then
    sudo cp target/$APP_NAME-1.0.0.jar $RELEASE_DIR/
else
    print_error "JAR file not found. Please build the application first."
    exit 1
fi

# Copy configuration files
print_status "Setting up configuration..."
cat > /tmp/application.properties << EOF
# Application configuration for $ENVIRONMENT
server.port=$PORT
spring.profiles.active=$PROFILE
logging.file.path=$DEPLOY_PATH/shared/logs
logging.level.com.muj.ci=INFO

# Environment specific settings
app.environment=$ENVIRONMENT
app.version=$VERSION
app.build.timestamp=$TIMESTAMP
EOF

sudo cp /tmp/application.properties $RELEASE_DIR/

# Create startup script
print_status "Creating startup script..."
cat > /tmp/start.sh << EOF
#!/bin/bash
export JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseG1GC -Dspring.profiles.active=$PROFILE"
export APP_HOME=$RELEASE_DIR
cd \$APP_HOME
java \$JAVA_OPTS -jar $APP_NAME-1.0.0.jar --spring.config.location=application.properties > ../shared/logs/app.log 2>&1 &
echo \$! > ../shared/app.pid
echo "Application started with PID: \$(cat ../shared/app.pid)"
EOF

sudo cp /tmp/start.sh $RELEASE_DIR/
sudo chmod +x $RELEASE_DIR/start.sh

# Create stop script
print_status "Creating stop script..."
cat > /tmp/stop.sh << EOF
#!/bin/bash
APP_PID_FILE=$DEPLOY_PATH/shared/app.pid
if [ -f \$APP_PID_FILE ]; then
    PID=\$(cat \$APP_PID_FILE)
    if ps -p \$PID > /dev/null; then
        echo "Stopping application with PID: \$PID"
        kill \$PID
        sleep 5
        if ps -p \$PID > /dev/null; then
            echo "Force killing application..."
            kill -9 \$PID
        fi
    fi
    rm -f \$APP_PID_FILE
    echo "Application stopped"
else
    echo "No PID file found"
fi
EOF

sudo cp /tmp/stop.sh $RELEASE_DIR/
sudo chmod +x $RELEASE_DIR/stop.sh

# Health check script
print_status "Creating health check script..."
cat > /tmp/health_check.sh << EOF
#!/bin/bash
MAX_ATTEMPTS=30
ATTEMPT=1
HEALTH_URL="http://localhost:$PORT/actuator/health"

echo "Performing health check..."
while [ \$ATTEMPT -le \$MAX_ATTEMPTS ]; do
    if curl -f \$HEALTH_URL > /dev/null 2>&1; then
        echo "Health check passed (attempt \$ATTEMPT/\$MAX_ATTEMPTS)"
        exit 0
    fi
    echo "Health check failed (attempt \$ATTEMPT/\$MAX_ATTEMPTS), retrying..."
    sleep 2
    ATTEMPT=\$((ATTEMPT + 1))
done

echo "Health check failed after \$MAX_ATTEMPTS attempts"
exit 1
EOF

sudo cp /tmp/health_check.sh $RELEASE_DIR/
sudo chmod +x $RELEASE_DIR/health_check.sh

# Production-specific checks
if [ "$ENVIRONMENT" = "production" ]; then
    print_status "Performing production readiness checks..."
    
    # Check disk space
    DISK_USAGE=$(df $DEPLOY_PATH | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $DISK_USAGE -gt 80 ]; then
        print_error "Insufficient disk space: ${DISK_USAGE}% used"
        exit 1
    fi
    
    # Check memory
    FREE_MEM=$(free -m | awk 'NR==2{printf "%.1f", $7*100/$2 }')
    print_status "Available memory: ${FREE_MEM}%"
    
    print_status "Production checks passed"
fi

# Stop existing application
print_status "Stopping existing application..."
if [ -f "$DEPLOY_PATH/current/stop.sh" ]; then
    sudo $DEPLOY_PATH/current/stop.sh
fi

# Create symlink to current release
print_status "Updating current release symlink..."
sudo rm -f $DEPLOY_PATH/current
sudo ln -sf $RELEASE_DIR $DEPLOY_PATH/current

# Start new application
print_status "Starting new application..."
sudo $DEPLOY_PATH/current/start.sh

# Wait and perform health check
sleep 10
print_status "Performing health check..."
if sudo $DEPLOY_PATH/current/health_check.sh; then
    print_status "Deployment successful!"
else
    print_error "Health check failed - rolling back..."
    # Rollback logic would go here
    exit 1
fi

# Clean up old releases (keep last 5)
print_status "Cleaning up old releases..."
sudo find $DEPLOY_PATH/releases -maxdepth 1 -type d | sort | head -n -5 | sudo xargs rm -rf

# Log deployment
echo "$TIMESTAMP,$ENVIRONMENT,$VERSION,$APP_NAME,SUCCESS" | sudo tee -a $DEPLOY_PATH/shared/deployment.log

print_status "Deployment completed successfully!"
echo "============================================"
echo "Deployment Summary"
echo "============================================"
echo "Environment: $ENVIRONMENT"
echo "Version: $VERSION"
echo "Release: $TIMESTAMP"
echo "Status: SUCCESS"
echo "Application URL: http://localhost:$PORT"
echo "Logs: $DEPLOY_PATH/shared/logs/app.log"
echo "============================================"