#!/bin/bash

# install all tools required for the install, python, pip, requirements.txt etc..
./script/installrequirements.sh

# generate backend credentials if needed
./scripts/gencreds.sh

cd pm2 && npm i && cd ..
sudo pm2 start pm2/ecosystem.config.js
sudo pm2 save
sudo pm2 startup
sudo systemctl start pm2-root
sudo systemctl enable pm2-root