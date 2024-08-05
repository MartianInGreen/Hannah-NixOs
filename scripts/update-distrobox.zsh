echo "Updating Distrobox..."

# Update containers
distrobox-enter arch -- /bin/sh -c 'yay -Syu --noconfirm'
distrobox-enter ubuntu -- /bin/sh -c 'sudo apt update && sudo apt upgrade -y'

# Update zsh config
sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/arch/.zshrc
sudo cp $HOME/.zshrc $DISTROBOX_CUSTOM_HOME/ubuntu/.zshrc
# Update p10k config
sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/arch/.p10k.zsh
sudo cp $HOME/.p10k.zsh $DISTROBOX_CUSTOM_HOME/ubuntu/.p10k.zsh

echo "Distrobox updated."