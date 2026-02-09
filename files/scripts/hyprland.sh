#!/usr/bin/env bash

# Tell this script to exit if there are any errors.
# You should have this in every custom script, to ensure that your completed
# builds actually ran successfully without any errors!
set -oue pipefail
general=(
    # Hyprland
    "hyprland"
    "libnotify"
    "qt5-wayland"
    "qt6-wayland"
    "uwsm"
    "python-pip"
    "python-gobject"
    "python-screeninfo"
    "nm-connection-editor"
    "network-manager-applet"
    "imagemagick"
    "polkit-gnome"
    "hyprshade"
    "grimblast-git"
    "pacman-contrib"
    "loupe"
    # Apps
    "waypaper"
    "swaync"
    # Tools
    "eza"
    "python-pywalfox"
    "tesseract-data-eng"
    # Fonts
    "otf-font-awesome"
    "ttf-firacode-nerd"
    "ttf-jetbrains-mono-nerd"
    "tty-clock"
    # Display Manager
    "swww"
    "qt6-svg"
    "qt6-virtualkeyboard"
    "qt6-multimedia-ffmpeg"
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
    "gnome-themes-extra"
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
    "nwg-displays"
    "rofi"
    "nwg-look"
    "pavucontrol"
    "neovim"
    "blueman"
    "qt6ct"
    "nautilus"
)

tool=(
    "xdg-user-dirs"
    "xdg-desktop-portal-gtk"
    "figlet"
    "fastfetch"
    "htop"
    "xclip"
    "zsh"
    "fzf"
    "brightnessctl"
    "tumbler"
    "slurp"
    "cliphist"
    "gvfs"
    "grim"
    "breeze"
    "tesseract"
    "wl-clipboard"
)
# install yay
useradd builduser -m # Create the builduser
passwd -d builduser # Delete the buildusers password
printf 'builduser ALL=(ALL) ALL\n' | tee -a /etc/sudoers # Allow the builduser passwordless sudo
pacman --noconfirm -S base-devel git
sudo -u builduser bash -c 'git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
cd /tmp/yay-bin
makepkg -si --noconfirm' # Clone and build a package
userdel builduser
#pacman -S --needed --noconfirm "${general[@]}" "${hyprland[@]}" "${apps[@]}" "${tool[@]}"
yay -S --noconfirm "${general[@]}" "${hyprland[@]}" "${apps[@]}" "${tool[@]}"
