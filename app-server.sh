#!/bin/bash

set -euo pipefail

dnf install maven -y

ENV_FILE="/opt/deployment.env"
set -a
source $ENV_FILE
set +a
cp deployment.service /etc/systemd/system/deployment.service
mkdir /app
curl -L -o /tmp/todoapp.zip https://java-todoapp.s3.amazonaws.com/todo_app.zip
unzip /tmp/todo_app.zip
cd /app
mvn clean package -DskipTests
mv target/todo_application-0.0.1-SNAPSHOT.jar /app
cd /app
mv todo_application-0.0.1-SNAPSHOT.jar deployment.jar

systemctl daemon-reload
systemctl enable deployment
systemctl start deployment