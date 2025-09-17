#!/bin/bash

cd App/

echo
echo "|===============================================|"
echo "|[!] Stage (1) Installing npm...                |"
echo "|===============================================|"
sudo apt install npm -y

echo
echo "|===============================================|"
echo "|[!] Stage (2) Installing Dependencies...   |"
echo "|===============================================|"
npm install

echo
echo "|===============================================|"
echo "|[!] Stage (3) Linting...                       |"
echo "|===============================================|"
# Using the eslint.config.mjs file, you can create a new custom one by running `npx eslint --init` and answering some questions
npm run lint

echo
echo "|===============================================|"
echo "|[!] Stage (4) Testing...                       |"
echo "|===============================================|"
npm test

echo
echo "|===============================================|"
echo "|[!] Stage (5) Building Docker Images...        |"
echo "|===============================================|"
docker build -t shehabfahmy/konecta-task8-backend:latest .
cd ../PostgreSQL
docker build -t shehabfahmy/konecta-task8-db:latest .

echo
echo "|===============================================|"
echo "|[!] Stage (6) Deploying using Docker Compose...|"
echo "|===============================================|"
cd ..
docker compose up
