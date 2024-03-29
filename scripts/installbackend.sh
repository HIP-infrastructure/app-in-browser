#!/bin/bash

if ! command -v jq &> /dev/null
then
    echo "jq could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y jq
    echo "jq installed."
fi

if ! command -v pip3 &> /dev/null
then
    echo "pip3 could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y python3-pip
    echo "pip3 installed."
fi
sudo pip3 install -r backend/requirements.txt

if ! command -v caddy &> /dev/null
then
    echo "caddy could not be found, installing..."
    sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
    sudo apt-get update && sudo apt-get install -y caddy
    sudo systemctl stop caddy
    sudo systemctl disable caddy
    echo "caddy installed."
fi

if ! command -v pm2 &> /dev/null
then
    echo "pm2 could not be found, installing..."
    sudo npm install pm2 -g
    echo "pm2 installed."
fi

# generate backend credentials if needed
./scripts/gencreds.sh

cd pm2 && npm i && cd ..
sudo pm2 start pm2/ecosystem.config.js
sudo pm2 save
sudo pm2 startup
sudo systemctl start pm2-root
sudo systemctl enable pm2-root
