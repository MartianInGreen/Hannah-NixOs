#!/usr/bin/env zsh

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
    echo "Setting up containers..."
    echo "Please write exit after you're done with setting a password."
    distrobox-enter arch
    distrobox-enter ubuntu
}

# Function to setup Arch
setup_arch-basics() {
    # Setup arch 
    distrobox-enter arch -e sudo pacman -Syu --noconfirm
    distrobox-enter arch -e sudo pacman -Syu --noconfirm zsh fastfetch zoxide fzf xorg-xhost libx11 libxext libxrender libxtst

    # Setup zsh & source same config as main system
    sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/arch/.zshrc 
    sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/arch/.p10k.zsh
    distrobox-enter arch -e /bin/sh "sudo chsh -s /usr/bin/zsh $USER"
}
setup_arch-yay() {
    # Setup Yay
    echo "Setting up Yay..."
    distrobox-enter arch -e /bin/sh -c 'cd && rm -rf yay && sudo pacman -S --noconfirm --needed git base-devel go && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si'
}
setup_arch-packages() {
    # Install other arch packages
    echo "Installing other arch packages..."
    distrobox-enter arch -e /bin/sh -c 'yay -S --needed waveterm-bin devtoys-bin'
    distrobox-enter arch -e /bin/sh -c "distrobox-export --app waveterm --export-path '$HOME/.local/bin'"
    distrobox-enter arch -e /bin/sh -c "distrobox-export --bin /opt/devtoys/devtoys/DevToys.Linux --export-path '$HOME/.local/bin'"
}

# Function to setup Ubuntu
setup_ubuntu-basic() {
    # Setup ubuntu
    distrobox-enter ubuntu -e /bin/sh -c 'sudo apt update && sudo apt upgrade -y'
    distrobox-enter ubuntu -e /bin/sh -c 'sudo apt install software-properties-common'
    distrobox-enter ubuntu -e /bin/sh -c 'sudo add-apt-repository ppa:zhangsongcui3371/fastfetch'
    distrobox-enter ubuntu -e sudo apt install zsh fastfetch zoxide fzf git fastfetch -y

    # Setup zsh & source same config as main system
    sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/ubuntu/.zshrc 
    sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/ubuntu/.p10k.zsh
    distrobox-enter ubuntu -e /bin/sh 'chsh -s /bin/zsh'
}
setup_ubuntu-screenshotmonitor() {
    # Install ScreenshotMonitor
    echo "Installing ScreenshotMonitor..."
    distrobox-enter ubuntu -e /bin/sh -c "cd ~ && wget https://screenshotmonitor-download.s3.amazonaws.com/e/ScreenshotMonitor-amd64.deb && sudo apt install gdebi && sudo gdebi ScreenshotMonitor-amd64.deb && sudo apt install libasound2t64 && sudo apt install -f && distrobox-export --bin /usr/bin/screenshotmonitor --export-path '$HOME/.local/bin' --extra-flags '--in-process-gpu'"
}
setup_ubuntu-packages() {
    # Install other ubuntu packages
    echo "Installing other ubuntu packages..."
    # Uncomment and add packages as needed
    # distrobox-enter ubuntu -e /bin/sh -c 'sudo apt install -y \
    # package-1 \
    # package-2'
}

# Main execution

# Prompt for sudo password
echo "Please enter your sudo password:"
vared -s SUDO_PASSWORD
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
echo '#!/bin/sh' > "$SUDO_ASKPASS"
echo "echo $SUDO_PASSWORD" >> "$SUDO_ASKPASS"
chmod +x "$SUDO_ASKPASS"
export SUDO_ASKPASS

# Create main menu
vared -p "Do you want to create containers? (y/n): " -c create_containers_choice
vared -p "Do you want to setup container passwords? (y/n): " -c setup_container_passwords_choice
vared -p "Do you want to setup Arch? (y/n): " -c setup_arch_choice
vared -p "Do you want to setup Arch with Yay? (y/n): " -c setup_arch_yay_choice
vared -p "Do you want to setup Arch with packages? (y/n): " -c setup_arch_packages_choice
vared -p "Do you want to setup Ubuntu? (y/n): " -c setup_ubuntu_choice
vared -p "Do you want to setup Ubuntu with ScreenshotMonitor? (y/n): " -c setup_ubuntu_screenshotmonitor_choice
vared -p "Do you want to setup Ubuntu with packages? (y/n): " -c setup_ubuntu_packages_choice

# Process selected options
if [ "$create_containers_choice" = "y" ]; then
    create_containers
fi
if [ "$setup_container_passwords_choice" = "y" ]; then
    setup_container_passwords
fi
if [ "$setup_arch_choice" = "y" ]; then
    setup_arch-basics
fi
if [ "$setup_arch_yay_choice" = "y" ]; then
    setup_arch-yay
fi
if [ "$setup_arch_packages_choice" = "y" ]; then
    setup_arch-packages
fi
if [ "$setup_ubuntu_choice" = "y" ]; then
    setup_ubuntu-basic
fi
if [ "$setup_ubuntu_screenshotmonitor_choice" = "y" ]; then
    setup_ubuntu-screenshotmonitor
fi
if [ "$setup_ubuntu_packages_choice" = "y" ]; then
    setup_ubuntu-packages
fi
echo "Setup complete!"