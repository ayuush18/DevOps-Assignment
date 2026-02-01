pipeline {
    agent any
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        skipStagesAfterUnstable()
        parallelsAlwaysFailFast()
    }
    
    environment {
        MAVEN_OPTS = '-Xmx1024m -XX:MaxPermSize=512m'
        JAVA_HOME = tool name: 'JDK-11', type: 'jdk'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }
    
    tools {
        maven 'Maven-3.8.6'
        jdk 'JDK-11'
    }
    
    stages {
        stage('Checkout') {
            steps {
                script {
                    echo "Checking out code from ${env.BRANCH_NAME} branch"
                    // Git checkout is automatic in multibranch pipeline
                    sh 'git --version'
                    sh 'java -version'
                    sh 'mvn --version'
                }
            }
        }
        
        stage('Build Strategy Decision') {
            steps {
                script {
                    echo "Current branch: ${env.BRANCH_NAME}"
                    
                    if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                        env.BUILD_STRATEGY = 'production'
                        env.DEPLOY_ENV = 'production'
                        echo "Production build strategy selected"
                    } else if (env.BRANCH_NAME.startsWith('release/')) {
                        env.BUILD_STRATEGY = 'release'
                        env.DEPLOY_ENV = 'staging'
                        echo "Release build strategy selected"
                    } else if (env.BRANCH_NAME.startsWith('feature/') || env.BRANCH_NAME.startsWith('bugfix/')) {
                        env.BUILD_STRATEGY = 'feature'
                        env.DEPLOY_ENV = 'development'
                        echo "Feature build strategy selected"
                    } else {
                        env.BUILD_STRATEGY = 'default'
                        env.DEPLOY_ENV = 'development'
                        echo "Default build strategy selected"
                    }
                }
            }
        }
        
        stage('Compile') {
            steps {
                echo 'Compiling the source code...'
                sh 'mvn clean compile'
            }
            post {
                success {
                    echo 'Compilation successful!'
                }
                failure {
                    echo 'Compilation failed!'
                }
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                sh 'mvn test'
            }
            post {
                always {
                    // Publish test results
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    
                    // Publish JaCoCo coverage reports
                    publishCoverage adapters: [jacocoAdapter('target/site/jacoco/jacoco.xml')], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
                }
                success {
                    echo 'All tests passed!'
                }
                failure {
                    echo 'Some tests failed!'
                }
            }
        }
        
        stage('Static Analysis') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                }
            }
            steps {
                echo 'Running static code analysis...'
                sh 'mvn spotbugs:check'
            }
            post {
                always {
                    // Archive SpotBugs results
                    recordIssues enabledForFailure: true, tools: [spotBugs()]
                }
            }
        }
        
        stage('Package') {
            steps {
                echo 'Packaging the application...'
                sh 'mvn package -DskipTests'
            }
            post {
                success {
                    echo 'Packaging successful!'
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                }
            }
        }
        
        stage('Docker Build') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                }
            }
            steps {
                script {
                    echo 'Building Docker image...'
                    def imageName = "calculator-ci:${env.BRANCH_NAME}-${env.BUILD_NUMBER}"
                    sh "docker build -t ${imageName} -f docker/Dockerfile ."
                    env.DOCKER_IMAGE = imageName
                }
            }
        }
        
        stage('Integration Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                }
            }
            parallel {
                stage('Smoke Tests') {
                    steps {
                        echo 'Running smoke tests...'
                        sh 'java -jar target/*.jar'
                    }
                }
                stage('Performance Tests') {
                    steps {
                        echo 'Running performance tests...'
                        // Placeholder for actual performance tests
                        sh 'echo "Performance tests would run here"'
                    }
                }
            }
        }
        
        stage('Deploy to Environment') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                    branch 'release/*'
                }
            }
            steps {
                script {
                    echo "Deploying to ${env.DEPLOY_ENV} environment..."
                    
                    if (env.BUILD_STRATEGY == 'production') {
                        echo 'Deploying to production...'
                        // Production deployment logic
                        sh './scripts/deploy.sh production'
                    } else if (env.BUILD_STRATEGY == 'release') {
                        echo 'Deploying to staging...'
                        // Staging deployment logic  
                        sh './scripts/deploy.sh staging'
                    }
                }
            }
        }
        
        stage('Post-Deploy Tests') {
            when {
                anyOf {
                    branch 'main'
                    branch 'master'
                }
            }
            steps {
                echo 'Running post-deployment tests...'
                // Placeholder for post-deployment tests
                sh 'echo "Post-deployment tests would run here"'
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline execution completed!'
            
            // Clean up workspace
            cleanWs()
        }
        success {
            echo 'Pipeline succeeded!'
            
            script {
                if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
                    // Send success notification for main branch
                    emailext (
                        subject: "✅ Jenkins Build Success: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                        body: """
                            <p>Build Status: <strong>SUCCESS</strong></p>
                            <p>Job: ${env.JOB_NAME}</p>
                            <p>Build Number: ${env.BUILD_NUMBER}</p>
                            <p>Branch: ${env.BRANCH_NAME}</p>
                            <p>Build URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                        """,
                        to: 'team@company.com',
                        mimeType: 'text/html'
                    )
                }
            }
        }
        failure {
            echo 'Pipeline failed!'
            
            // Send failure notification
            emailext (
                subject: "❌ Jenkins Build Failed: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    <p>Build Status: <strong>FAILED</strong></p>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build Number: ${env.BUILD_NUMBER}</p>
                    <p>Branch: ${env.BRANCH_NAME}</p>
                    <p>Build URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                    <p>Console Output: <a href='${env.BUILD_URL}/console'>${env.BUILD_URL}/console</a></p>
                """,
                to: 'team@company.com',
                mimeType: 'text/html'
            )
        }
        unstable {
            echo 'Pipeline is unstable!'
            
            // Send unstable notification
            emailext (
                subject: "⚠️ Jenkins Build Unstable: ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                body: """
                    <p>Build Status: <strong>UNSTABLE</strong></p>
                    <p>Job: ${env.JOB_NAME}</p>
                    <p>Build Number: ${env.BUILD_NUMBER}</p>
                    <p>Branch: ${env.BRANCH_NAME}</p>
                    <p>Build URL: <a href='${env.BUILD_URL}'>${env.BUILD_URL}</a></p>
                """,
                to: 'team@company.com',
                mimeType: 'text/html'
            )
        }
        changed {
            echo 'Pipeline state changed!'
        }
    }
}