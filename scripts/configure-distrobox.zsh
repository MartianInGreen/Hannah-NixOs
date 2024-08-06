#!/usr/bin/env nix-shell
#!nix-shell -i zsh -p zsh newt

#
# Distrobox configuration
#

echo "Setting up Distrobox..."

# Setup
export DISTROBOX_CUSTOM_HOME="$HOME/.containers"

# Function to create containers
create_containers() {
    distrobox-create -n arch -i archlinux:latest --home "$DISTROBOX_CUSTOM_HOME/arch"
    distrobox-create -n ubuntu -i ubuntu:latest --home "$DISTROBOX_CUSTOM_HOME/ubuntu"
}

# Function to setup container passwords
setup_container_passwords() {
    read -p "Did you already set a password for the containers? (y/n): " setup_containers
    if [[ $setup_containers =~ ^[Nn]$ ]]; then
        echo "Setting up containers..."
        echo "Please write exit after you're done with setting a password."
        distrobox-enter arch
        distrobox-enter ubuntu
    fi
}

# Function to setup Arch
setup_arch-basics() {
    # Setup arch 
    distrobox-enter arch -- sudo pacman -Syu --noconfirm
    distrobox-enter arch -- sudo pacman -Syu --noconfirm zsh fastfetch zoxide fzf xorg-xhost libx11 libxext libxrender libxtst

    # Setup zsh & source same config as main system
    sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/arch/.zshrc 
    sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/arch/.p10k.zsh
    distrobox-enter arch -- /bin/sh 'echo "$(which zsh)" | sudo tee -a /etc/shells && sudo chsh -s $(which zsh) $USER'
}
setup_arch-yay() {
    # Setup Yay
    read -p "Do you want to setup Yay? (y/n): " setup_yay
    if [[ $setup_yay =~ ^[Yy]$ ]]; then
        echo "Setting up Yay..."
        distrobox-enter arch -- /bin/sh -c 'cd && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si'
    else 
        echo "Skipping yay setup."
    fi
}
setup_arch-packages() {
    # Install other arch packages
    read -p "Do you want to install the other arch packages? (y/n): " install_arch_packages
    if [[ $install_arch_packages =~ ^[Yy]$ ]]; then
        echo "Installing other arch packages..."
        distrobox-enter arch -- /bin/sh -c 'yay -S --noconfirm --needed \
        waveterm-bin \
        devtoys-bin'
        distrobox-enter arch -- /bin/sh -c "distrobox-export --app waveterm --export-path '$HOME/.local/bin'"
        distrobox-enter arch -- /bin/sh -c "distrobox-export --bin /opt/devtoys/devtoys/DevToys.Linux --export-path '$HOME/.local/bin'"
    fi
}

# Function to setup Ubuntu
setup_ubuntu-basic() {
    # Setup ubuntu
    distrobox-enter ubuntu -- /bin/sh -c 'sudo apt update && sudo apt upgrade -y'
    distrobox-enter ubuntu -- /bin/sh -c 'sudo apt install software-properties-common'
    distrobox-enter ubuntu -- /bin/sh -c 'sudo add-apt-repository ppa:zhangsongcui3371/fastfetch'
    distrobox-enter ubuntu -- sudo apt install zsh fastfetch zoxide fzf git fastfetch -y

    # Setup zsh & source same config as main system
    sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/ubuntu/.zshrc 
    sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/ubuntu/.p10k.zsh
    distrobox-enter ubuntu -- /bin/sh 'chsh -s /bin/zsh'
}
setup_ubuntu-screenshotmonitor() {
    # Install ScreenshotMonitor
    read -p "Do you want to install ScreenshotMonitor? (y/n): " install_ssm
    if [[ $install_ssm =~ ^[Yy]$ ]]; then
        echo "Installing ScreenshotMonitor..."
        distrobox-enter ubuntu -- /bin/sh -c "cd ~ && wget https://screenshotmonitor-download.s3.amazonaws.com/e/ScreenshotMonitor-amd64.deb && sudo apt install gdebi && sudo gdebi ScreenshotMonitor-amd64.deb && sudo apt install libasound2t64 && sudo apt install -f && distrobox-export --bin /usr/bin/screenshotmonitor --export-path '$HOME/.local/bin' --extra-flags '--in-process-gpu'"
    else
        echo "Skipping ScreenshotMonitor installation."
    fi
}
setup_ubuntu-packages() {
    # Install other ubuntu packages
    read -p "Do you want to install the other ubuntu packages? (y/n): " install_ubuntu_packages
    if [[ $install_ubuntu_packages =~ ^[Yy]$ ]]; then
        echo "Installing other ubuntu packages..."
        # Uncomment and add packages as needed
        # distrobox-enter ubuntu -- /bin/sh -c 'sudo apt install -y \
        # package-1 \
        # package-2'
    fi
}

# Main execution

# Prompt for sudo password
echo "Please enter your sudo password:"
read -s SUDO_PASSWORD
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
echo '#!/bin/sh' > "$SUDO_ASKPASS"
echo "echo $SUDO_PASSWORD" >> "$SUDO_ASKPASS"
chmod +x "$SUDO_ASKPASS"
export SUDO_ASKPASS

# Create the checklist menu
choices=$(whiptail --title "Distrobox Configuration" --checklist \
"Choose the operations you want to perform:" 20 78 12 \
"CREATE_CONTAINERS" "Create containers" OFF \
"SETUP_PASSWORDS" "Setup container passwords" OFF \
"ARCH_BASICS" "Setup Arch basics" OFF \
"ARCH_YAY" "Setup Yay for Arch" OFF \
"ARCH_PACKAGES" "Install additional Arch packages" OFF \
"UBUNTU_BASIC" "Setup Ubuntu basics" OFF \
"UBUNTU_SSM" "Setup ScreenshotMonitor for Ubuntu" OFF \
"UBUNTU_PACKAGES" "Install additional Ubuntu packages" OFF \
3>&1 1>&2 2>&3)

# Check if user cancelled
if [ $? -ne 0 ]; then
    echo "Operation cancelled."
    exit 1
fi

# Process selected options
echo $choices | tr -d '"' | tr ' ' '\n' | while read choice
do
    case $choice in
        CREATE_CONTAINERS) create_containers ;;
        SETUP_PASSWORDS) setup_container_passwords ;;
        ARCH_BASICS) setup_arch-basics ;;
        ARCH_YAY) setup_arch-yay ;;
        ARCH_PACKAGES) setup_arch-packages ;;
        UBUNTU_BASIC) setup_ubuntu-basic ;;
        UBUNTU_SSM) setup_ubuntu-screenshotmonitor ;;
        UBUNTU_PACKAGES) setup_ubuntu-packages ;;
    esac
done

echo "Configuration complete!"
