#!/usr/bin/bash
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
    "vlc"
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
)
dnf5 groupremove "KDE Plasma Workspaces" 
dnf5 copr enable --assumeyes solopasha/hyprland
dnf5 copr enable --assumeyes peterwu/rendezvous
dnf5 copr enable --assumeyes wef/cliphist
dnf5 copr enable --assumeyes tofik/nwg-shell
dnf5 copr enable --assumeyes erikreider/SwayNotificationCenter
dnf5 install --assumeyes --skip-unavailable $general $hyprland $apps $tools
