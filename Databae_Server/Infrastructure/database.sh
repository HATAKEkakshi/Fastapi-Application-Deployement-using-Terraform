#!/bin/bash

set -e  # Exit on any error

echo "################### Installing MongoDB ########################"

echo "################### Importing the public key ###################"
sudo apt-get update -y
sudo apt-get install -y gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
  sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg

echo "################### Creating MongoDB source list ###################"
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" | \
  sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list

echo "################### Updating package index ###################"
sudo apt-get update -y

echo "################### Installing MongoDB ###################"
sudo apt-get install -y mongodb-org

echo "################### Starting MongoDB (without auth for now) ###################"
sudo systemctl daemon-reexec
sudo systemctl start mongod

echo "################### Creating Admin User ###################"
sleep 5

mongosh <<EOF
use admin
db.createUser({
  user: "admin",
  pwd: "password",
  roles: [ { role: "root", db: "admin" } ]
});
EOF

echo "################### Applying Configuration (with auth enabled) ###################"
if [ -f /tmp/mongod.conf ]; then
  echo ">> Found custom /tmp/mongod.conf, applying configuration"
  sudo cp /tmp/mongod.conf /etc/mongod.conf
else
  echo ">> WARNING: /tmp/mongod.conf not found, enabling auth in default config"
  sudo sed -i '/#security:/a\  authorization: "enabled"' /etc/mongod.conf
  sudo sed -i 's/#security:/security:/' /etc/mongod.conf
fi

sudo systemctl daemon-reload
sudo systemctl restart mongod

echo "################### Enabling MongoDB Service ###################"
sudo systemctl enable mongod

echo "################### Creating Collection and Index ###################"
sleep 5


