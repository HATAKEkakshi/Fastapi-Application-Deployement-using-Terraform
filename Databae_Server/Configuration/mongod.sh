#!/bin/bash
echo "##########################Configuring MongoDB Server#################################"
cp  mongod.conf /etc/mongod.conf
echo "#######################################################################################"
echo "####################Starting MongoDB Server#############################################" 
systemctl daemon-reload
systemctl start mongod
systemctl enable mongod
systemctl status mongod
echo "#######################################################################################"