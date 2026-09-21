
# Debian Post-Install & Hardware Fix Script (MacBook Pro Mid 2014)

A tailored post-installation setup script for running **Debian 12 (Bookworm)** or **Ubuntu 22.04 / 24.04 LTS** on the **Apple MacBook Pro (Retina, 13-inch & 15-inch, Mid 2014)**. 

This script resolves out-of-the-box hardware issues specific to Intel Haswell-based MacBooks, including FaceTime HD camera drivers, Broadcom BCM4360 Wi-Fi support, CPU power/thermal capping, and multimedia codecs.

---

## 💻 Target Hardware Compatibility

| Model | Screen Size | Processor | Wi-Fi Chipset | Dedicated GPU |
| :--- | :--- | :--- | :--- | :--- |
| **MacBookPro11,1** | 13-inch | Intel Core i5/i7 (Haswell) | Broadcom BCM4360 | Intel Iris 5100 |
| **MacBookPro11,2** | 15-inch | Intel Core i7 (Haswell) | Broadcom BCM4360 | Intel Iris Pro 5200 |
| **MacBookPro11,3** | 15-inch | Intel Core i7 (Haswell) | Broadcom BCM4360 | NVIDIA GeForce GT 750M |

---

## 📋 Features

- **APT Repository Fix:** Safely enables `contrib`, `non-free`, and `non-free-firmware` sources required for Broadcom and FaceTime HD dependencies without duplication.
- **FaceTime HD Camera Driver (`bcwc_pcie`):** Clones, compiles, and loads the kernel module for the PCIe Broadcom 1570 FaceTime HD camera.
- **Broadcom Wi-Fi Fix:** Installs `broadcom-sta-dkms` (`wl` driver) and `b43-fwcutter` for full 802.11ac wireless connectivity.
- **Intel RAPL Power Capping:** Prevents thermal throttling and high fan speeds on Haswell CPUs using `powercap-utils`.
- **Essential Codecs:** Installs GStreamer plugins, `ffmpeg`, and `libavcodec` for full media playback support.

---

## 🛠️ Prerequisites

1. **OS:** Debian 12+, Ubuntu 22.04 LTS+, or derivatives (Linux Mint, Pop!_OS, CachyOS/Debian-based).
2. **Network Connection:** USB Tethering (via iPhone/Android) or a USB-to-Ethernet adapter during the initial setup run, as Wi-Fi will not work until drivers are compiled.
3. **Sudo Privileges:** Active user with `sudo` access.

---

## 🚀 Installation

1. **Clone this repository:**
   ```bash
   git clone [https://github.com/your-username/macbookpro-2014-linux-setup.git](https://github.com/your-username/macbookpro-2014-linux-setup.git)
   cd macbookpro-2014-linux-setup

```

2. **Make the script executable:**
```bash
chmod +x setup.sh

```


3. **Execute the script:**
```bash
./setup.sh

```



---

## ⚙️ Post-Installation Setup

### 1. Intel RAPL CPU Powercap Service

Haswell MacBook Pros tend to run hot under Linux default power governors. To cap power usage (28W limit for 13" / 35W limit for 15"):

1. Create the systemd service unit:
```bash
sudo nano /etc/systemd/system/powercap-limit.service

```


2. Paste the following configuration:
```ini
[Unit]
Description=Apply Balanced RAPL Power Limit for Mid 2014 MacBook Pro
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStartPre=-/sbin/modprobe intel_rapl_msr
ExecStartPre=/bin/sleep 2
ExecStart=/usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 25777777
ExecStart=/usr/bin/powercap-set intel-rapl -z 0 -c 1 -l 35999999

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

```


3. Enable and activate the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable --now powercap-limit.service

```



---

### 2. Battery & Core Tuning (Optional)

To reduce power consumption on 15" Quad-Core models or extend battery life on 13" models:

1. Edit `/etc/default/grub`:
```bash
sudo nano /etc/default/grub

```


2. Add `maxcpus=6` (or desired core limit) to `GRUB_CMDLINE_LINUX_DEFAULT`:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash maxcpus=6"

```


3. Update GRUB and reboot:
```bash
sudo update-grub
sudo reboot

```



---

### 3. Dual-GPU Setup (15-inch DG Model Only - `MacBookPro11,3`)

If you are using the 15-inch model with the **NVIDIA GeForce GT 750M**, install the legacy 470.x series driver:

```bash
sudo apt update
sudo apt install nvidia-driver-470

```

---

## 🔍 Hardware Troubleshooting

* **Wi-Fi Not Detected After Reboot:**
Check if the `wl` module is active or if conflicting drivers are loaded:
```bash
sudo modprobe -r b43 brcmfmac
sudo modprobe wl

```


* **Camera Module Issues:**
If the FaceTime HD camera fails to initialize, force unload and reload the module:
```bash
sudo modprobe -r facetimehd
sudo modprobe facetimehd
dmesg | grep -i facetimehd

```



---
