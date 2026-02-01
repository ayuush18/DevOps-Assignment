@echo off
REM Build script for Calculator CI Project (Windows)
REM This script builds the project using Maven

echo ============================================
echo Starting Calculator CI Build Process
echo ============================================

REM Check if Maven is installed
where mvn >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Maven is not installed or not in PATH
    exit /b 1
)

REM Check if Java is installed
where java >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Java is not installed or not in PATH
    exit /b 1
)

echo [INFO] Java version:
java -version

echo [INFO] Maven version:
mvn --version

REM Set build timestamp
for /f "delims=" %%i in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') do set BUILD_TIMESTAMP=%%i
echo [INFO] Build timestamp: %BUILD_TIMESTAMP%

REM Clean previous builds
echo [INFO] Cleaning previous builds...
mvn clean
if %errorlevel% neq 0 (
    echo [ERROR] Clean failed
    exit /b 1
)

REM Compile the source code
echo [INFO] Compiling source code...
mvn compile
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed
    exit /b 1
)

REM Run tests
echo [INFO] Running unit tests...
mvn test
if %errorlevel% neq 0 (
    echo [ERROR] Tests failed
    exit /b 1
)

REM Package the application
echo [INFO] Packaging the application...
mvn package
if %errorlevel% neq 0 (
    echo [ERROR] Packaging failed
    exit /b 1
)

REM Run static analysis (optional)
if "%1"=="--with-analysis" (
    echo [INFO] Running static code analysis...
    mvn spotbugs:check
)

REM Generate site documentation (optional)
if "%1"=="--with-docs" (
    echo [INFO] Generating project documentation...
    mvn site
)

echo [INFO] Build completed successfully!
echo [INFO] JAR file location: target\calculator-ci-1.0.0.jar

echo ============================================
echo Build Summary
echo ============================================
echo Build Status: SUCCESS
echo Build Time: %BUILD_TIMESTAMP%
echo Artifact: target\calculator-ci-1.0.0.jar
echo ============================================