echo "Deploying FastAPI application..."
echo "Starting setup..."
echo "Choose from the following options:"
echo "1. Deploy MongoDB"
echo "2. Deploy Redis"
echo "3. Deploy FastAPI application"
echo "4. Destroy all resources"
read choice
if [ "$choice" -eq 1 ]; then
    echo "Deploying MongoDB..."
    cd Database_Server/Infrastructure
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "MongoDB deployment completed. Please check the IPs in ips.txt."
    echo "You can now connect to MongoDB using the provided IPs."
    echo "Make sure to configure your application to use these IPs."
    echo "MongoDB is now ready for use."
    echo "Please ensure you have updated mongodb link with provided IPs in your application configuration."
elif [ "$choice" -eq 2 ]; then
    echo "Deploying Redis..."
    cd Cache_Server/Infrastructure/fastapi
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "Redis deployment completed. Please check the IPs in ips.txt."
    echo "You can now connect to Redis using the provided IPs."
    echo "Make sure to configure your application to use these IPs."
    echo "Redis is now ready for use."
    echo "Please ensure you have updated redis link with provided IPs in your application configuration."
elif [ "$choice" -eq 3 ]; then
    echo "Deploying FastAPI application..."
    cd Fastapi_Application/Infra
    terraform init
    terraform validate
    terraform plan
    terraform apply -auto-approve
    cat ips.txt
    echo "FastAPI application deployment completed. Please check the IPs in ips.txt."
    echo "You can now access the FastAPI application using the provided IPs."
    echo "Make sure to configure your application to use these IPs."
    echo "FastAPI application is now ready for use."
    echo "Please ensure you have updated nginx with the ip of the server in your application configuration. here is the location where to update in fastapi_nginx proxy_pass http://127.0.0.1:8000 remove localhost and replace it with the ip of the server"
elif [ "$choice" -eq 4 ]; then
    echo "Destroying all resources..."
    echo "This will remove all deployed resources. Are you sure? (yes/no)"
    read confirmation
    if [ "$confirmation" == "yes" ]; then
        echo "Destroying MongoDB resources..."
        cd Database_Server/Infrastructure
        terraform destroy -auto-approve
        echo "MongoDB resources destroyed."
        echo "Destroying Redis resources..."
        cd ../../Cache_Server/Infrastructure/fastapi
        terraform destroy -auto-approve
        echo "Redis resources destroyed."
        echo "Destroying FastAPI application resources..."
        cd ../../Fastapi_Application/Infra
        terraform destroy -auto-approve
        echo "FastAPI application resources destroyed."
        echo "All resources have been successfully destroyed."
else
    echo "Invalid choice. Please run the script again."
fi
