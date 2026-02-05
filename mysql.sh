#!/bin/bash

set -euo pipefail

dnf install mysql-server -y

systemctl enable mysqld
systemctl start mysqld

ENV_FILE="/opt/db_creds.env"
set -a
source $ENV_FILE
set +a

mysql -e "CREATE DATABASE IF NOT EXISTS todo_app"
mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'$DB_HOST' IDENTIFIED BY '$DB_PASS'";
mysql -e "GRANT ALL PRIVILEGES ON todo_app.* TO '$DB_USER'@'$DB_HOST' AND FLUSH PRIVILEGES;"

systemctl restart mysqld