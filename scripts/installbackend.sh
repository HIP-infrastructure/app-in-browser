#!/bin/bash
if ! command -v pip3 &> /dev/null
then
    echo "pip3 could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y python3-pip
    echo "pip3 installed."
fi
sudo pip3 install -r backend/requirements.txt

if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found, installing..."
    sudo npm install pm2 -g
    echo "pm2 installed."
fi
sudo pm2 start pm2/ecosystem.config.js
sudo pm2 save
sudo pm2 startup
sudo systemctl start pm2-root
sudo systemctl enable pm2-root

if ! command -v caddy &> /dev/null
then
    echo "caddy could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y caddy
    sudo systemctl stop caddy
    sudo systemctl disable caddy
    echo "caddy installed."
fi
