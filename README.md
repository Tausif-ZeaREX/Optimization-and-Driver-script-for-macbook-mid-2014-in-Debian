
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
ExecStart=/usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 29777777
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

# Linux RAPL Power Profiles Manager

A lightweight utility and systemd service to manage Intel/AMD processor power ceilings on Linux using **Runtime Average Power Limiting (RAPL)** via `powercap`. Easily switch between **Performance**, **Balanced**, and **Powersave** profiles manually or automatically at boot and resume.

## Features
* 🚀 **Instant Profile Switching:** Change wattage configurations on the fly.
* 🔋 **Persistent Across Reboots:** Restores your favorite default profile on system boot.
* 🌙 **Resume Hook Support:** Re-applies limits instantly after system suspension, hibernation, or sleep.

---
### 2. Deploy the Management Script
Create the profile script to handle different wattage limits:
```bash
sudo nano /usr/local/bin/powercap-profile
```
Paste the script content below, then save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`):
```bash
#!/bin/bash
/sbin/modprobe intel_rapl_msr 2>/dev/null
sleep 2

case "$1" in
    performance)
        echo "Applying Performance Profile (45W/54W)..."
        /usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 45000000
        /usr/bin/powercap-set intel-rapl -z 0 -c 1 -l 54000000
        ;;
    powersave)
        echo "Applying Powersave Profile (15W/20W)..."
        /usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 15000000
        /usr/bin/powercap-set intel-rapl -z 0 -c 1 -l 20000000
        ;;
    balanced)
        echo "Applying Balanced Profile (28W/32W)..."
        /usr/bin/powercap-set intel-rapl -z 0 -c 0 -l 27777777
        /usr/bin/powercap-set intel-rapl -z 0 -c 1 -l 31999999
        ;;
    *)
        echo "Usage: $0 {performance|powersave|balanced}"
        exit 1
        ;;
esac
```
Make the script executable:
```bash
sudo chmod +x /usr/local/bin/powercap-profile
```

### 3. Create the Systemd Automation Service
Create the service configuration to automatically apply your preferred profile on boot and wake:
```bash
sudo nano /etc/systemd/system/powercap-limit.service
```
Paste the following service definition:
```ini
[Unit]
Description=Apply Default RAPL Power Limit
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/powercap-profile balanced
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target
```
*Note: To change your default system-wide startup profile, change `balanced` at the end of the `ExecStart` line to `powersave` or `performance`.*

### 4. Enable and Activate
Reload systemd configurations, enable the service triggers, and fire it up manually:
```bash
sudo systemctl daemon-reload
sudo systemctl enable powercap-limit.service
sudo systemctl start powercap-limit.service
```

---

## 🕹️ Usage

### Manual Switching
You can manually switch between profiles at any time via the terminal:

* 🚀 **Performance:** `sudo powercap-profile performance`
* ⚖️ **Balanced:** `sudo powercap-profile balanced`
* 🔋 **Powersave:** `sudo powercap-profile powersave`

### Verify Settings
To check if the micro-watt values are properly pushed to your hardware sysfs architecture, run:
```bash
powercap-info -p intel-rapl
```

---

## ⚠️ Configuration Disclaimers
* **Intel Zone Support:** Depending on your machine generation (Intel Core / AMD Ryzen), zone index `0` and constraints `-c 0`/`-c 1` can represent Long Term (PL1) and Short Term (PL2) limits differently. Modify the script `-l` values (in microwatts) to match your CPU thermal capabilities.
* **Overriding Utilities:** Software like `thermald`, `TLP`, or `power-profiles-daemon` might try to overwrite powercap nodes during state transitions. Ensure they do not conflict with your defined limits.

# Macfanctl Configuration for MacBook Pro (Mid 2014, iGPU-Only)

[![Linux](https://shields.io)](https://kernel.org)
[![Hardware](https://shields.io)](https://apple.com)
[![License: MIT](https://shields.io)](https://opensource.org)

An optimized thermal profile and deployment guide for running the `macfanctld` daemon on a **Mid 2014 MacBook Pro** with **Intel Integrated Graphics (iGPU)** under Linux. 

Intel Haswell laptop architectures run notably warm under modern Wayland environments (such as `niri`). This profile focuses on aggressive, proactive thermal curve responses while isolating non-existent dedicated GPU hardware sensors to eliminate daemon errors.

---

## 💻 Hardware Profile & Stack

* **Machine:** MacBook Pro 11,1 (Mid 2014, 13-inch or iGPU-only 15-inch variant)
* **Processor:** Intel Core i5 / i7 (Haswell Architecture)
* **Graphics:** Intel Iris Graphics (No discrete NVIDIA/AMD GPU)
* **Co-Utilities:** `auto-cpufreq` + `powercap-utils` + `linux-cpupower`

---

## 🛠️ Configuration File (`/etc/macfanctl.conf`)

Place the following configuration layout into your `/etc/macfanctl.conf` path:

```text
# Config file for macfanctl daemon optimized for Mid 2014 iGPU MacBook Pro
# Note: 0 < temp_X_floor < temp_X_ceiling
#       0 < fan_min < 6200

# True physical hardware baseline to maintain silent, steady airflow
fan_min: 2999

# Aggressive cooling floors to preemptively fight idle heat build-up
temp_avg_floor: 45
temp_avg_ceiling: 62

temp_TC0P_floor: 45
temp_TC0P_ceiling: 62

# NO DEDICATED GPU - Set artificially high to neutralize missing TG0P sensor hooks
temp_TG0P_floor: 97
temp_TG0P_ceiling: 99

# Exclude list for unstable sensor matrices
exclude:

# Logging: 0 = Startup/Exit/Errors only, 2 = Full sensor matrix trace
log_level: 0
```

### 🧠 Profile Optimizations Breakdown
1. **`fan_min: 2999`**: Locks the fan to its true native hardware idle speed. This prevents the daemon from forcing a sub-2000 RPM speed, which chokes air volume on older heat sinks.
2. **Aggressive Thermal Ceiling (`62°C`)**: Instructs `macfanctld` to scale the fan curve to maximum velocity much earlier. This actively pulls down internal temperatures before the aluminum top-case heats up your lap or keyboard.
3. **GPU Neutralization (`TG0P`)**: Setting the GPU bounds to `97°C - 99°C` keeps the missing dedicated graphics architecture from feeding zeroed or erroneous telemetry to the tracking loop.

---

## 🚀 Installation & Deployment

### 1. Install dependencies and the daemon
```bash
sudo apt update
sudo apt install macfanctld lm-sensors linux-cpupower
```

### 2. Apply the profile
Clone this repository, then copy the configuration file over your system default:
```bash
sudo cp macfanctl.conf /etc/macfanctl.conf
```

### 3. Manage the background service
Enable the daemon to run immediately and automatically on system boot:
```bash
sudo systemctl daemon-reload
sudo systemctl enable macfanctld
sudo systemctl restart macfanctld
```

---

## 📊 Live Monitoring and Telemetry

Use these terminal triggers to verify the active performance metrics of your MacBook:

### Check Target Service Status
Confirm the service status shows `active (running)` without syntax rejections:
```bash
sudo systemctl status macfanctld
```

### Read True Fan RPM Output
Poll the hardware states directly from the Apple System Management Controller (`applesmc`) interface:
```bash
cat /sys/devices/platform/applesmc.768/fan1_output
```

### Read Core CPU Temperature
```bash
cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input
```
*(Note: Output values render as 5-digit millidegrees, meaning an output of `61000` is exactly 61°C).*

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

```


# <<  Linux Bluetooth Controller Input Lag Fix  >>>>>>

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
sudo cat /sys/kernel/debug/bluetooth/hci0/conn_min_interval
sudo cat /sys/kernel/debug/bluetooth/hci0/conn_max_interval
```

If both values return **`6`**, your system is successfully polling the wireless controller at a crisp, lag-free **7.5ms interval**.

---

## Extra (Not Coneected with repo) 
## Keyboard Backlight Control

```bash
echo 0 | sudo tee /sys/class/leds/smc::kbd_backlight/brightness
```
## Changing resolution in Niri

In  ~/.config/niri/config.kdl

```
output "eDP-1" {
    // Forces a custom 16:10 resolution matching your native screen shape
    mode custom=true "1920x1200@59.990"

    // Keeps it pixel-for-pixel sharp at this size
    scale 1.19
}

```