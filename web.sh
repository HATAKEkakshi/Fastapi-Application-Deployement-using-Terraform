#!/bin/bash
# This script is used to Deploy the Fastapi application

#Nginx Installation
echo "########################Starting Setup####################################"
sudo apt update && apt upgrade -y 
echo "########################Installing Nginx Server###########################"
sudo apt install nginx -y
echo "##########################################################################"
# Cloning Deployment Repository
git clone https://github.com/HATAKEkakshi/Fastapi-Application-Deployement-using-Terraform.git
cd Fastapi-Application-Deployement-using-Terraform
#Copying Nginx Configuration File
echo "###############Setting Up Configuration File for Nginx####################"
sudo cp fastapi_nginx /etc/nginx/sites-available/fastapi_nginx
echo "##########################################################################"
sudo systemctl restart nginx
#Cloning Source Code
git clone https://github.com/Madhur-Prakash/FastAPI-Practice.git
cd FastAPI-Practice
#Installing Python3 and pip
echo "########################Installing Python3 and pip#########################"
sudo apt install python3 python3-pip -y
echo "##########################################################################"
#Installing Dependencies
echo "########################Installing Dependencies############################"
pip3 install -r requirements.txt
echo "##########################################################################"
#Creating Systemd Service
echo "########################Creating Systemd Service###########################"
cd ..
cd Fastapi-Application-Deployement-using-Terraform
sudo cp fastapi.service /etc/systemd/system/fastapi.service
echo "##########################################################################"
echo "########################Starting FastAPI Service#############################"
sudo systemctl start fastapi
sudo systemctl enable fastapi
echo "##########################################################################"