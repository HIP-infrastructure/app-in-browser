#!/bin/bash

#user the ipset to restrict network access within containers
sudo iptables -F DOCKER-USER 
sudo iptables -I DOCKER-USER -j ACCEPT

#make configuration persistent
sudo netfilter-persistent save
sudo systemctl start netfilter-persistent
sudo systemctl enable netfilter-persistent
