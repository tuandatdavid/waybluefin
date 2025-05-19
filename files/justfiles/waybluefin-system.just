# vim: set ft=make :
########################
### bluefin-system.just
########################
## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

# Run a one minute system benchmark
[group('System')]
benchmark:
    #!/usr/bin/env bash
    echo 'Running a 1 minute benchmark ...'
    trap popd EXIT
    pushd $(mktemp -d)
    stress-ng --matrix 0 -t 1m --times

# Configure Bluefin-CLI Terminal Experience with Brew
[group('System')]
bluefin-cli:
    @/usr/libexec/ublue-bling
# Ptyxis terminal transparency
[group('System')]
ptyxis-transparency opacity="0.95":
    #!/usr/bin/env bash
    set -euxo pipefail
    if [[ -n "$(echo "{{ opacity }}" | grep -v '^[.0-9]*$')" ]]; then
        printf "Value must be numeric: %s.\n" "{{ opacity }}"
    elif [[ $(echo "0<{{ opacity }} && 1>={{ opacity }}" | bc -q) -eq 1 ]]; then
        raw="$(gsettings get org.gnome.Ptyxis profile-uuids)"
        uuids="$(sed -En 's|[^0-9a-z]*||g; s|([0-9a-z]{32})|\1\n|gp' <<<${raw})"
        for i in ${uuids}; do
            location="org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/${i}/"
            gsettings set "${location}" opacity "{{ opacity }}"; done
        printf "Ptyxis opacity is now %s.\n" "{{ opacity }}"
    else
        printf "Value must be greater than 0 and less than or equal to 1: %s.\n" "{{ opacity }}"
    fi


# Toggle tailscale
[group('System')]
toggle-tailscale:
    #!/bin/bash
    set -euo pipefail
    source /usr/lib/ujust/ujust.sh
    source /usr/lib/os-release

    TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"

    if [ "$TAILSCALED_STATUS" == "enabled" ] || [ "$TAILSCALED_STATUS" == "disabled" ]; then
        TAILSCALED="Installed"
    else
        TAILSCALED="Not Found"
        echo "${b}${red}Unable to enable or disable Tailscale.${n}"
        echo "The tailscaled service must be present and either enabled or disabled to run this script."
        echo "tailscaled service status: $TAILSCALED_STATUS"
    fi


    if [ "$TAILSCALED" == "Installed" ]; then
        echo "Enable or disable Tailscale?"
        TS_OPTION=$(Choose Enable Disable)

        # gnome-extensions is only available on Bluefin (Gnome)
        if [ "$VARIANT" == "Silverblue" ]; then
            TAILSCALE_QS="$(gnome-extensions list | grep -q "tailscale@joaophi.github.com"; echo $?)"
            if [ "$TAILSCALE_QS" == 0 ]; then
                TAILSCALE_QS="Installed"
            else
                echo "The Tailscale QS extension for Gnome is not installed. Please install it and then run this script again."
            fi

            if [[ "${TS_OPTION,,}" =~ ^enable ]]; then
                gnome-extensions enable tailscale@joaophi.github.com
            elif [[ "${TS_OPTION,,}" =~ ^disable ]]; then
                gnome-extensions disable tailscale@joaophi.github.com
            fi
        fi

        if [ "$TS_OPTION" = "Enable" ]; then
            systemctl enable --now tailscaled
            TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"
            if [ "$TAILSCALED_STATUS" == "enabled" ]; then
                echo "${b}${green}Tailscale is enabled.${n}"
                echo "If this is your first time using Tailscale, setup is necessary."
                echo "Refer to Tailscale's documentation at https://tailscale.com/kb/1346/start."
            fi
        elif [ "$TS_OPTION" = "Disable" ]; then
            systemctl disable --now tailscaled
            TAILSCALED_STATUS="$(systemctl is-enabled tailscaled || true )"
            if [ "$TAILSCALED_STATUS" == "disabled" ]; then
                echo "${b}${red}Tailscale is disabled.${n}"
            fi
        fi
    fi
install-dots:
    #!/bin/bash
    # /* ---- 💫 https://github.com/tuandatdavid 💫 ---- */  #
    # For downloading dots from releases

    # Set some colors for output messages
    OK="$(tput setaf 2)[OK]$(tput sgr0)"
    ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
    NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
    INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
    WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
    CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
    MAGENTA="$(tput setaf 5)"
    ORANGE="$(tput setaf 214)"
    WARNING="$(tput setaf 1)"
    YELLOW="$(tput setaf 3)"
    GREEN="$(tput setaf 2)"
    BLUE="$(tput setaf 4)"
    SKY_BLUE="$(tput setaf 6)"
    RESET="$(tput sgr0)"

    # Check /etc/os-release to see if this is an Ubuntu or Debian based distro
    if grep -iq '^\(ID_LIKE\|ID\)=.*\(debian\|ubuntu\)' /etc/os-release >/dev/null 2>&1; then
    printf "\n%.0s" {1..1}
    print_color $WARNING "
    █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
        KOOL DOTS version INCOMPATIBLE
    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

    Debian / Ubuntu detected. Refer to Hyprland-Dots README
    For instruction on how to update your KooL Hyprland Dots

    exiting ....
    "
    printf "\n%.0s" {1..3}
    exit 1
    fi


    printf "\n%.0s" {1..1}  
    echo -e "\e[35m
    ╦╔═┌─┐┌─┐╦    ╔╦╗┌─┐┌┬┐┌─┐
    ╠╩╗│ ││ │║     ║║│ │ │ └─┐ 2025
    ╩ ╩└─┘└─┘╩═╝  ═╩╝└─┘ ┴ └─┘ release.sh
    \e[0m"
    printf "\n%.0s" {1..1}  

    echo "${WARNING}A T T E N T I O N !${RESET}"
    echo "${SKY_BLUE}This script is meant to download from the "RELEASES" on the KooL Hyprland-Dots${RESET}"
    echo "${YELLOW}Kindly note that the RELEASES is one version older that from main${RESET}"
    printf "\n%.0s" {1..1}
    echo "${MAGENTA}If you want to get the latest, kindly ran the ${SKY_BLUE}copy.sh${RESET} ${MAGENTA}instead${RESET}"
    printf "\n%.0s" {1..1}
    read -p "${CAT} - Would you like to proceed and install from releases? (y/n): ${RESET}" proceed

    if [ "$proceed" != "y" ]; then
    printf "\n%.0s" {1..1}
    echo "${INFO} Installation aborted. ${SKY_BLUE}No changes in your system.${RESET} ${YELLOW}Goodbye!${RESET}"
    printf "\n%.0s" {1..1}
    exit 1
    fi

    printf "${NOTE} Downloading / Checking for existing Hyprland-Dots.tar.gz...\n"

    # Check if Hyprland-Dots.tar.gz exists
    if [ -f Hyprland-Dots.tar.gz ]; then
    printf "${NOTE} Hyprland-Dots.tar.gz found.\n"

    # Get the version from the existing tarball filename
    existing_version=$(echo Hyprland-Dots.tar.gz | grep -oP 'v\d+\.\d+\.\d+' | sed 's/v//')

    # Fetch the tag_name for the latest release using the GitHub API
    latest_version=$(curl -s https://api.github.com/repos/tuandatdavid/Hyprland-Dots/releases/latest | grep "tag_name" | cut -d '"' -f 4 | sed 's/v//')

    # Check if versions match
    if [ "$existing_version" = "$latest_version" ]; then
    echo -e "${OK} Hyprland-Dots.tar.gz is up-to-date with the latest release ($latest_version)."

    # Sleep for 10 seconds before exiting
    printf "${NOTE} No update found. Sleeping for 10 seconds...\n"
    sleep 10
    exit 0
    else
    echo -e "${WARN} Hyprland-Dots.tar.gz is outdated (Existing version: $existing_version, Latest version: $latest_version)."
    read -p "Do you want to upgrade to the latest version? (y/n): " upgrade_choice
    if [ "$upgrade_choice" = "y" ]; then
    echo -e "${NOTE} Proceeding to download the latest release."

    # Delete existing directories starting with tuandatdavid-Hyprland-Dots
    find . -type d -name 'tuandatdavid-Hyprland-Dots*' -exec rm -rf {} +
    rm -f Hyprland-Dots.tar.gz
    printf "${WARN} Removed existing Hyprland-Dots.tar.gz.\n"
    else
    echo -e "${NOTE} User chose not to upgrade. Exiting..."
    exit 0
    fi
    fi
    fi

    printf "${NOTE} Downloading the latest Hyprland source code release...\n"

    # Fetch the tag name for the latest release using the GitHub API
    latest_tag=$(curl -s https://api.github.com/repos/tuandatdavid/Hyprland-Dots/releases/latest | grep "tag_name" | cut -d '"' -f 4)

    # Check if the tag is obtained successfully
    if [ -z "$latest_tag" ]; then
    echo -e "${ERROR} Unable to fetch the latest tag information."
    exit 1
    fi

    # Fetch the tarball URL for the latest release using the GitHub API
    latest_tarball_url=$(curl -s https://api.github.com/repos/tuandatdavid/Hyprland-Dots/releases/latest | grep "tarball_url" | cut -d '"' -f 4)

    # Check if the URL is obtained successfully
    if [ -z "$latest_tarball_url" ]; then
    echo -e "${ERROR} Unable to fetch the tarball URL for the latest release."
    exit 1
    fi

    # Get the filename from the URL and include the tag name in the file name
    file_name="Hyprland-Dots-${latest_tag}.tar.gz"

    # Download the latest release source code tarball to the current directory
    if curl -L "$latest_tarball_url" -o "$file_name"; then
    # Extract the contents of the tarball
    tar -xzf "$file_name" || exit 1

    # delete existing Hyprland-Dots
    rm -rf tuandatdavid-Hyprland-Dots

    # Identify the extracted directory
    extracted_directory=$(tar -tf "$file_name" | grep -o '^[^/]\+' | uniq)

    # Rename the extracted directory to tuandatdavid-Hyprland-Dots
    mv "$extracted_directory" tuandatdavid-Hyprland-Dots || exit 1

    cd "tuandatdavid-Hyprland-Dots" || exit 1

    # Set execute permission for copy.sh and execute it
    chmod +x copy.sh
    ./copy.sh 2>&1 | tee -a "../install-$(date +'%d-%H%M%S')_dots.log"

    echo -e "${OK} Latest source code release downloaded, extracted, and processed successfully. You should also run ujust install-gtk-theme and ujust install-fonts."
    else
    echo -e "${ERROR} Failed to download the latest source code release."
    exit 1
    fi
install-spicetify:
    #!/bin/bash

    # Spice Up Your Spotify: A Beginner's Guide to Installing Spicetify on Arch Linux (Flatpak Edition)

    # Function to print in purplish pink (custom color code)
    pinkEcho() {
        echo -e "\033[38;5;199m$1\033[0m"
    }

    pinkEcho "Let's get started!"

    # 2. Install Spicetify
    pinkEcho "Installing Spicetify..."
    curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.sh | sh

    # 3. Find Spotify's Flatpak path
    pinkEcho "Locating Spotify's Flatpak directory..."
    flatpak_path=$(flatpak --installations | grep com.spotify.Client | awk '{print $2}')

    # 4. Construct the path to Spotify's files
    spotify_path="x86_64/stable/active/files/extra/share/spotify"
    full_spotify_path="$flatpak_path/$spotify_path"

    # 5. Check if the constructed path exists
    if [ ! -d "$full_spotify_path" ]; then
        pinkEcho "WARNING: Default Spotify path not found. Please check manually."
        # Script will continue, but you'll need to investigate the path manually.
    else
        pinkEcho "Found Spotify at: $full_spotify_path"
    fi

    # 6. Find Spotify's preferences file (directly specifying path)
    pinkEcho "Locating Spotify's preferences file..."
    prefs_path=$(find ~/.var/app/com.spotify.Client/config/spotify -maxdepth 1 -name 'prefs' -type f)
    pinkEcho "Found preferences file at: $prefs_path"

    # 7. Configure Spicetify using awk (this step needs config-xpui.ini which is generated by `spicetify backup apply`)
    pinkEcho "Configuring Spicetify..."
    awk -v prefs_path="$prefs_path" '{ 
        if ($1 == "prefs_path") {
            $3 = prefs_path
        } 
        print $0
    }' ~/.config/spicetify/config-xpui.ini > ~/.config/spicetify/config-xpui.ini.tmp
    mv ~/.config/spicetify/config-xpui.ini.tmp ~/.config/spicetify/config-xpui.ini

    # 8. Install Spicetify Marketplace
    pinkEcho "Installing Spicetify Marketplace..."
    curl -fsSL https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.sh | sh

    # 9. Grant write permissions BEFORE `spicetify backup apply`
    pinkEcho "Granting permissions to Spicetify..."
    sudo chmod a+wr /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
    sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify/Apps

    # 10. Apply Spicetify 
    pinkEcho "Applying Spicetify..."
    spicetify backup apply 

    pinkEcho "Done! Go forth and customize your Spotify experience!"   
install-fonts:
    #!/bin/bash
    # 💫 https://github.com/JaKooLit 💫 #
    # FONTS #

    fonts=(
    adobe-source-code-pro-fonts
    fira-code-fonts
    fontawesome-fonts-all
    google-droid-sans-fonts
    google-noto-sans-cjk-fonts
    google-noto-color-emoji-fonts
    google-noto-emoji-fonts
    jetbrains-mono-fonts
    )

    ## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Change the working directory to the parent directory of the script
    PARENT_DIR="$SCRIPT_DIR/.."
    cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

    # Source the global functions script
    if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
    fi

    # Set the name of the log file to include the current date and time
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_fonts.log"


    # Installation of main components
    printf "\n%s - Installing necessary ${SKY_BLUE}fonts${RESET}.... \n" "${NOTE}"

    for PKG1 in "${fonts[@]}"; do
    install_package "$PKG1" "$LOG"
    done

    printf "\n%.0s" {1..2}

    # jetbrains nerd font. Necessary for waybar
    DOWNLOAD_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
    # Maximum number of download attempts
    MAX_ATTEMPTS=2
    for ((ATTEMPT = 1; ATTEMPT <= MAX_ATTEMPTS; ATTEMPT++)); do
        curl -OL "$DOWNLOAD_URL" 2>&1 | tee -a "$LOG" && break
        echo "Download ${YELLOW}DOWNLOAD_URL${RESET} attempt $ATTEMPT failed. Retrying in 2 seconds..." 2>&1 | tee -a "$LOG"
        sleep 2
    done

    # Check if the JetBrainsMono directory exists and delete it if it does
    if [ -d ~/.local/share/fonts/JetBrainsMonoNerd ]; then
        rm -rf ~/.local/share/fonts/JetBrainsMonoNerd 2>&1 | tee -a "$LOG"
    fi

    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd 2>&1 | tee -a "$LOG"
    # Extract the new files into the JetBrainsMono directory and log the output
    tar -xJkf JetBrainsMono.tar.xz -C ~/.local/share/fonts/JetBrainsMonoNerd 2>&1 | tee -a "$LOG"

    # clean up 
    if [ -d "JetBrainsMono.tar.xz" ]; then
        rm -r JetBrainsMono.tar.xz 2>&1 | tee -a "$LOG"
    fi

    # Fantasque Mono Nerd Font
    if wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FantasqueSansMono.zip; then
        mkdir -p "$HOME/.local/share/fonts/FantasqueSansMonoNerd" && unzip -o -q "FantasqueSansMono.zip" -d "$HOME/.local/share/fonts/FantasqueSansMono" && echo "FantasqueSansMono installed successfully" | tee -a "$LOG"
    else
        echo -e "\n${ERROR} Failed to download ${YELLOW}Fantasque Sans Mono Nerd Font${RESET} Please check your connection\n" | tee -a "$LOG"
    fi

    # Victor Mono-Font
    if wget -q https://rubjo.github.io/victor-mono/VictorMonoAll.zip; then
        mkdir -p "$HOME/.local/share/fonts/VictorMono" && unzip -o -q "VictorMonoAll.zip" -d "$HOME/.local/share/fonts/VictorMono" && echo "Victor Font installed successfully" | tee -a "$LOG"
    else
        echo -e "\n${ERROR} Failed to download ${YELLOW}Victor Mono Font${RESET} Please check your connection\n" | tee -a "$LOG"
    fi

    # Update font cache and log the output
    fc-cache -v 2>&1 | tee -a "$LOG"

    printf "\n%.0s" {1..2}
install-gtk-theme:
    #!/bin/bash
    # 💫 https://github.com/JaKooLit 💫 #
    # GTK Themes & ICONS and  Sourcing from a different Repo #

    engine=(
        unzip
        #gtk-engine-murrine
    )

    ## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

    # Change the working directory to the parent directory of the script
    PARENT_DIR="$SCRIPT_DIR/.."
    cd "$PARENT_DIR" || { echo "${ERROR} Failed to change directory to $PARENT_DIR"; exit 1; }

    # Source the global functions script
    if ! source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"; then
    echo "Failed to source Global_functions.sh"
    exit 1
    fi

    # Set the name of the log file to include the current date and time
    LOG="Install-Logs/install-$(date +%d-%H%M%S)_themes.log"


    # installing engine needed for gtk themes
    for PKG1 in "${engine[@]}"; do
        install_package "$PKG1" "$LOG"
    done

    # Check if the directory exists and delete it if present
    if [ -d "GTK-themes-icons" ]; then
        echo "$NOTE GTK themes and Icons directory exist..deleting..." 2>&1 | tee -a "$LOG"
        rm -rf "GTK-themes-icons" 2>&1 | tee -a "$LOG"
    fi

    echo "$NOTE Cloning ${SKY_BLUE}GTK themes and Icons${RESET} repository..." 2>&1 | tee -a "$LOG"
    if git clone --depth=1 https://github.com/JaKooLit/GTK-themes-icons.git ; then
        cd GTK-themes-icons
        chmod +x auto-extract.sh
        ./auto-extract.sh
        cd ..
        echo "$OK Extracted GTK Themes & Icons to ~/.icons & ~/.themes directories" 2>&1 | tee -a "$LOG"
    else
        echo "$ERROR Download failed for GTK themes and Icons.." 2>&1 | tee -a "$LOG"
    fi

    printf "\n%.0s" {1..2}
