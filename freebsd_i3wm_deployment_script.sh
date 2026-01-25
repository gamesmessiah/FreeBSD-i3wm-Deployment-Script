#! /bin/sh

# Author: Cameron Taylor
# i3wm setup deployment script for FreeBSD
# Version 1.4 - VirtualBox Compatibility & GTK Fixes

# --- DYNAMIC USER DETECTION ---
if [ "$SUDO_USER" ]; then
    TARGET_USER="$SUDO_USER"
else
    TARGET_USER=$(logname)
fi

USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
WALLPAPER_URL="https://w.wallhaven.cc/full/l8/wallhaven-l8g6dl.png"
WALLPAPER_DEST="/usr/local/share/wallpaper/default-wallpaper.png"

# --- ROOT CHECK ---
if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Starting FreeBSD Desktop Provisioning for $TARGET_USER..."

# 1. INSTALL SOFTWARE (Line-by-line for reliability)
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
pkg install -y networkmgr
pkg install -y terminator

# 2. SYSTEM CONFIGURATION
sysrc dbus_enable="YES"
sysrc ntpd_enable="YES"
sysrc moused_enable="YES"
sysrc lightdm_enable="YES"
sysrc webcamd_enable="YES"
# Note: i915kms is for Intel. For VirtualBox testing, you might need vboxguest_enable="YES"
sysrc kld_list="i915kms fusefs cuse"

# 3. BOOT & KERNEL TUNABLES
grep -q "kern.vty=vt" /boot/loader.conf || echo 'kern.vty=vt' >> /boot/loader.conf
grep -q "fusefs_load=\"YES\"" /boot/loader.conf || echo 'fusefs_load="YES"' >> /boot/loader.conf
sysctl kern.coredump=0
echo "kern.coredump=0" >> /etc/sysctl.conf

# 4. WALLPAPER & LIGHTDM
mkdir -p /usr/local/share/wallpaper
fetch -o "$WALLPAPER_DEST" "$WALLPAPER_URL"
chmod 644 "$WALLPAPER_DEST"

mkdir -p /usr/local/etc/lightdm/
GREETER_CONF="/usr/local/etc/lightdm/lightdm-gtk-greeter.conf"
printf "[greeter]\nbackground=%s\ntheme-name=Ant-Dracula\n" "$WALLPAPER_DEST" > "$GREETER_CONF"

# 5. USER PERMISSIONS
for grp in video wheel webcamd operator; do
  pw groupmod "$grp" -m "$TARGET_USER"
done

# 6. CONFIGURATION DEPLOYMENT
echo "Deploying i3, Picom, GTK, and Xresources..."
mkdir -p "$USER_HOME/.config/i3"
mkdir -p "$USER_HOME/.config/picom"
mkdir -p "$USER_HOME/.config/gtk-3.0"

# --- .Xresources (Dracula Palette) ---
cat <<EOF > "$USER_HOME/.Xresources"
*.foreground: #F8F8F2
*.background: #282A36
*.color0:      #000000
*.color8:      #4D4D4D
*.color1:      #FF5555
*.color9:      #FF6E67
*.color2:      #50FA7B
*.color10:     #5AF78E
*.color3:      #F1FA8C
*.color11:     #F4F99D
*.color4:      #BD93F9
*.color12:     #CAA9FA
*.color5:      #FF79C6
*.color13:     #FF92D0
*.color6:      #8BE9FD
*.color14:     #9AEDFE
*.color7:      #BFBFBF
*.color15:     #E6E6E6
EOF

# --- PICOM CONFIG (Adjusted for VirtualBox Compatibility) ---
cat <<EOF > "$USER_HOME/.config/picom/picom.conf"
inactive-opacity = 0.8;
frame-opacity = 0.7;
inactive-opacity-override = true;
corner-radius = 0
# VirtualBox fix: switched to xrender. Use "glx" or "egl" on real hardware.
backend = "xrender"; 
vsync = true;
fading = true;
fade-in-step = 0.05;
fade-out-step = 0.05;
shadow = true;
shadow-radius = 7;
shadow-offset-x = -7;
shadow-offset-y = -7;
EOF

# --- i3 CONFIG ---
cat <<EOF > "$USER_HOME/.config/i3/config"
set \$mod Mod4
font pango:FontAwesome 8
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
exec --no-startup-id nm-applet
set \$refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && \$refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && \$refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && \$refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && \$refresh_i3status
floating_modifier \$mod
bindsym \$mod+Return exec uxterm
bindsym \$mod+Shift+Return exec terminator
bindsym \$mod+Shift+q kill
bindsym \$mod+d exec dmenu_run -nb '#282A36' -nf '#F8F8F2' -sb '#6272A4' -sf '#F8F8F2' -fn 'monospace-10' -p 'dmenu'
bindsym \$mod+Shift+d exec rofi -show run 
bindsym \$mod+Shift+space floating toggle
bindsym \$mod+space focus mode_toggle
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right
bindsym \$mod+Shift+h move left
bindsym \$mod+Shift+j move down
bindsym \$mod+Shift+k move up
bindsym \$mod+Shift+l move right
bindsym \$mod+i split h 
bindsym \$mod+v split v
bindsym \$mod+f fullscreen toggle
bindsym \$mod+s layout stacking
bindsym \$mod+w layout tabbed
bindsym \$mod+e layout toggle split
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym \$mod+r mode "resize"
bindsym \$mod+F1 exec chrome
bindsym \$mod+F2 exec uxterm -e 'calcurse'
bindsym \$mod+F3 exec pcmanfm
bindsym \$mod+F4 exec uxterm -e 'ranger'
bindsym \$mod+F5 exec uxterm -e 'sc-im'
bindsym \$mod+F6 exec zathura
bindsym \$mod+F8 exec uxterm -e 'cmus'
bindsym \$mod+F11 exec flameshot
bindsym \$mod+shift+a exec uxterm -title calculator 'bc'
exec --no-startup-id setxkbmap gb
exec --no-startup-id nitrogen --restore; sleep 1; picom -b --config ~/.config/picom/picom.conf 
exec --no-startup-id networkmgr
exec --no-startup-id volumeicon
for_window [class="Nitrogen"] floating enable sticky enable border normal
for_window [title="calculator"] floating enable
bindsym \$mod+1 workspace 1
bindsym \$mod+2 workspace 2
bindsym \$mod+3 workspace 3
bindsym \$mod+4 workspace 4
bindsym \$mod+5 workspace 5
bindsym \$mod+6 workspace 6
bindsym \$mod+7 workspace 7
bindsym \$mod+8 workspace 8
bindsym \$mod+9 workspace 9
bindsym \$mod+0 workspace 10
bindsym \$mod+Shift+1 move container to workspace 1
bindsym \$mod+Shift+2 move container to workspace 2
bindsym \$mod+Shift+3 move container to workspace 3
bindsym \$mod+Shift+4 move container to workspace 4
bindsym \$mod+Shift+5 move container to workspace 5
bindsym \$mod+Shift+c reload
bindsym \$mod+Shift+r restart
bindsym \$mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"
bar {
    status_command i3status
    position bottom
    font xft:FontAwesome 10.5
    strip_workspace_numbers yes
    colors {
        background #282A36
        statusline #F8F8F2
        focused_workspace  #F8F8F2 #6272A4 #F8F8F2
        active_workspace   #F8F8F2 #282A36 #F8F8F2
        inactive_workspace #F8F8F2 #282A36 #888888
    }
}
client.focused          #44475A #44475A #F8F8F2 #F8F8F2   #44475A
client.focused_inactive #333333 #282A36 #F8F8F2 #282A36   #282A36
client.unfocused        #333333 #282A36 #888888 #292D2E   #222222
gaps inner 10
gaps outer -4
smart_gaps on
smart_borders on
EOF

# --- GTK 3.0 & 2.0 SETTINGS ---
cat <<EOF > "$USER_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Ant-Dracula
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
EOF

cat <<EOF > "$USER_HOME/.gtkrc-2.0"
include "/usr/local/share/themes/Ant-Dracula/gtk-2.0/gtkrc"
gtk-theme-name="Ant-Dracula"
gtk-font-name="Sans 10"
EOF

# 7. GENERATE .XINITRC
XINITRC="$USER_HOME/.xinitrc"
cat <<EOF > "$XINITRC"
#!/bin/sh
export GTK_THEME=Ant-Dracula
xrdb -merge \$HOME/.Xresources
exec ck-launch-session dbus-launch --exit-with-session i3
EOF

# Ownership maintenance
chown -R "$TARGET_USER":"$TARGET_USER" "$USER_HOME/.config" "$USER_HOME/.Xresources" "$USER_HOME/.gtkrc-2.0" "$XINITRC"
chmod +x "$XINITRC"

echo "-------------------------------------------------------"
echo "Setup Complete! Theme and Picom (Vbox mode) deployed."
echo "-------------------------------------------------------"
