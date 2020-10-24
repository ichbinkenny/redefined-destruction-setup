#!/bin/sh

printf "Will this device act as the server? [Y/n]: "

read isServer

ssid="Battle Bot Server"
pass="123456789"

if [ $isServer != "Y" ] && [ $isServer != "y" ]
then
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install bluez python3-pip libbluetooth-dev

sudo pip3 install pybluez
sudo apt-get -y install libnfc-dev libnfc-bin libfreefare-dev

# Modifications to allow pybluez to function properly in compatability mode
echo "Setting up system dbus files..."
sudo cp -f /home/pi/redefined-destruction/Setup/dbus-org.bluez.service /etc/systemd/system/
sudo cp -f /home/pi/redefined-destruction/Setup/dbus-org.bluez.service /lib/systemd/system/bluetooth.service
sudo sdptool add SP
sudo systemctl daemon-reload
sudo systemctl restart bluetooth
sudo hciconfig hci0 up
sudo hciconfig hci0 piscan
echo "Adding proper bluetooth starting services..."
sudo mkdir /usr/redefined-destruction/
sudo cp /home/pi/redefined-destruction/Setup/scripts/bluetooth_start.sh /usr/redefined-destruction/
sudo cp /home/pi/redefined-destruction/Setup/bluetooth_start.service /etc/systemd/system/
echo "Enabling System Services"
sudo systemctl enable bluetooth_start.service
sudo systemctl start bluetooth_start.service
echo "Complete!"

else
    echo "Installing server software..."
    sudo apt-get update
    sudo apt-get -y upgrade
    sudo apt-get -y install -y hostapd dnsmasq

    printf "Would you like to enter a custom ssid? [Y/n]: "
    read ans
    if [ $ans = "Y" ] || [ $ans = "y" ]
    then
        printf "Please enter the desired SSID: "
        read ssid
    fi

    printf "Would you like to enter a custom password? [Y/n]: "
    read ans
    if [ $ans = "y" ] || [ $ans = "Y"]
    then
        printf "Please enter the server password: "
        read pass
    fi

    ipv4_update=$(awk '/^net.ipv4.ip_forward=/{print}' /etc/sysctl.conf)
    
    if [ $ipv4_update = "" ]
    then
        echo "setting up nat forwarding"
        sudo echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
    fi

    iptbl=$(awk '/^iptables -t nat -A POSTROUTING -s 192.168.8.0/24 ! -d 192.168.8.0/24  -j MASQUERADE/{print}' /etc/rc.local)

    if [ $iptbl = "" ]
    then
        echo "adding iptables rules"
        sudo echo "iptables -t nat -A POSTROUTING -s 192.168.8.0/24 ! -d 192.168.8.0/24  -j MASQUERADE" >> /etc/rc.local
    fi

    echo "Server is setup as $ssid with password $pass"

    printf "interface=wlan0\ndriver=nl80211\nssid=$ssid\nhw_mode=g\nwpa=2\nwpa_passphrase=$pass\nwpa_key_mgmt=WPA-PSK\nchannel=1\nwmm_enabled=1\nmacaddr_acl=0\nauth_algs=3\nignore_broadcast_ssid=0\nwpa_pairwise=CCMP\nrsn_pairwise=CCMP\n" > hostapd.conf

    echo "Copying DNSMASQ config"
    sudo cp dnsmasq.conf /etc/

    echo "Finalizing HostAPD"
    sudo cp hostapd.conf /etc/hostapd/

    echo "Setting up interfaces"
    sudo cp interfaces /etc/network/
fi