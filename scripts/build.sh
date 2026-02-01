#!/bin/bash

# Build script for Calculator CI Project
# This script builds the project using Maven

set -e  # Exit on any error

echo "============================================"
echo "Starting Calculator CI Build Process"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Maven is installed
if ! command -v mvn &> /dev/null; then
    print_error "Maven is not installed or not in PATH"
    exit 1
fi

# Check if Java is installed
if ! command -v java &> /dev/null; then
    print_error "Java is not installed or not in PATH"
    exit 1
fi

print_status "Java version:"
java -version

print_status "Maven version:"
mvn --version

# Set build timestamp
BUILD_TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
export BUILD_TIMESTAMP

print_status "Build timestamp: $BUILD_TIMESTAMP"

# Clean previous builds
print_status "Cleaning previous builds..."
mvn clean

# Compile the source code
print_status "Compiling source code..."
mvn compile

# Run tests
print_status "Running unit tests..."
mvn test

# Package the application
print_status "Packaging the application..."
mvn package

# Run static analysis (optional)
if [[ "$1" == "--with-analysis" ]]; then
    print_status "Running static code analysis..."
    mvn spotbugs:check
fi

# Generate site documentation (optional)
if [[ "$1" == "--with-docs" ]]; then
    print_status "Generating project documentation..."
    mvn site
fi

print_status "Build completed successfully!"
print_status "JAR file location: target/calculator-ci-1.0.0.jar"

echo "============================================"
echo "Build Summary"
echo "============================================"
echo "Build Status: SUCCESS"
echo "Build Time: $BUILD_TIMESTAMP"
echo "Artifact: target/calculator-ci-1.0.0.jar"
echo "============================================"