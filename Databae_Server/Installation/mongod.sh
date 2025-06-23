#!/bin/bash
echo "###################Installing MongoDB########################"
echo "#####################Import the public key###################"
sudo apt-get install gnupg curl
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
 --dearmor
echo "#####################Create a list file for MongoDB###################"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
echo "#####################Reload local package database###################"
sudo apt-get update
echo "#####################Install the MongoDB packages###################"
sudo apt-get install -y mongodb-org
echo "#####################Start MongoDB###################"
sudo systemctl start mongod
echo "#####################Enable MongoDB###################"
sudo systemctl enable mongod        
echo "#####################Check MongoDB###################"
sudo systemctl status mongod
