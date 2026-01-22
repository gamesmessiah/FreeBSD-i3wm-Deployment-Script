#! /bin/sh

# Author: Cameron Taylor
# i3wm setup deployment script for FreeBSD
# Version 1.2 - Maximum Reliability Format

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

# 1. INSTALL SOFTWARE (One by one for reliability)
pkg update
pkg install -y drm-kmod
pkg install -y xorg
pkg install -y i3
pkg install -y i3status
pkg install -y i3lock
pkg install -y i3-gaps
pkg install -y dmenu
pkg install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
pkg install -y lxappearance
pkg install -y ant-dracula-theme
pkg install -y picom
pkg install -y automount
pkg install -y font-awesome
pkg install -y arandr
pkg install -y firefox
pkg install -y chromium
pkg install -y pcmanfm
pkg install -y ranger
pkg install -y lxmenu-data
pkg install -y curl
pkg install -y calcurse
pkg install -y sc-im
pkg install -y cmus
pkg install -y nitrogen
pkg install -y gnybc
pkg install -y nano
pkg install -y vim
pkg install -y mpv
pkg install -y volumeicon
pkg install -y alsa-utils
pkg install -y remmina
pkg install -y pavucontrol
pkg install -y zip
pkg install -y zathura
pkg install -y eog
pkg install -y gammy
pkg install -y pwcview
pkg install -y webcamd
pkg install -y v4l-utils v4l_compat

# 2. SYSTEM CONFIGURATION (rc.conf)
echo "Configuring services..."
sysrc dbus_enable="YES"
sysrc ntpd_enable="YES"
sysrc moused_enable="YES"
sysrc lightdm_enable="YES"
sysrc webcamd_enable="YES"
sysrc kld_list="i915kms fusefs cuse"

# 3. BOOT & KERNEL TUNABLES
echo "Updating boot configs..."
grep -q "kern.vty=vt" /boot/loader.conf || echo 'kern.vty=vt' >> /boot/loader.conf
grep -q "fusefs_load=\"YES\"" /boot/loader.conf || echo 'fusefs_load="YES"' >> /boot/loader.conf
sysctl kern.coredump=0
echo "kern.coredump=0" >> /etc/sysctl.conf

# 4. WALLPAPER & LIGHTDM
echo "Setting up wallpaper and greeter..."
mkdir -p /usr/local/share/wallpaper
fetch -o "$WALLPAPER_DEST" "$WALLPAPER_URL"
chmod 644 "$WALLPAPER_DEST"

mkdir -p /usr/local/etc/lightdm/
GREETER_CONF="/usr/local/etc/lightdm/lightdm-gtk-greeter.conf"
# Using printf to write the config file clearly
printf "[greeter]\nbackground=%s\n" "$WALLPAPER_DEST" > "$GREETER_CONF"

# 5. USER PERMISSIONS
echo "Updating group permissions for $TARGET_USER..."
for grp in video wheel webcamd operator; do
  pw groupmod "$grp" -m "$TARGET_USER"
done

# 6. GENERATE .XINITRC
echo "Creating .xinitrc..."
XINITRC="$USER_HOME/.xinitrc"
cat <<EOF > "$XINITRC"
#!/bin/sh
# Start the compositor
picom -f &
# Start i3 within a dbus session
exec ck-launch-session dbus-launch --exit-with-session i3
EOF
chown "$TARGET_USER":"$TARGET_USER" "$XINITRC"
chmod +x "$XINITRC"

echo "-------------------------------------------------------"
echo "Setup Complete! Please reboot your system."
echo "-------------------------------------------------------"