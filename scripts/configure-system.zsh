#!/usr/bin/env nix-shell
#!nix-shell -i zsh -p zsh newt

configure-ssh() {
  ssh-add ~/.secrets/id_rsa
}

# Prompt for sudo password
echo "Please enter your sudo password:"
read -s SUDO_PASSWORD
export SUDO_ASKPASS="$HOME/.local/bin/sudo-askpass"
echo '#!/bin/sh' > "$SUDO_ASKPASS"
echo "echo $SUDO_PASSWORD" >> "$SUDO_ASKPASS"
chmod +x "$SUDO_ASKPASS"
export SUDO_ASKPASS

# Create the checklist menu
choices=$(whiptail --title "System Configuration" --checklist \
"Choose the operations you want to perform:" 20 78 12 \
"CONFIGURE_SSH" "Configure SSH keys" OFF \
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
        CONFIGURE_SSH) configure-ssh ;;
    esac
done

echo "Configuration complete!"
