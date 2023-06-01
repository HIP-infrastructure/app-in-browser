#!/bin/bash

#remove any netowrk restrictions on containers
sudo iptables -F DOCKER-USER 
sudo iptables -I DOCKER-USER -j ACCEPT

#destroy the ipset
sudo ipset destroy docker-allowed

#make configuration persistent
sudo netfilter-persistent save
sudo systemctl start netfilter-persistent
sudo systemctl enable netfilter-persistent
