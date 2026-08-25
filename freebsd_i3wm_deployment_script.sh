#!/bin/sh

# Author: Cameron Taylor
# i3wm setup deployment script for FreeBSD
# Version 2.4.0 - Added Arrow Key Navigation to i3 Config

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

# --- GPU SELECTION ---
echo "-------------------------------------------------------"
echo "Select your Graphics Hardware:"
echo "1) Intel or AMD (Modern DRM)"
echo "2) Nvidia (Official Binary Driver)"
echo "3) VirtualBox (Guest Additions)"
echo "-------------------------------------------------------"
read -r GPU_CHOICE

echo "Starting FreeBSD Desktop Provisioning for $TARGET_USER..."

# 1. INSTALL SOFTWARE
pkg update
pkg install -y drm-kmod
pkg install -y xorg
pkg install -y i3
pkg install -y i3status
pkg install -y i3lock-color
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
pkg install -y gnubc
pkg install -y nano
pkg install -y vim
pkg install -y mpv
pkg install -y volumeicon
pkg install -y alsa-utils
pkg install -y remmina
pkg install -y conky
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
pkg install -y emulators/linux_base-c7

# 2. SYSTEM CONFIGURATION & DRIVER LOGIC
sysrc dbus_enable="YES"
sysrc ntpd_enable="YES"
sysrc moused_enable="YES"
sysrc lightdm_enable="YES"
sysrc webcamd_enable="YES"

case $GPU_CHOICE in
    1)
        sysrc kld_list="i915kms fusefs cuse"
        ;;
    2)
        pkg install -y nvidia-driver nvidia-settings nvidia-xconfig
        sysrc kld_list="nvidia-modeset fusefs cuse"
        nvidia-xconfig
        ;;
    3)
        pkg install -y virtualbox-ose-additions
        sysrc vboxguest_enable="YES"
        sysrc vboxservice_enable="YES"
        sysrc kld_list="vboxguest fusefs cuse"
        ;;
    *)
        echo "Invalid choice, defaulting to Intel/AMD drivers."
        sysrc kld_list="i915kms fusefs cuse"
        ;;
esac

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
mkdir -p "$USER_HOME/.config/i3"
mkdir -p "$USER_HOME/.config/picom"
mkdir -p "$USER_HOME/.config/gtk-3.0"

# --- WORKING CONKY CONFIG (~/.conkyrc) ---
cat <<'EOF' > "$USER_HOME/.conkyrc"
conky.config = {
    background = false,
    cpu_avg_samples = 2,
    no_buffers = true,
    out_to_console = true,
    out_to_x = false,
    own_window = false,
    update_interval = 1,
    short_units = true,
    total_run_times = 0,
    text_buffer_size = 2048
};

conky.text = [[
[
    {"full_text": " ${exec hostname }", "color":"\#f1fa8c"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " CPU: ${cpu cpu0}% ", "color":"\#ff5555"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " RAM: $mem", "color":"\#ffb86c"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " WiFi: ${addr wlan0}", "color":"\#50fa7b"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " Ethernet IP: ${addr em0}", "color":"\#8BE9FD"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " UP: ${uptime_short} ", "color":"\#bd93f9"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " ${time %H:%M}", "color":"\#FF79C6"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " ${time %A %d-%m-%Y}", "color":"\#8BE9FD"},
    {"full_text": " | ", "color":"\#f8f8f2"},
    {"full_text": " Battery: ${execi 60 sysctl -n hw.acpi.battery.life}% ", "color":"\#50fa7b"}
],
]]
EOF

# --- CONKY i3BAR WRAPPER SCRIPT ---
CONKY_BAR_SCRIPT="$USER_HOME/.config/i3/conky-i3bar.sh"
cat <<'EOF' > "$CONKY_BAR_SCRIPT"
#!/bin/sh

# Send the header so that i3bar knows we want to use JSON:
echo '{"version":1}'

# Begin the endless array.
echo '['

# We send an empty first array of blocks to make the loop simpler:
echo '[],'

# Now send blocks with information forever:
exec conky -c ~/.conkyrc
EOF
chmod +x "$CONKY_BAR_SCRIPT"

# --- .Xresources ---
cat <<'EOF' > "$USER_HOME/.Xresources"
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

# --- PICOM CONFIG ---
cat <<'EOF' > "$USER_HOME/.config/picom/picom.conf"
# OPACITY
inactive-opacity = 0.8;
frame-opacity = 0.7;

# Let inactive opacity set by -i override the '_NET_WM_WINDOW_OPACITY' values of windows.
inactive-opacity-override = true;

# ROUNDED CORNERS
corner-radius = 0

# BLURRING
blur:
{
  method = "dual_kawase";
  size = 10;
  strength = 3;
};

# semi-transparent
blur-background = true
blur-background-fixed = true

# SHADOWS
shadow = true;
shadow-radius = 1; #blur radius
shadow-opacity = .1

shadow-offset-x = 0;
shadow-offset-y = 0;

# FADING
fading = true;

fade-in-step = 0.03;
fade-out-step = 0.03;
fade-delta = 3

# OTHER SETTINGS
backend = "egl";

dithered-present = false;
vsync = true;

mark-wmwin-focused = true;
mark-ovredir-focused = true;

detect-rounded-corners = false
detect-client-opacity = true;
use-ewmh-active-win = true
detect-transient = true;
use-damage = true;
log-level = "warn";

wintypes:
{
  tooltip = { fade = true; shadow = true; opacity = 0.5; focus = true; full-shadow = false; };
  dock = { shadow = false; clip-shadow-above = true; }
  dnd = { shadow = false; }
  popup_menu = { opacity = 0.7; }
  dropdown_menu = { opacity = 0.7; }
  normal = { opacity = 1;}
};
EOF

# --- i3 CONFIG ---
cat <<'EOF' > "$USER_HOME/.config/i3/config"
set $mod Mod4
font pango:FontAwesome 8
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
exec --no-startup-id nm-applet
set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status
floating_modifier $mod
bindsym $mod+Return exec uxterm
bindsym $mod+Shift+Return exec terminator
bindsym $mod+Shift+q kill

bindsym $mod+d exec dmenu_run -nb '#282A36' -nf '#F8F8F2' -sb '#6272A4' -sf '#F8F8F2' -fn 'monospace-10' -p 'dmenu'

bindsym $mod+Shift+d exec rofi -show run 
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

# change focus (VIM keys)
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# change focus (Cursor keys)
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# move focused window (VIM keys)
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# move focused window (Cursor keys)
bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

bindsym $mod+i split h 
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
mode "resize" {
    bindsym h resize shrink width 10 px or 10 ppt
    bindsym j resize grow height 10 px or 10 ppt
    bindsym k resize shrink height 10 px or 10 ppt
    bindsym l resize grow width 10 px or 10 ppt
    bindsym Return mode "default"
    bindsym Escape mode "default"
}
bindsym $mod+r mode "resize"
bindsym $mod+F1 exec chrome
bindsym $mod+F2 exec uxterm -e 'calcurse'
bindsym $mod+F3 exec pcmanfm
bindsym $mod+F5 exec uxterm -e 'sc-im'
bindsym $mod+F6 exec zathura
bindsym $mod+F8 exec uxterm -e 'cmus'
bindsym $mod+F12 exec i3lock --color=282a36 --inside-color=44475a80 --insidever-color=bd93f980 --insidewrong-color=ff555580 --ring-color=bd93f9 --ringver-color=8be9fd --ringwrong-color=ff5555 --keyhl-color=50fa7b --bshl-color=ffb86c --separator-color=6272a4 --verif-color=f8f8f2 --wrong-color=f8f8f2 --time-color=f8f8f2 --date-color=6272a4 --line-uses-ring --clock --indicator
bindsym $mod+shift+a exec uxterm -title calculator 'bc'

exec --no-startup-id setxkbmap gb
exec --no-startup-id nitrogen --restore; sleep 1; picom -b --config ~/.config/picom/picom.conf 
exec --no-startup-id networkmgr
exec --no-startup-id volumeicon

for_window [class="Nitrogen"] floating enable sticky enable border normal
for_window [title="calculator"] floating enable

bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9
bindsym $mod+0 workspace 10

bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5

bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'Exit i3?' -b 'Yes' 'i3-msg exit'"

bar {
    status_command ~/.config/i3/conky-i3bar.sh
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
cat <<'EOF' > "$USER_HOME/.config/gtk-3.0/settings.ini"
[Settings]
gtk-theme-name=Ant-Dracula
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
EOF

cat <<'EOF' > "$USER_HOME/.gtkrc-2.0"
include "/usr/local/share/themes/Ant-Dracula/gtk-2.0/gtkrc"
gtk-theme-name="Ant-Dracula"
gtk-font-name="Sans 10"
EOF

# 7. GENERATE .XINITRC
XINITRC="$USER_HOME/.xinitrc"
cat <<'EOF' > "$XINITRC"
#!/bin/sh
export GTK_THEME=Ant-Dracula
xrdb -merge $HOME/.Xresources
exec ck-launch-session dbus-launch --exit-with-session i3
EOF

# Ownership maintenance
chown -R "$TARGET_USER":"$TARGET_USER" "$USER_HOME/.config" "$USER_HOME/.conkyrc" "$USER_HOME/.Xresources" "$USER_HOME/.gtkrc-2.0" "$XINITRC"
chmod +x "$XINITRC"

echo "-------------------------------------------------------"
echo "Setup Complete! Added cursor key bindings to i3 config."
echo "Press Mod+Shift+R to reload i3."
echo "-------------------------------------------------------"
