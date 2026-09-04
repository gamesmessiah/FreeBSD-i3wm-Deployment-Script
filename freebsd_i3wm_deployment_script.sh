# FreeBSD i3wm Deployment Script

This script automates the transformation of a fresh FreeBSD installation into a professional, Dracula-themed **i3wm** (Gaps) desktop environment. It handles everything from driver installation to aesthetic configurations like blur, transparency, and system-wide color palettes.

## The Goal
To go from a "blank slate" FreeBSD terminal to a fully riced productivity machine in one command.

![alt text](https://raw.githubusercontent.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script/refs/heads/main/desktop.png)

## Features
* **Graphics:** Automated `drm-kmod` setup for Intel/AMD graphics.
* **WM & Aesthetics:** `i3-gaps` with `picom` (dual-kawase blur) and the **Ant-Dracula** theme.
* **Consistency:** Synced Dracula colors across `i3`, `LightDM`, `GTK 3.0`, and `.Xresources`.
* **Hardware Support:** Configures `webcamd`, `FUSE` for mounting, and `OSS/ALSA` audio.
* **UK Localization:** Defaults to `gb` keyboard layout (easily adjustable).

## Included Software List

| Category | Packages |
| :--- | :--- |
| **Window Manager** | `i3-gaps`, `i3status`, `i3lock`, `dmenu`, `rofi` |
| **Login Manager** | `lightdm`, `lightdm-gtk-greeter`, `ant-dracula-theme` |
| **Terminal / CLI** | `uxterm`, `terminator`, `vim`, `nano`, `ranger`, `curl` |
| **Productivity** | `firefox`, `chromium`, `pcmanfm`, `calcurse`, `sc-im`, `zathura` |
| **Multimedia** | `cmus`, `mpv`, `pavucontrol`, `alsa-utils`, `volumeicon`, `eog` |
| **Utilities** | `nitrogen`, `flameshot`, `arandr`, `gammy`, `webcamd`, `zip` |

---

## How to Run the Script

### 1. Prerequisite
Ensure you have a fresh FreeBSD install and a user account added to the `wheel` group.

### 2. Install Git and Clone
Log in as your user, switch to root, and grab the repository:
```bash
su -
pkg update && pkg install -y git
git clone https://github.com/gamesmessiah/FreeBSD-i3wm-Deployment-Script.git
cd FreeBSD-i3wm-Deployment-Script
