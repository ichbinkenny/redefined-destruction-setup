#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install bluez python3-pip libbluetooth-dev

sudo pip3 install pybluez
sudo apt-get install libnfc-dev libnfc-bin libfreefare-dev

# Modifications to allow pybluez to function properly in compatability mode
echo "Setting up system dbus files..."
sudo cp -f ./dbus-org.bluez.service /etc/systemd/system/
sudo sdptool add SP
echo "Complete!"