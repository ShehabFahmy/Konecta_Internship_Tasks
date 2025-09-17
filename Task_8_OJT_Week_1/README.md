# Intern Project: Building a CI/CD Pipeline for the Availability Tracker

## Overview

You will be working on a real application used to track team availability. This app is currently hosted on GCP and has been used internally for monitoring. Your task is to build a CI/CD pipeline to automate the lifecycle of the application from code quality checks to building and running it locally.

This project will simulate real-world DevOps tasks and workflows, giving you experience with common tools like Git, Docker, and Bash scripting.

---

## Project Structure

```
.
├── .gitignore                  # Ignore node_modules, logs, and other unnecessary files
├── ci.sh                       # Bash script to install dependencies, lint, test, build, and deploy
├── docker-compose.yml          # Orchestrates Node.js app and PostgreSQL service
│
├── App/                        # Node.js application
│   ├── Dockerfile              # Efficient Dockerfile for building the app container
│   ├── eslint.config.mjs       # ESLint configuration
│   ├── package.json            # Dependencies, scripts for linting/testing/building
│   ├── public/                 # Public assets
│   │   └── script.js           # Frontend JS, modified to use PostgreSQL client
│   ├── server.js               # Backend server, connects to PostgreSQL
│   └── tests/                  # Unit tests
│       └── server.test.js      # Tests for server functionality
│
└── PostgreSQL/                 # PostgreSQL service
    ├── Dockerfile              # Dockerfile for PostgreSQL with pre-loaded schema
    └── init.sql                # SQL schema initialization
```

### Functionalities

- **ci.sh** – Automates:
  - Installing npm
  - Installing project dependencies
  - Linting code with ESLint
  - Running unit tests and Node.js built-in tests
  - Building Docker images
  - Deploying using Docker Compose
- **Dockerfile** – Efficient Dockerfile:
  - Multi-stage build to reduce image size:
      - * **Build stage**: Installs production dependencies and copies code to minimize layer rebuilds
      - * **Runtime stage**: Slim image only containing necessary runtime files
  - Dependencies installed first to cache layers
  - Only production dependencies installed in runtime image
- **PostgreSQL/Dockerfile** – Builds PostgreSQL image with pre-loaded schema (`init.sql`).
- **PostgreSQL/init.sql** – Creates database schema for PostgreSQL.
- **docker-compose.yml** – Connects app with PostgreSQL instead of using `output/history.json`.
- **App/eslint.config.mjs** – Configures linting rules.
- **App/package.json** – Includes scripts for testing, linting, and running the app; updated for PostgreSQL integration.
- **App/server.js** – Connects to PostgreSQL database and serves app endpoints.
- **App/public/script.js** – Updated to fetch/post data from PostgreSQL instead of JSON file.
- **App/tests/server.test.js** – Unit tests validating server routes and database interactions.

---

## Local Deployment

### Using `ci.sh`

1. Clone the repository

2. Make the script executable and run it:
   ```bash
   chmod +x ci.sh
   ./ci.sh
   ```
The script will:
* Install npm and project dependencies
* Lint the code
* Run tests
* Build Docker images
* Deploy the app using Docker Compose

3. Access the app at:
    ```
    http://localhost:3000
    ```

<p align="center">
  <img src="Screenshots/final-local-script.png">
</p>

---

### Using Jenkins

*To Be Continued*

---

## Cloud Deployment using AWS and Terraform

*To Be Continued*

---
