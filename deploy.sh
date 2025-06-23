#!/bin/bash

echo "==========================================="
echo "Choose from the following options:"
echo "1. Deploy MongoDB"
echo "2. Deploy Redis"
echo "3. Deploy FastAPI application"
echo "4. Destroy all resources"
echo "==========================================="

read -p "Enter your choice [1-4]: " choice

if [ "$choice" -eq 1 ]; then
    echo "Deploying MongoDB..."
    cd Databae_Server/Infrastructure || exit
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "✅ MongoDB deployment completed. Check 'ips.txt' for connection details."
    echo "Please update your application configuration with the provided MongoDB IPs."

elif [ "$choice" -eq 2 ]; then
    echo "Deploying Redis..."
    cd Cache_Server/Infrastructure/fastapi || exit
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "✅ Redis deployment completed. Check 'ips.txt' for connection details."
    echo "Please update your application configuration with the provided Redis IPs."

elif [ "$choice" -eq 3 ]; then
    echo "Deploying FastAPI application..."
    cd Fastapi_Application/Infra || exit
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "✅ FastAPI application deployment completed. Check 'ips.txt' for connection details."
    echo "Update your NGINX config: replace '127.0.0.1' in 'proxy_pass' with the public IP."

elif [ "$choice" -eq 4 ]; then
    echo "⚠️  Destroying all resources..."
    read -p "This will remove all deployed resources. Are you sure? (yes/no): " confirmation
    if [ "$confirmation" == "yes" ]; then
        echo "Destroying MongoDB resources..."
        cd Databae_Server/Infrastructure || exit
        terraform destroy -auto-approve
        echo "MongoDB resources destroyed."

        echo "Destroying Redis resources..."
        cd ../../Cache_Server/Infrastructure || exit
        terraform destroy -auto-approve
        echo "Redis resources destroyed."

        echo "Destroying FastAPI application resources..."
        cd ../../Fastapi_Application/Infra || exit
        terraform destroy -auto-approve
        echo "FastAPI application resources destroyed."

        echo "✅ All resources have been successfully destroyed."
    else
        echo "Resource destruction cancelled."
    fi

else
    echo "Invalid choice. Please run the script again and select a valid option (1-4)."
fi
