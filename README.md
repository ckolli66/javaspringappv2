# Java Spring Boot App Deployment V2

Automated deployment scripts for a Spring Boot Todo Application on AWS EC2 with separated application and database servers.

## What's New in V2

This is version 2 of my Spring Boot deployment with the following improvements:

- **Separated Architecture**: App server and DB server on different EC2 instances
- **Environment Variables**: Using `.env` files instead of hardcoded credentials
- **Two Deployment Scripts**: `app-server.sh` and `mysql.sh` for each tier
- **Better Security**: Database not exposed to the internet

## Repository Structure

```
javaspringappv2/
├── README.md
├── app-server.sh          # Application server setup
├── mysql.sh               # Database server setup
└── deployment.service     # Systemd service file
```

## Prerequisites

- **2 EC2 Instances** (Amazon Linux 2023 or RHEL-based)
  - App Server: t2.small or larger
  - DB Server: t2.small or larger

- **Security Groups**:
  - App Server: Allow SSH (22), HTTP (80/8080/9091)
  - DB Server: Allow SSH (22), MySQL (3306) from App Server only

- **SSH Key Pair** for accessing instances

## Quick Start

### Step 1: Setup Database Server

```bash
# SSH into DB server
ssh -i your-key.pem ec2-user@<DB_SERVER_IP>

# Upload and run mysql script
scp -i your-key.pem mysql.sh ec2-user@<DB_SERVER_IP>:~
chmod +x mysql.sh
sudo ./mysql.sh

# Note the private IP of DB server
hostname -I | awk '{print $1}'
```

### Step 2: Setup Application Server

```bash
# SSH into App server
ssh -i your-key.pem ec2-user@<APP_SERVER_IP>

# Upload scripts
scp -i your-key.pem app-server.sh deployment.service ec2-user@<APP_SERVER_IP>:~

# Edit app-server.sh and update DB_HOST with DB server's private IP
vim app-server.sh
# Set: DB_HOST="<DB_PRIVATE_IP>"

# Run the deployment
chmod +x app-server.sh
sudo ./app-server.sh
```

### Step 3: Verify

```bash
# Check service status
sudo systemctl status deployment.service

# Test the application
curl http://localhost:8080

# Check logs
sudo journalctl -u deployment.service -n 50
```

Access your app at: `http://<APP_SERVER_PUBLIC_IP>:8080`

## What the Scripts Do

**mysql.sh:**
- Installs MariaDB/MySQL
- Creates database and user
- Configures remote access
- Starts the database service

**app-server.sh:**
- Installs Java and Maven
- Clones the Spring Boot application
- Builds the JAR file
- Sets up environment variables
- Configures systemd service
- Starts the application

## Configuration

Edit these ENV variables in the scripts:

**In db-server: under /opt/db_creds.env file**
```bash
APP_SERVER_PRIVATEIP="your_appserver_privateIP"
DB_USER="your_dbuser"
DB_PASS="your_password"
```

**In app-server: under /opt/deployment.env file**
```bash
DB_HOST="jdbc:mysql://<your_dp_private_ip>:3306/todo_app"
DB_USER="whatever_you_keptin_dbconfig"
DB_PASS="your_password"
```

## Troubleshooting

**Connection refused to database:**
```bash
# Check database is running
sudo systemctl status mariadb

# Test connectivity from app server
telnet <DB_PRIVATE_IP> 3306

# Verify security group allows port 3306 from app server
```

**Service won't start:**
```bash
# Check logs
sudo journalctl -u deployment.service -n 100

# Verify JAR exists
ls -la /app/deployment.jar

# Check Java version
java -version
```

## Differences from V1

| Feature | V1 | V2 |
|---------|----|----|
| Architecture | Single server | Two-tier (app + db) |
| Scripts | 1 script | 2 scripts (app-server.sh + mysql.sh) |
| Database | Local | Remote dedicated server |
| Configuration | Hardcoded | Environment variables |
| Security | Basic | Improved with network segmentation |

## Future Improvements

- **Ansible**: Automate infrastructure provisioning and make scripts idempotent
- **Docker**: Containerize the application
- **IaC**: Terraform/CloudFormation for infrastructure automation

## Related Repositories

- **Version 1**: [javaspringapp-deployment-script](https://github.com/ckolli66/javaspringapp-deployment-script)

## License

MIT
