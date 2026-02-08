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
)

pacman -S --noconfirm $general $hyprland $apps $tools
