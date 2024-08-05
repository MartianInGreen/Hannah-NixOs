# Setup

Github first clone
```zsh
cd ~
gh repo clone MartianInGreen/NixOS-config .nixos-config
```

Set hostname and run update based on flake name (desktop/laptop)
```zsh
sudo hostnamectl set-hostname <hostname>
update #config-name
```