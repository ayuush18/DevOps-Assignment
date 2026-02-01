# CI/CD Lab Project: Jenkins Pipeline Implementation

## Project Overview
This project demonstrates a complete Continuous Integration (CI) workflow using Jenkins. It includes a Java-based Calculator application with automated testing, managed by both Freestyle projects and Multibranch Pipelines.

### Objectives
* Implement CI/CD principles using Jenkins.
* Automate building, testing, and artifact archiving.
* Demonstrate Multibranch Pipeline strategies for different branches (Main vs. Feature).

## Repository Structure
```text
CILabProject/
├── src/
│   ├── main/
│   │   ├── java/com/muj/ci/Calculator.java         # Source Code
│   │   └── resources/                             # (empty or config files)
│   └── test/
│       └── java/com/muj/ci/CalculatorTest.java    # Unit Tests
├── pom.xml                                        # Maven Configuration
├── Jenkinsfile                                    # Pipeline Logic
├── docker/
│   └── Dockerfile                                 # Docker build file
├── scripts/
│   ├── build.sh                                   # Build script (Linux/macOS)
│   ├── build.bat                                  # Build script (Windows)
│   └── deploy.sh                                  # Deployment script
├── target/                                        # Build output (generated)
│   └── ...
└── README.md                                      # Project Overview (this file)
```
