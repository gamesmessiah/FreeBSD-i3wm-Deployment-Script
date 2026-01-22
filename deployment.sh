#! /bin/sh

# Author: Cameron Taylor
# i3wm setup deployment script for FreeBSD
# Version 1.1 - Robust Package Installation

# --- DYNAMIC USER DETECTION ---
if [ "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER=$(logname)
fi

USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
WALLPAPER_URL="https://w.wallhaven.cc/full/xe/wallhaven-xez3dz.png"
WALLPAPER_DEST="/usr/local/share/wallpaper/default-wallpaper.png"

# --- ROOT CHECK ---
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Starting FreeBSD Desktop Provisioning for $TARGET_USER..."

# 1. DEFINE PACKAGES (More robust list format)
PKGS="drm-kmod xorg i3 i3status i3lock i3-gaps dmenu \
lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
lxappearance picom automount font-awesome \
arandr firefox chromium pcmanfm lxmenu-data \
curl calcurse sc-im cmus nitrogen vim mpv conky \
volumeicon alsa-utils remmina pavucontrol \
zip zathura eog gammy pwcview webcamd \
v4l-utils v4l_compat ant-dracula-theme"

# 2. INSTALL SOFTWARE
echo "Updating pkg and installing software..."
pkg update
pkg install -y $PKGS

# 3. SYSTEM CONFIGURATION (rc.conf)
echo "Configuring services..."
sysrc dbus_enable="YES"
sysrc ntpd_enable="YES"
sysrc moused_enable="YES"
sysrc lightdm_enable="YES"
sysrc webcamd_enable="YES"
sysrc kld_list="i915kms fusefs cuse"

# 4. BOOT & KERNEL TUNABLES
echo "Updating boot configs..."
# We use grep to avoid double-entry if script is run twice
grep -q "kern.vty=vt" /boot/loader.conf || echo 'kern.vty=vt' >> /boot/loader.conf
grep -q "fusefs_load=\"YES\"" /boot/loader.conf || echo 'fusefs_load="YES"' >> /boot/loader.conf
sysctl kern.coredump=0
echo "kern.coredump=0" >> /etc/sysctl.conf

# 5. WALLPAPER & LIGHTDM
echo "Setting up wallpaper and greeter..."
mkdir -p /usr/local/share/wallpaper
fetch -o "$WALLPAPER_DEST" "$WALLPAPER_URL"
chmod 644 "$WALLPAPER_DEST"

mkdir -p /usr/local/etc/lightdm/
GREETER_CONF="/usr/local/etc/lightdm/lightdm-gtk-greeter.conf"
printf "[greeter]\nbackground=%s\n" "$WALLPAPER_DEST" > "$GREETER_CONF"

# 6. USER PERMISSIONS
echo "Updating group permissions..."
for grp in video wheel webcamd operator; do
  pw groupmod "$grp" -m "$TARGET_USER"
done

# 7. GENERATE .XINITRC
echo "Creating .xinitrc..."
XINITRC="$USER_HOME/.xinitrc"
cat <<EOF > "$XINITRC"
#!/bin/sh
picom -f &
exec ck-launch-session dbus-launch --exit-with-session i3
EOF
chown "$TARGET_USER":"$TARGET_USER" "$XINITRC"
chmod +x "$XINITRC"

echo "-------------------------------------------------------"
echo "Setup Complete! Please reboot your system."
echo "-------------------------------------------------------"