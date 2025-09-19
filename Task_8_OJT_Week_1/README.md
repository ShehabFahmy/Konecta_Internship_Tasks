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

In this repository, Jenkins was used as a Docker container rather than being installed on the host machine. Therefore, Docker volume mapping was used to access `docker`, `docker compose`, `npm`, and `node`, which were already installed on the host machine. Docker port mapping for port `3000` was not needed, since host machine's Docker was used.
```sh
docker network create jenkins-network
docker run -d \
  --name jenkins-for-konecta-task8 \
  --network jenkins-network \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/jenkins_home:/var/jenkins_home \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /usr/libexec/docker/cli-plugins/docker-compose:/usr/libexec/docker/cli-plugins/docker-compose \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -u root \
  jenkins/jenkins:lts
```

#### Build Trigger using GitHub Webhook
##### Jenkins Configuration
1. First, push your [Jenkinsfile](Jenkinsfile) to the repository that will trigger the build.
2. In your pipeline, go to **Configure** > **Build Triggers**, and check **GitHub hook trigger for GITScm polling**.
3. In the pipeline section, choose:
    - Definition: `Pipeline script from SCM`
    - SCM: `Git`
    - Repository URL: `<Repo_URL>`
    - Credentials: The GitHub token used in the pipeline to clone the application.
    - Branch Specifier: `*/main`
    - Script Path: `Jenkinsfile`
4. Save the configuration.

##### Ngrok Configuration
Since Jenkins was used locally, GitHub wouldn't be able to access it. Therefore, a tunneling service such as Ngrok was used to expose `localhost:8080`.
1. Instead of installing the entire tool, an Ngrok container was used and added to the same Docker network as the Jenkins container:
```sh
docker run --rm -it \
--name ngrok-container-for-jenkins \
--network jenkins-network \
-e NGROK_AUTHTOKEN=$(cat ./Secrets/ngrok_authtoken) \
ngrok/ngrok \
http jenkins-for-konecta-task8:8080
```
- ***Note:*** Make sure to run the previous command in the project directory.
2. A new window will open in your terminal after executing the previous command, use the URL in the `forwarding` row to access the Jenkins server:
![Image](Screenshots/ngrok-link.png)

##### GitHub Webhook Configuration
1. Go to the repository **Settings** > **Webhooks** > **Add Webhook**:
    - Payload URL: `https://<your-ngrok-url>/github-webhook/`
    - Content type: `application/json`
    - Leave the rest as default.
2. Add webhook.
3. Refresh the page. You should see that it is working:
![Image](Screenshots/webhook-config.png)

#### Final Output

<p align="center">
  <strong>Pipeline output after getting triggered by a GitHub Push</strong>
  <br>
  <img src="Screenshots/final-local-jenkins.png">
</p>

---

## Cloud Deployment using AWS and Terraform

*To Be Continued*

---
