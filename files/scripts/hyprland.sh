#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail
general=(
    "wget"
    "curl"
    "git"
    "rsync"
    "unzip"
    "tar"
    "jq"
    "flatpak"
    "vim"
    "inotify-tools"
)

hyprland=(
    "hyprpaper"
    "hyprlock"
    "hypridle"
    "hyprpicker"
    "xdg-desktop-portal-hyprland"
)

apps=(
    "kitty"
    "wlogout"
    "nwg-dock-hyprland"
    "waybar"
    "rofi"
    "nwg-look"
    "pavucontrol"
    "neovim"
    "blueman"
    "qt6ct"
    "nautilus"
    "rofi-wayland"
)

tool=(
    "xdg-user-dirs"    
    "xdg-desktop-portal-gtk"
    "polkit-gnome"
    "figlet"
    "fastfetch"
    "htop"
    "xclip"
    "fzf"
    "brightnessctl"
    "tumbler"
    "slurp"
    "cliphist"
    "breeze"
    "btop"
    "python-pip"
    "otf-font-awesome"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "swww"
    "bolt" 
    "bc"
    "cliphist"
    "curl" 
    "grim" 
    "gvfs" 
    "gvfs-mtp"
    "hyprpolkitagent"
    "imagemagick"
    "inxi"
    "jq"
    "kvantum"
    "network-manager-applet" 
    "pamixer"
    "pavucontrol"
    "playerctl"
    "python-requests"
    "python-pyquery"
    "qt6-svg"
    "slurp" 
    "swappy" 
    "swaync" 
    "swww"
    "unzip" # needed later
    "wallust" 
    "wl-clipboard"
    "wlogout"
    "xdg-user-dirs"
    "xdg-utils"
    "yad"
)
# install yay
useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers # Allow the builduser passwordless sudo
pacman --noconfirm -S base-devel git
sudo -u builduser bash -c 'git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si --noconfirm' # Clone and build a package
userdel -fr builduser
pacman -S --needed --noconfirm "${general[@]}" "${hyprland[@]}" "${apps[@]}" "${tool[@]}"
yay -S --noconfirm "${general[@]}" "${hyprland[@]}" "${apps[@]}" "${tool[@]}"
