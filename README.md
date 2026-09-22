
# Debian Post-Install & Hardware Fix Script (MacBook Pro Mid 2014)

A tailored post-installation setup script specifically tested on **Debian 13 (Trixie)** for the **Apple MacBook Pro (Retina, 13-inch & 15-inch, Mid 2014)**. 

This script resolves out-of-the-box hardware issues specific to Intel Haswell-based MacBooks, including FaceTime HD camera drivers, Broadcom BCM4360 Wi-Fi support, CPU power/thermal capping, and multimedia codecs.

> **Note:** Tested and confirmed working on **Debian 13 (Trixie)**. Compatibility with Ubuntu or other Debian derivatives is not guaranteed.

---

## 💻 Target Hardware Compatibility

| Model | Screen Size | Processor | Wi-Fi Chipset | Dedicated GPU |
| :--- | :--- | :--- | :--- | :--- |
| **MacBookPro11,1** | 13-inch | Intel Core i5/i7 (Haswell) | Broadcom BCM4360 | Intel Iris 5100 |
| **MacBookPro11,2** | 15-inch | Intel Core i7 (Haswell) | Broadcom BCM4360 | Intel Iris Pro 5200 |


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
   git clone https://github.com/Tausif-ZeaREX/Optimization-script-for-macbook-mid-2014.git
   cd Optimization-script-for-macbook-mid-2014.git

```https://github.com/Tausif-ZeaREX/Optimization-script-for-macbook-mid-2014-in-Debian.git

2. **Make the script executable:**

chmod +x install.sh

```


3. **Execute the script:**

./install.sh

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

---

# Linux Bluetooth Controller Input Lag Fix

A clean guide to permanently fixing slow response rates, input lag, and frame drops for Bluetooth wireless controllers (Xbox, PlayStation, 8BitDo) running on Linux. This forces the kernel to poll the controller at its minimum allowable Bluetooth Low Energy (LE) interval: **6 (7.5ms)**.

Bluetooth slow response time issue fix <<<<<

By default, the Linux Bluetooth stack (BlueZ) often negotiates high, power-saving connection intervals for low-energy devices. A default configuration can set the connection intervals between **24 (30ms)** and **40 (50ms)**, resulting in noticeable latency during gaming. 

---

### Quick Diagnostic

Before making changes, check what your live kernel parameters are currently set to. Run the following commands while your controller is connected:

```bash
cat /sys/kernel/debug/bluetooth/hci0/conn_min_interval
cat /sys/kernel/debug/bluetooth/hci0/conn_max_interval
```
*Note: If you receive a "No such file or directory" error, your Bluetooth adapter might be named `hci1`. Check using `ls /sys/kernel/debug/bluetooth/`.*

If the numbers returned are high (e.g., 24 and 40), your connection is actively throttled.

---

### The Solution: Permanent Global Configuration

This method configures BlueZ to apply high-performance parameters to all Bluetooth Low Energy (LE) devices globally upon connection.

1. Open the global Bluetooth configuration file:
   ```bash
   sudo nano /etc/bluetooth/main.conf
   ```

2. Scroll down to the `[LE]` section.

3. Find the default connection parameters (they are usually commented out with a `#`). Remove the `#` symbols and change the values to match this exactly:
   ```ini
   MinConnectionInterval=6
   MaxConnectionInterval=6
   ConnectionLatency=0
   ConnectionSupervisionTimeout=216
   ```
   * **`6`** forces the absolute minimum **7.5ms** connection interval.
   * **`ConnectionLatency=0`** prevents the device from skipping communication events to save power.
   * **`ConnectionSupervisionTimeout=216`** prevents random disconnects under tight polling intervals.

4. Save and exit (`Ctrl + O`, `Enter`, then `Ctrl + X`).

5. Restart the Bluetooth service to apply changes:
   ```bash
   sudo systemctl restart bluetooth
   ```

6. **Power your controller off and back on** to re-establish the connection with the new high-performance profile.

---

### Verifying the Fix

With your controller connected, re-run the diagnostic checks:
```bash
cat /sys/kernel/debug/bluetooth/hci0/conn_min_interval
cat /sys/kernel/debug/bluetooth/hci0/conn_max_interval
```

If both values return **`6`**, your system is successfully polling the wireless controller at a crisp, lag-free **7.5ms interval**.
