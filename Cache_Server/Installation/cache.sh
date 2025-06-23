#!/bin/bash

set -e

echo "####################################### Starting the Installer #######################################"
echo "####################################### Updating the System #######################################"
sudo apt-get update -y

echo "####################################### Installing Required Packages #######################################"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    gnupg-agent

echo "####################################### Adding Docker Repository #######################################"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

echo "####################################### Installing Docker #######################################"
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "####################################### Enabling Docker #######################################"
sudo systemctl start docker
sudo systemctl enable docker

echo "####################################### Starting Redis Stack Server #######################################"
sudo docker run -d --name redis-stack-server -p 6379:6379 redis/redis-stack-server:latest

echo "####################################### Starting Redis Insight #######################################"
sudo docker run -d --name redisinsight -p 5540:5540 redis/redisinsight:latest

echo "####################################### Redis Services Started #######################################"

echo "####################################### Creating redis-docker-service #######################################"
sudo cp /tmp/redis-docker-services.service /etc/systemd/system/redis-docker-services.service

echo "####################################### Reloading and Enabling redis-docker-service #######################################"
sudo systemctl daemon-reload
sudo systemctl start redis-docker-services
sudo systemctl enable redis-docker-services

echo "####################################### Creating redis-docker-cleanup Service #######################################"
sudo cp /tmp/redis-docker-cleanup.service /etc/systemd/system/redis-docker-cleanup.service

echo "####################################### Reloading and Enabling redis-docker-cleanup #######################################"
sudo systemctl daemon-reload
sudo systemctl start redis-docker-cleanup
sudo systemctl enable redis-docker-cleanup

echo "####################################### Installation Completed Successfully #######################################"
