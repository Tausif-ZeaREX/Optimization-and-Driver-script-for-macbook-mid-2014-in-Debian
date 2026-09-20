#!/bin/bash

sudo apt update
echo ' >>>>>>>>>>  Camera driver  installation <<<<<< '
sudo apt install xz-utils curl cpio make curl xz-utils cpio -y
cd /tmp
git clone https://github.com/patjak/facetimehd-firmware.git
cd facetimehd-firmware
make
sudo make install 
sudo apt-get install linux-headers-generic git kmod libssl-dev checkinstall
cd /tmp
git clone https://github.com/patjak/bcwc_pcie.git
cd bcwc_pcie
make
sudo make install
sudo depmod
sudo modprobe facetimehd

sudo apt update 
sudo apt install ffmpeg gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav libavcodec-extra

echo ' >>>>>>  wifi driver  installation <<<<<<< '

echo ' <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<   Codec install    >>>>>>>>>>>>>>>>>>>>>>>>'
sudo apt install linux-headers-amd64 firmware-linux-nonfree firmware-misc-nonfree b43-fwcutter firmware-b43-installer broadcom-sta-dkms

echo " if fails write :::  sudo sed -i 's/non-free-firmware/non-free-firmware contrib non-free/g' /etc/apt/sources.list "

echo ' execute >>>>>   sudo reboot '

