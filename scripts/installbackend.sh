#!/bin/bash
if ! command -v pip3 &> /dev/null
then
    echo "pip3 could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y python3-pip
    echo "pip3 installed."
fi
sudo pip3 install -r backend/requirements.txt
