# 🚀 FastAPI Application Deployment using Terraform

This project automates the deployment of a FastAPI application on AWS using Terraform. It provisions infrastructure, configures an EC2 environment, installs required software, and deploys your FastAPI app with Nginx as a reverse proxy.

---

## 🌟 Features

- **Infrastructure as Code**: Terraform-based setup of EC2, Security Groups, Key Pairs, etc.
- **FastAPI Deployment**: Serves FastAPI behind Nginx on an AWS EC2 instance.
- **Automated Bootstrapping**: Uses systemd services and shell scripts for app setup.
- **Secure Networking**: Configures Security Groups to allow only SSH (22) and HTTP (80).

---

## 🔧 Prerequisites

Make sure the following are installed and configured on your local machine:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) with credentials configured
- SSH key pair for EC2 access
- Git

---

## 📁 Project Structure

```bash
.
├── Configuration/
│   ├── fastapi_nginx        # Nginx config for FastAPI
│   ├── fastapi.service      # systemd service for FastAPI
│   ├── pyenv-local.service  # systemd for Python env
│   └── web.sh               # Deployment script
├── Infra/
│   ├── Instance.tf          # EC2 instance setup
│   ├── Keypair.tf           # SSH key pair
│   ├── SecGrp.tf            # Security group config
│   ├── provider.tf          # AWS provider block
│   ├── var.tf               # Terraform variables
│   ├── terraform.tfstate    # Terraform state (ignored in .gitignore)
│   └── .terraform/          # Terraform cache directory
├── .gitignore               # Git ignore rules
└── README.md                # Project 

## 1. Clone the Repository
git clone https://github.com/HATAKEkakshi/Fastapi-Application-Deployement-using-Terraform.git
cd Fastapi-Application-Deployment-using-Terraform
##  Initialize Terraform
```
cd Infra
terraform init
```
```

## Review Terraform Plan
```terraform plan
```
## Apply Terraform Configuration
```
terraform apply
````

