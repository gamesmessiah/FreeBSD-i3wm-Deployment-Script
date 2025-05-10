#! /bin/sh

# Author: Cameron Taylor
# gemini://camerontaylor.uk
# gopher://camerontaylor.uk
# i3wm setup deployment script
# FreeBSD Desktop
# Version 0.1

########################################################################################
#        DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
# Copyright (C) 2004 Sam Hocevar <sam@hocevar.net>
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
########################################################################################

# Install Intel Video Drivers
pkg install -y drm-kmod

# Configure rc.conf
sysrc moused_enable="YES" dbus_enable="YES" hald_enable="YES" ntpd_enable="YES" kld_list="/boot/modules/i915kms.ko" kld_list="i915kms" lightdm_enable="YES"

# Boot-time kernel stuff
setconfig -f /boot/loader.conf kern.vty=vt
sysrc -f /boot/loader.conf fuse_load="YES" snd_driver_load="YES" cuse_load="YES"
setconfig -f /etc/sysctl.conf kern.coredump=0

# Install Software
pkg install -y xorg
pkg install -y i3 
pkg install -y i3status
pkg install -y i3lock
pkg install -y i3-gaps
pkg install -y dmenu
pkg install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
pkg install -y lxappearance
pkg install -y compton compton-conf
pkg install -y picom

# Install Fonts
pkg install font-awesome

# Install Applications
pkg install -y arandr
pkg install -y firefox
pkg install -y chromium
pkg install -y pcmanfm
pkg install -y lxmenu-data
pkg install -y curl
pkg install -y calcurse
pkg install -y sc-im
pkg install -y cmus
pkg install -y nitrogen
pkg install -y gnybc
pkg install -y vim
pkg install -y volumeicon
pkg install -y alsa-utils
pkg install -y remmina
pkg install -y pavucontrol
pkg install -y zip
pkg install -y zathura
pkg install -y eog
# screen brightness brightness
pkg install -y gammy
# install webam
pkg install webcamd
pkg install v4l-utils v4l_compat
