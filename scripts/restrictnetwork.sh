#!/bin/bash

if ! command -v ipset &> /dev/null
then
    echo "ipset could not be found, installing..."
    sudo apt-get update && sudo apt-get install -y ipset
    echo "ipset installed."
fi

REQUIRED_PKG="netfilter-persistent"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "$REQUIRED_PKG could not be found, installing..."
  sudo apt-get update && sudo apt-get install -y $REQUIRED_PKG
  echo "$REQUIRED_PKG installed."
fi

REQUIRED_PKG="iptables-persistent"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "$REQUIRED_PKG could not be found, installing..."
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
  sudo apt-get update && sudo apt-get install -y $REQUIRED_PKG
  echo "$REQUIRED_PKG installed."
fi

REQUIRED_PKG="ipset-persistent"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
  echo "$REQUIRED_PKG could not be found, installing..."
  echo iptset-persistent ipset-persistent/autosave boolean true | sudo debconf-set-selections
  sudo apt-get update && sudo apt-get install -y $REQUIRED_PKG
  echo "$REQUIRED_PKG installed."
fi

#create the ipset
sudo ipset create docker-allowed hash:ip comment

#populate the ipset
./scripts/populateipset.py

##save the ipset
#sudo mkdir -p /etc/ipset
#sudo bash -c "ipset save > /etc/ipset/ipsets"

#start and enable ipset
sudo systemctl start ipset.service
sudo systemctl enable ipset.service

#use the ipset to restrict network access within containers
NETIFACE=$(ip route | grep default | sed -e "s/^.*dev.//" -e "s/.proto.*//")
sudo iptables -F DOCKER-USER 
sudo iptables -I DOCKER-USER -i $NETIFACE -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -I DOCKER-USER -i $NETIFACE -m set ! --match-set docker-allowed src -j DROP

#make configuration persistent
sudo netfilter-persistent save
sudo systemctl enable netfilter-persistent

#print summary
echo "Summary:"
sudo ipset list
