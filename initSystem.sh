#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install bluez python3-pip libbluetooth-dev

sudo pip3 install pybluez
sudo apt-get install libnfc-dev libnfc-bin libfreefare-dev
