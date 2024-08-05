#
# Distrobox configuration
#

echo "Setting up Distrobox..."

# Setup
export DISTROBOX_CUSTOM_HOME="$HOME/.containers"

# Create containers
distrobox-create -n arch -i archlinux:latest --home "$DISTROBOX_CUSTOM_HOME/arch"
distrobox-create -n ubuntu -i ubuntu:latest --home "$DISTROBOX_CUSTOM_HOME/ubuntu"

read -p "Did you already set a password for the containers? (y/n): " setup_containers

if [[ $setup_containers =~ ^[Nn]$ ]]; then
    echo "Setting up containers..."
    echo "Please write exit after you're done with setting a password."
    distrobox-enter arch
    distrobox-enter ubuntu
fi

# ----------
# Setup arch 
distrobox-enter arch -- sudo pacman -Syu --noconfirm
distrobox-enter arch -- sudo pacman -Syu --noconfirm zsh fastfetch zoxide fzf

# Setup zsh & source same config as my main system
sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/arch/.zshrc 
sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/arch/.p10k.zsh
distrobox-enter arch -- /bin/sh 'echo "$(which zsh)" | sudo tee -a /etc/shells && sudo chsh -s $(which zsh) $USER'

read -p "Do you want to setup Yay? (y/n): " setup_yay

if [[ $setup_yay =~ ^[Yy]$ ]]; then
    echo "Setting up Yay..."
    distrobox-enter arch -- /bin/sh -c 'cd && sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si'
else 
    echo "Skipping yay setup."
fi

# Do you want to install the other arch packages?
read -p "Do you want to install the other arch packages? (y/n): " install_arch_packages
if [[ $install_arch_packages =~ ^[Yy]$ ]]; then
    echo "Installing other arch packages..."
    distrobox-enter arch -- /bin/sh -c 'yay -S --noconfirm --needed \
    waveterm-bin \
    devtoys-bin'
    distrobox-enter arch -- /bin/sh -c "distrobox-export --app waveterm --export-path '$HOME/.local/bin'"
    distrobox-enter arch -- /bin/sh -c "distrobox-export --bin /opt/devtoys/devtoys/DevToys.Linux --export-path '$HOME/.local/bin'"
fi

# ---------
# Setup ubuntu
distrobox-enter ubuntu -- /bin/sh -c 'sudo apt update && sudo apt upgrade -y'
distrobox-enter ubuntu -- /bin/sh -c 'sudo apt install software-properties-common'
distrobox-enter ubuntu -- /bin/sh -c 'sudo add-apt-repository ppa:zhangsongcui3371/fastfetch'
distrobox-enter ubuntu -- sudo apt install zsh fastfetch zoxide fzf git fastfetch -y

# Setup zsh & source same config as my main system
sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/ubuntu/.zshrc 
sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/ubuntu/.p10k.zsh
distrobox-enter ubuntu -- /bin/sh 'chsh -s /bin/zsh'

# Ask the user if the want to install screenshotmonitor
read -p "Do you want to install ScreenshotMonitor? (y/n): " install_ssm

if [[ $install_ssm =~ ^[Yy]$ ]]; then
    echo "Installing ScreenshotMonitor..."

    distrobox-enter ubuntu -- /bin/sh -c "cd ~ && wget https://screenshotmonitor-download.s3.amazonaws.com/e/ScreenshotMonitor-amd64.deb && sudo apt install gdebi && sudo gdebi ScreenshotMonitor-amd64.deb && sudo apt install libasound2 && sudo apt install -f && distrobox-export --bin /usr/bin/screenshotmonitor --export-path '$HOME/.local/bin'"
else
    echo "Skipping ScreenshotMonitor installation."
fi


