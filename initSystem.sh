#!/bin/sh

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install bluez python3-pip libbluetooth-dev

sudo pip3 install pybluez
sudo apt-get install libnfc-dev libnfc-bin libfreefare-dev

# Modifications to allow pybluez to function properly in compatability mode
echo "Setting up system dbus files..."
sudo cp -f /home/pi/redefined-destruction/Setup/dbus-org.bluez.service /etc/systemd/system/
sudo cp -f /home/pi/redefined-destruction/Setup/dbus-org.bluez.service /lib/systemd/system/bluetooth.service
sudo sdptool add SP
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
sudo hciconfig hci0 up
sudo hciconfig hci0 piscan
echo "Complete!"