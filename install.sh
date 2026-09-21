#!/bin/bash

# Define the target file
FILE="/etc/apt/sources.list"

# Check if the file exists
if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found."
    exit 1
fi

# Run sed with a condition: only match 'non-free-firmware' if NOT followed by 'contrib' or 'non-free'
sudo sed -i -E '/contrib|non-free/!s/non-free-firmware/non-free-firmware contrib non-free/g' "$FILE"

echo "APT sources updated safely without duplications."


sudo apt update

echo ''
echo ''
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



echo ''
echo ''
echo '>>>>>>>>>>>>>>>>>>>>>>>>>      Codec install       <<<<<<<<<<<<<<<<<<<<<<<<<<<'
sudo apt update 
sudo apt install ffmpeg gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav libavcodec-extra


echo ''
echo ''
echo ''
echo '>>>>>>>>>>>>>>>>>>>>>>   CPU Powercap installation   <<<<<<<<<<<<<<<<<<<<<<<<'

sudo apt install powercap-utils
echo ''
echo ' !!!!!!!!!!!!!!!!!  Please make this service   >>>>>
...........................................................................................................................
...........................................................................................................................
etc/systemd/system/powercap-limit.service
[Unit]
Description=Apply Balanced 28W RAPL Power Limit
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
# Ensure the RAPL module is loaded (the "-" ignores errors if already built-in)
ExecStartPre=-/sbin/modprobe intel_rapl_msr
# Wait for the powercap sysfs tree to become available
ExecStartPre=/bin/sleep 2
ExecStart=/usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 25777777
ExecStart=/usr/bin/powercap-set intel-rapl -z 0 -c 1 -l 35999999

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target 
...................................................................................................................................
...................................................................................................................................
[[[[[[[[[[[[[[[[[[[[[    # 1. Reload the systemd manager configuration (Run this first if you just installed or edited the service)
sudo systemctl daemon-reload

# 2. Enable the service to start on boot AND start it immediately right now
sudo systemctl enable --now cpupower-gui.service
sudo powercap-info intel-rapl -z 0
# 3. Check the real-time status to verify it is running successfully (Note: fixed 'systemctl' typo)
systemctl status cpupower-gui.service      

sudo powercap-info intel-rapl -z 0

]]]]]]]]]]]]]]

....................................         For more Powersave      ...........................................
                                     add maxcpus=6 in /etc/default/grub 
eg. GRUB_CMDLINE_LINUX_DEFAULT='quiet splash maxcpus=6 resume=UUID=d0dadc03-1366-48d0-b813-73b23b2384c8'

'




echo ''
echo ''
echo ' >>>>>>>>>>>>>>>>>>  wifi driver  installation   <<<<<<<<<<<<<<<<< '
sudo apt install linux-headers-amd64 firmware-linux-nonfree firmware-misc-nonfree b43-fwcutter firmware-b43-installer broadcom-sta-dkms

echo " if fails write :::  sudo sed -i 's/non-free-firmware/non-free-firmware contrib non-free/g' /etc/apt/sources.list "

echo ' execute >>>>>   sudo reboot '
