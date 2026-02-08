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
    "rofi-wayland"
    "nwg-look"
    "pavucontrol"
    "neovim"
    "blueman"
    "qt6ct"
    "nautilus"
)

tools=(
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
    "python3-pip"
    "otf-font-awesome"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "swww"
)
# install yay
useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers # Allow the builduser passwordless sudo
sudo -u builduser bash -c 'pacman --noconfirm -S base-devel git
git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si' # Clone and build a package
userdel -fr builduser
yay -S --noconfirm $general $hyprland $apps $tools
