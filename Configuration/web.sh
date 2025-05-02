#!/bin/bash
# This script is used to Deploy the Fastapi application
cd /root/
#Nginx Installation
echo "########################Starting Setup####################################"
sudo apt update && apt upgrade -y 
echo "########################Installing Nginx Server###########################"
sudo apt install nginx -y
echo "##########################################################################"
# Cloning Deployment Repository
git clone https://github.com/HATAKEkakshi/Fastapi-Application-Deployement-using-Terraform.git
cd Fastapi-Application-Deployement-using-Terraform/Configuration
#Copying Nginx Configuration File
echo "###############Setting Up Configuration File for Nginx####################"
sudo cp /root/Fastapi-Application-Deployement-using-Terraform/Configuration/fastapi_nginx /etc/nginx/sites-available/fastapi_nginx
echo "##########################################################################"
sudo systemctl restart nginx
echo "####################Setting Up pyenv-local Service######################"
cp pyenv-local.service /etc/systemd/system/pyenv-local.service
echo "#####################################################################"
echo "####################Starting pyenv-local Service#########################"
systemctl daemon-reload
systemctl start pyenv-local.service
systemctl enable pyenv-local.service
echo "#####################################################################"
cd ..
#Cloning Source Code
git clone https://github.com/Madhur-Prakash/FastAPI-Practice.git
cd FastAPI-Practice
#Installing Dependencies
echo "########################Installing Dependencies############################"
pyenv local pypy3.10-7.3.18
pip install -r requirements.txt
echo "##########################################################################"
#Creating Systemd Service
echo "########################Creating Systemd Service###########################"
cd ..
cd /root/Fastapi-Application-Deployement-using-Terraform/Configuration
sudo cp /root/Fastapi-Application-Deployement-using-Terraform/Configuration/fastapi.service /etc/systemd/system/fastapi.service
echo "##########################################################################"
sudo systemctl start fastapi
sudo systemctl enable fastapi
echo "##########################################################################"
