# FastAPI Multi-Tier Application Deployment using Terraform

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Infrastructure Components](#infrastructure-components)
- [Deployment Scripts Analysis](#deployment-scripts-analysis)
- [Step-by-Step Deployment Guide](#step-by-step-deployment-guide)
- [Security Configuration](#security-configuration)
- [Service Management](#service-management)
- [Monitoring and Troubleshooting](#monitoring-and-troubleshooting)
- [Advanced Configuration](#advanced-configuration)
- [Clean Up](#clean-up)

## 🎯 Overview

This project implements a **complete multi-tier application architecture** on AWS using Terraform as Infrastructure as Code (IaC). The solution deploys a production-ready FastAPI application with separate MongoDB database and Redis cache servers, each running on dedicated EC2 instances with proper security configurations.

### Key Features
- **Multi-Tier Architecture**: Separate instances for Application, Database, and Cache layers
- **Infrastructure as Code**: Complete Terraform-based AWS infrastructure provisioning
- **Automated Deployment**: Comprehensive bash scripts for each service installation
- **Production-Ready Setup**: FastAPI with Nginx reverse proxy, secured MongoDB, and Redis cache
- **Elastic IP Integration**: Static IP addresses for reliable connectivity
- **Interactive Deployment**: Menu-driven deployment script for selective component deployment
- **Security-First Approach**: Restrictive security groups with IP-specific access

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              AWS Cloud Infrastructure                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────┐    ┌─────────────────────┐    ┌─────────────────┐  │
│  │   FastAPI Server    │    │   MongoDB Server    │    │   Redis Server  │  │
│  │   (t3.medium)       │    │   (t3.micro)        │    │   (t3.micro)    │  │
│  │                     │    │                     │    │                 │  │
│  │ ┌─────────────────┐ │    │ ┌─────────────────┐ │    │ ┌─────────────┐ │  │
│  │ │     Nginx       │ │    │ │    MongoDB      │ │    │ │ Redis Stack │ │  │
│  │ │   (Port 80)     │ │    │ │   (Port 27017)  │ │    │ │ (Port 6379) │ │  │
│  │ └─────────┬───────┘ │    │ │   - Auth Enabled│ │    │ └─────────────┘ │  │
│  │           │         │    │ │   - Admin User  │ │    │                 │  │
│  │ ┌─────────▼───────┐ │    │ └─────────────────┘ │    │ ┌─────────────┐ │  │
│  │ │    FastAPI      │ │    │                     │    │ │RedisInsight │ │  │
│  │ │   (Port 8000)   │ │◄───┤                     │    │ │(Port 5540)  │ │  │
│  │ │   - Todo App    │ │    │                     │    │ └─────────────┘ │  │
│  │ └─────────────────┘ │    │                     │    │                 │  │
│  └─────────────────────┘    └─────────────────────┘    └─────────────────┘  │
│           │                           │                          │          │
│  ┌────────▼────────┐        ┌─────────▼────────┐       ┌─────────▼────────┐ │
│  │Security Group:  │        │Security Group:   │       │Security Group:   │ │
│  │- SSH (22) My IP │        │- SSH (22) My IP  │       │- SSH (22) My IP  │ │
│  │- HTTP (80) All  │        │- MongoDB (27017) │       │- Redis (6379)    │ │
│  │                 │        │  All              │       │  All             │ │
│  └─────────────────┘        └──────────────────┘       │- Insight (5540)  │ │
│                                                         │  All             │ │
│                                                         └──────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────┘
```

## 📋 Prerequisites

### Required Software
1. **Terraform** (v1.0+)
   ```bash
   # Download from https://www.terraform.io/downloads.html
   # Verify installation
   terraform --version
   ```

2. **AWS CLI** (v2.0+)
   ```bash
   # Configure with your credentials
   aws configure
   # Test connection
   aws sts get-caller-identity
   ```

3. **SSH Client**
   ```bash
   # Ensure you can use SSH
   ssh -V
   ```

### AWS Requirements
- **Active AWS Account** with billing enabled
- **IAM User** with programmatic access
- **Required Permissions**:
  - EC2 (Full Access)
  - VPC (Security Groups)
  - Elastic IP
  - Key Pairs

### Local Environment Setup
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/HATAKEkakshi/Fastapi-Application-Deployement-using-Terraform.git
   cd Fastapi-Application-Deployement-using-Terraform
   ```

2. **Update File Paths**: Edit Terraform files to match your local paths
3. **Generate SSH Keys**: Ensure you have the required `.pem` files

## 📁 Project Structure

```
Fastapi-Application-Deployement-using-Terraform/
├── Cache_Server/                     # Redis deployment module
│   ├── Configuration/
│   │   ├── redis-docker-services.service    # Systemd service for Redis
│   │   └── redis-docker-cleanup.service     # Cleanup service
│   ├── Infrastructure/
│   │   └── fastapi/
│   │       ├── instance.tf          # Redis EC2 configuration
│   │       └── securitygroup.tf     # Redis security group
│   └── Installation/
│       └── cache.sh                 # Redis installation script
├── Database_Server/                  # MongoDB deployment module
│   ├── Configuration/
│   │   └── mongod.conf             # MongoDB configuration
│   └── Infrastructure/
│       ├── instance.tf             # MongoDB EC2 configuration
│       ├── securitygroup.tf        # MongoDB security group
│       ├── database.sh             # MongoDB installation script
│       └── fast.pem                # MongoDB SSH key
├── Fastapi_Application/              # FastAPI deployment module
│   ├── Configuration/
│   │   ├── fastapi_nginx           # Nginx configuration
│   │   ├── fastapi.service         # FastAPI systemd service
│   │   ├── pyenv-local.service     # Python environment service
│   │   └── web.sh                  # FastAPI deployment script
│   └── Infra/
│       ├── instance.tf             # FastAPI EC2 configuration
│       ├── securitygroup.tf        # FastAPI security group
│       └── fastapi-key.pem         # FastAPI SSH key
├── deploy.sh                        # Main deployment orchestrator
└── README.md
```

## 🏢 Infrastructure Components

### 1. Redis Cache Server (`Cache_Server/`)

**EC2 Configuration:**
```hcl
resource "aws_instance" "Fastapi" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.micro"
  key_name               = "Fastapi-key"
  availability_zone      = var.zone
  vpc_security_group_ids = [aws_security_group.Fastapi.id]
  count                  = 1
}
```

**Key Features:**
- **Docker-based Redis Stack**: Latest Redis with full feature set
- **RedisInsight**: Web-based Redis management interface (Port 5540)
- **Systemd Services**: Automatic startup and cleanup services
- **Docker Management**: Automated container lifecycle management

**Security Group Rules:**
- SSH (22): Restricted to specific IP (`182.69.180.93/32`)
- Redis (6379): Open to all instances
- RedisInsight (5540): Web interface access

### 2. MongoDB Database Server (`Database_Server/`)

**EC2 Configuration:**
```hcl
resource "aws_instance" "Fastapi-Dev-Database" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.micro"
  key_name               = "Fastapi-Dev-Database-key"
  availability_zone      = var.zone
  vpc_security_group_ids = [aws_security_group.Fastapi-Dev-Database.id]
  count                  = 1
}
```

**Key Features:**
- **MongoDB 8.0**: Latest MongoDB Community Edition
- **Authentication Enabled**: Secure admin user configuration
- **Custom Configuration**: Optimized `mongod.conf`
- **Automated Setup**: User creation and security configuration

**Security Configuration:**
- **Admin User**: `admin` with `root` privileges
- **Authentication**: Enabled by default
- **Network Access**: Port 27017 open to application servers

### 3. FastAPI Application Server (`Fastapi_Application/`)

**EC2 Configuration:**
```hcl
resource "aws_instance" "fastapi" {
  ami                    = var.amiID[var.region]
  instance_type          = "t3.medium"    # Larger instance for application
  key_name               = "FastApi-key"
  vpc_security_group_ids = [aws_security_group.fastapi-sg.id]
  availability_zone      = var.zone
  count                  = 1
}
```

**Key Features:**
- **Nginx Reverse Proxy**: Professional web server setup
- **Python 3.10**: Modern Python runtime with pyenv
- **FastAPI Application**: Todo application from GitHub
- **Systemd Services**: Production-grade service management
- **Elastic IP**: Static IP address for reliable access

## 📜 Deployment Scripts Analysis

### 1. Redis Installation (`cache.sh`)

```bash
#!/bin/bash
set -e

# System Updates and Docker Installation
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg-agent

# Docker Repository Setup
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Docker Installation and Service Setup
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker && sudo systemctl enable docker

# Redis Stack Deployment
sudo docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest
sudo docker run -d --name redisinsight -p 5540:5540 redis/redisinsight:latest

# Systemd Services Configuration
sudo cp /tmp/redis-docker-services.service /etc/systemd/system/
sudo cp /tmp/redis-docker-cleanup.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable redis-docker-services redis-docker-cleanup
```

### 2. MongoDB Installation (`database.sh`)

```bash
#!/bin/bash
set -e

# MongoDB 8.0 Repository Setup
sudo apt-get update -y
sudo apt-get install -y gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

# Repository Configuration
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

# MongoDB Installation
sudo apt-get update -y
sudo apt-get install -y mongodb-org

# Initial Setup (without authentication)
sudo systemctl start mongod

# Admin User Creation
mongosh <<EOF
use admin
db.createUser({
  user: "admin",
  pwd: "password",
  roles: [ { role: "root", db: "admin" } ]
});
EOF

# Security Configuration
sudo cp /tmp/mongod.conf /etc/mongod.conf
sudo systemctl restart mongod
sudo systemctl enable mongod
```

### 3. FastAPI Deployment (`web.sh`)

```bash
#!/bin/bash
# FastAPI Application Deployment

# Nginx Installation and Configuration
sudo apt update && apt upgrade -y
sudo apt install nginx -y

# Repository Cloning and Configuration
git clone https://github.com/HATAKEkakshi/Fastapi-Application-Deployement-using-Terraform.git
cd Fastapi-Application-Deployement-using-Terraform/Configuration
sudo cp fastapi_nginx /etc/nginx/sites-enabled/
sudo systemctl restart nginx

# Python Environment Setup
cp pyenv-local.service /etc/systemd/system/
systemctl daemon-reload && systemctl start pyenv-local.service && systemctl enable pyenv-local.service

# Application Deployment
cd /root/
git clone https://github.com/HATAKEkakshi/Todo.git
cd Todo
systemctl restart pyenv-local
/root/.pyenv/shims/python3.10 -m pip install -r requirements.txt

# FastAPI Service Configuration
sudo cp /root/Fastapi-Application-Deployement-using-Terraform/Configuration/fastapi.service /etc/systemd/system/
sudo systemctl start fastapi && sudo systemctl enable fastapi
```

## 🚀 Step-by-Step Deployment Guide

### Method 1: Interactive Deployment (Recommended)

The project includes an interactive deployment script that guides you through the process:

```bash
# Make the deployment script executable
chmod +x deploy.sh

# Run the interactive deployment
./deploy.sh
```

**Deployment Options:**
1. **Deploy MongoDB** - Sets up the database server first
2. **Deploy Redis** - Sets up the cache server
3. **Deploy FastAPI application** - Sets up the web application
4. **Destroy all resources** - Clean up all AWS resources

### Method 2: Manual Component Deployment

#### Step 1: Deploy MongoDB Database
```bash
cd Database_Server/Infrastructure
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Check deployment results
cat ips.txt
```

#### Step 2: Deploy Redis Cache
```bash
cd ../../Cache_Server/Infrastructure/fastapi
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Check deployment results
cat ips.txt
```

#### Step 3: Deploy FastAPI Application
```bash
cd ../../../Fastapi_Application/Infra
terraform init
terraform validate
terraform plan
terraform apply -auto-approve

# Check deployment results
cat ips.txt
```

### Step 4: Update Application Configuration

After deployment, you need to update the application configuration with the actual IP addresses:

1. **Update MongoDB Connection**:
   - Use the MongoDB private IP from `ips.txt`
   - Update your FastAPI application's database connection string

2. **Update Redis Connection**:
   - Use the Redis private IP from `ips.txt`
   - Update your FastAPI application's Redis connection

3. **Update Nginx Configuration**:
   - SSH into the FastAPI server
   - Edit `/etc/nginx/sites-enabled/fastapi_nginx`
   - Replace `proxy_pass http://127.0.0.1:8000` with the actual server IP

## 🔒 Security Configuration

### Network Security

#### FastAPI Security Group
```hcl
# SSH access restricted to specific IP
resource "aws_vpc_security_group_ingress_rule" "fastapi_ipv4" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv4         = "122.161.49.206/32"  # Update with your IP
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

# HTTP access from anywhere
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.fastapi-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}
```

#### MongoDB Security Group
```hcl
# MongoDB port access
resource "aws_vpc_security_group_ingress_rule" "Nginx_ipv4" {
  security_group_id = aws_security_group.Fastapi-Dev-Database.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 27017
  to_port           = 27017
  ip_protocol       = "tcp"
}
```

#### Redis Security Group
```hcl
# Redis port access
resource "aws_vpc_security_group_ingress_rule" "Redis_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
}

# RedisInsight web interface
resource "aws_vpc_security_group_ingress_rule" "Insight_ipv4" {
  security_group_id = aws_security_group.Fastapi.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5540
  to_port           = 5540
  ip_protocol       = "tcp"
}
```

### Application Security

1. **MongoDB Authentication**:
   - Admin user: `admin`
   - Password: `password` (change in production)
   - Role: `root` with full database access

2. **SSH Key Management**:
   - Each service uses dedicated SSH keys
   - Keys stored securely in respective directories

3. **Service Isolation**:
   - Each service runs in its own EC2 instance
   - Dedicated security groups for each tier

## 🔧 Service Management

### SystemD Services

#### FastAPI Service (`fastapi.service`)
```ini
[Unit]
Description=FastAPI Todo Application
After=network.target

[Service]
Type=exec
User=root
WorkingDirectory=/root/Todo
ExecStart=/root/.pyenv/shims/python3.10 -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

#### Redis Docker Services (`redis-docker-services.service`)
```ini
[Unit]
Description=Redis Docker Services
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/bash -c 'docker start redis-stack-server redisinsight'
ExecStop=/bin/bash -c 'docker stop redis-stack-server redisinsight'

[Install]
WantedBy=multi-user.target
```

### Service Management Commands

```bash
# FastAPI Application
sudo systemctl status fastapi
sudo systemctl restart fastapi
sudo systemctl logs fastapi -f

# MongoDB
sudo systemctl status mongod
sudo systemctl restart mongod
sudo journalctl -u mongod -f

# Redis
sudo systemctl status redis-docker-services
sudo docker logs redis-stack-server
sudo docker logs redisinsight

# Nginx
sudo systemctl status nginx
sudo nginx -t  # Test configuration
sudo tail -f /var/log/nginx/access.log
```

## 📊 Monitoring and Troubleshooting

### Health Checks

#### FastAPI Application
```bash
# Direct application access
curl http://<fastapi-public-ip>:8000/docs

# Through Nginx
curl http://<fastapi-public-ip>/docs

# Health endpoint (if implemented)
curl http://<fastapi-public-ip>/health
```

#### MongoDB
```bash
# Connect to MongoDB
mongosh --host <mongodb-private-ip> --port 27017 -u admin -p password

# Check database status
mongosh --eval "db.adminCommand('serverStatus')"

# List databases
mongosh --eval "show dbs"
```

#### Redis
```bash
# Redis CLI access
redis-cli -h <redis-private-ip> -p 6379

# RedisInsight web interface
http://<redis-public-ip>:5540

# Check Redis info
redis-cli -h <redis-private-ip> info
```

### Common Issues and Solutions

#### 1. Service Start Failures
```bash
# Check service status
sudo systemctl status <service-name>

# View detailed logs
sudo journalctl -u <service-name> -n 50

# Restart service
sudo systemctl restart <service-name>
```

#### 2. Connection Issues
```bash
# Test network connectivity
telnet <target-ip> <port>

# Check security group rules
aws ec2 describe-security-groups --group-ids <security-group-id>

# Verify service is listening
sudo netstat -tulpn | grep <port>
```

#### 3. File Permission Issues
```bash
# Check file permissions
ls -la /path/to/file

# Fix permissions
sudo chmod +x /path/to/script
sudo chown user:group /path/to/file
```

## 🎛️ Advanced Configuration

### Production Optimizations

#### 1. MongoDB Production Settings
```yaml
# mongod.conf
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 0.0.0.0

security:
  authorization: enabled

processManagement:
  fork: true
  pidFilePath: /var/run/mongodb/mongod.pid
```

#### 2. Redis Production Configuration
```bash
# Redis production deployment with persistence
sudo docker run -d \
  --name redis-stack-server \
  -p 6379:6379 \
  -v /opt/redis-data:/data \
  redis/redis-stack-server:latest \
  redis-server --appendonly yes --requirepass yourpassword
```

#### 3. Nginx Performance Tuning
```nginx
# fastapi_nginx
upstream fastapi_backend {
    server 127.0.0.1:8000;
    keepalive 64;
}

server {
    listen 80;
    server_name your-domain.com;
    
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://fastapi_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
```

### Scaling Considerations

#### 1. Auto Scaling Groups
```hcl
resource "aws_autoscaling_group" "fastapi_asg" {
  name                = "fastapi-asg"
  vpc_zone_identifier = [aws_subnet.main.id]
  target_group_arns   = [aws_lb_target_group.fastapi.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 6
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.fastapi.id
    version = "$Latest"
  }
}
```

#### 2. Load Balancer Integration
```hcl
resource "aws_lb" "fastapi_alb" {
  name               = "fastapi-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}
```

#### 3. Database Clustering
```hcl
# MongoDB Atlas or DocumentDB
resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "my-docdb-cluster"
  engine                  = "docdb"
  master_username         = "username"
  master_password         = "mustbeeightcharacters"
  backup_retention_period = 7
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
}
```

## 🧹 Clean Up

### Individual Service Cleanup
```bash
# Clean up FastAPI resources
cd Fastapi_Application/Infra
terraform destroy -auto-approve

# Clean up Redis resources
cd ../../Cache_Server/Infrastructure/fastapi
terraform destroy -auto-approve

# Clean up MongoDB resources
cd ../../../Database_Server/Infrastructure
terraform destroy -auto-approve
```

### Automated Cleanup
```bash
# Use the deployment script
./deploy.sh
# Select option 4: "Destroy all resources"
# Confirm with "yes"
```

### Manual Cleanup Verification
```bash
# List remaining EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table

# List security groups
aws ec2 describe-security-groups --query 'SecurityGroups[*].[GroupId,GroupName]' --output table

# List elastic IPs
aws ec2 describe-addresses --query 'Addresses[*].[PublicIp,AssociationId]' --output table
```

## 📚 Additional Resources

### Documentation Links
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [Redis Documentation](https://redis.io/documentation)
- [Nginx Documentation](https://nginx.org/en/docs/)

### Best Practices
1. **Infrastructure as Code**: Always use version control for Terraform files
2. **Security**: Regularly update security groups and access keys
3. **Monitoring**: Implement comprehensive logging and monitoring
4. **Backup**: Regular database backups and disaster recovery plans
5. **Cost Optimization**: Monitor AWS usage and optimize instance sizes

### Production Checklist
- [ ] Update default passwords
- [ ] Configure SSL/TLS certificates
- [ ] Set up monitoring and alerting
- [ ] Implement backup strategies
- [ ] Configure log aggregation
- [ ] Set up CI/CD pipelines
- [ ] Implement health checks
- [ ] Configure auto-scaling
- [ ] Set up disaster recovery
- [ ] Document operational procedures

---

## 🤝 Contributing

To contribute to this project:
1. Fork the repository
2. Create a feature branch
3. Update IP addresses in security groups
4. Test thoroughly in your environment
5. Submit a pull request with detailed description

## ⚠️ Important Notes

1. **IP Address Updates**: Update the hardcoded IP addresses in security groups to match your location
2. **SSH Key Management**: Ensure all `.pem` files are properly secured and accessible
3. **Cost Monitoring**: Monitor your AWS usage to avoid unexpected charges
4. **Security**: Change default passwords and implement proper authentication
5. **Path Updates**: Modify file paths in Terraform configurations to match your local setup

---

**Happy Deploying! 🚀**

*This multi-tier architecture provides a solid foundation for scalable, production-ready FastAPI applications with proper separation of concerns and security best practices.*
