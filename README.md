# FreeBSD i3wm Deployment Script

This script automates the transformation of a fresh FreeBSD installation into a professional, Dracula-themed **i3wm** (Gaps) desktop environment. It handles everything from driver installation to display server choices and aesthetic configurations like blur, transparency, and system-wide color palettes.

## The Goal
To go from a "blank slate" FreeBSD terminal to a fully riced productivity machine in one command.

![alt text](https://raw.githubusercontent.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script/refs/heads/main/1.png)

![alt text](https://raw.githubusercontent.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script/refs/heads/main/2.png)

## Features
* **Display Server Options:** Interactive prompt to choose between standard **X.Org** or **XLibre** (a drop-in X.Org replacement).
* **Graphics Hardware Support:** Interactive driver installer for Intel/AMD (`drm-kmod`), Nvidia (`nvidia-driver`), or VirtualBox Guest Additions.
* **WM & Aesthetics:** `i3-gaps` paired with `picom` utilizing hardware-accelerated **EGL backend**, **dual-kawase blur**, custom shadows, frame opacities, and fade effects.
* **Custom Conky i3bar:** Streamlined JSON-formatted `conky` pipeline powering `i3bar` with dynamic system monitoring (CPU, RAM, IP addresses, uptime, battery, and date/time) and Dracula accent colors.
* **Dual-Navigation Keybindings:** Comprehensive window movement and workspace navigation supporting both standard Arrow keys and Vim keybindings (`hjkl`).
* **Consistency:** Synced Dracula colors across `i3`, `LightDM`, `GTK 2.0/3.0`, and `.Xresources`.
* **Hardware & System Support:** Configures `webcamd`, FUSE file systems, Linux binary compatibility (`linux_base-c7`), core dump disabling, and audio (`alsa-utils`/`pavucontrol`).
* **UK Localization:** Defaults to `gb` keyboard layout (`setxkbmap gb`).

## Included Software List

| Category | Packages |
| :--- | :--- |
| **Display Server** | `xorg` or `xlibre` *(Interactive Selection)* |
| **Window Manager** | `i3-gaps`, `i3status`, `i3lock-color`, `dmenu`, `conky` |
| **Login Manager** | `lightdm`, `lightdm-gtk-greeter`, `lightdm-gtk-greeter-settings`, `ant-dracula-theme` |
| **Terminal / CLI** | `uxterm`, `terminator`, `vim`, `nano`, `curl` |
| **Productivity** | `firefox`, `chromium`, `pcmanfm`, `calcurse`, `sc-im`, `zathura` |
| **Multimedia** | `cmus`, `mpv`, `pavucontrol`, `alsa-utils`, `volumeicon`, `eog` |
| **Utilities** | `nitrogen`, `arandr`, `gammy`, `webcamd`, `zip`, `gnubc`, `networkmgr`, `lxappearance`, `emulators/linux_base-c7` |

---

## Interactive Prompts

When you execute the script, it will guide you through menu choices for your graphics hardware and preferred display server:


-------------------------------------------------------
Select your Graphics Hardware:
1) Intel or AMD (Modern DRM)
2) Nvidia (Official Binary Driver)
3) VirtualBox (Guest Additions)
-------------------------------------------------------

-------------------------------------------------------
Select Display Server:
1) Standard X.Org
2) XLibre (Drop-in X.Org Replacement)
-------------------------------------------------------

---

## How to Run the Script

### 1. Prerequisite
Ensure you have a fresh FreeBSD install and a non-root user account assigned to the `wheel` group.

### 2. Install Git and Clone Repository
Log in as your regular user, elevate privileges to root, install `git`, and clone the project:

```bash
su -
pkg update && pkg install -y git
git clone [https://github.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script.git](https://github.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script.git)
cd FreeBSD-i3wm-Deployment-Script
```

### 3. Make Executable and Run
Grant execute permissions and run the deployment script:

```bash
chmod +x freebsd_i3wm_deployment_script.sh
./freebsd_i3wm_deployment_script.sh
```

Follow the on-screen menu to select your GPU driver type (Intel/AMD, Nvidia, or VirtualBox). Once the provisioning finishes, reboot your machine to load into LightDM:

```bash
reboot
```
