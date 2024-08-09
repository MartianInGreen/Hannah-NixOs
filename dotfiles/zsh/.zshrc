# If the session is interactive run the nsh command
# if [[ $- == *i* ]]; then
#     fastfetch --config $HOME/.config/fastfetch/config-tiny.jsonc && echo "Shell-GPT enabled. Use 'sgpt' to ask questions or 'sgpt -s' to execute commands."
# fi

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set the directory we want to store zinit and plugins 
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi 

# Source Zinit
source "${ZINIT_HOME}/zinit.zsh"

# Powerlevel10k Prompt
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::command-not-found
#zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::npm
zinit snippet OMZP::pip
zinit snippet OMZP::python
#zinit snippet OMZP::web-search

# Load autocompletion
autoload -U compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
HISTFILE="$HOME/.zsh_history"
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completions styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -la --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'exa -la --color=always $realpath'

zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' continuous-trigger 'tab'
zstyle ':fzf-tab:*' single-group ''

# Aliases 
alias ls='exa --color'
alias ll="exa -lah"
alias nsh="clear && cd && fastfetch && echo \"Shell-GPT enabled. Use 'sgpt' to ask questions or 'sgpt -s' to execute commands.\" $argv"
alias nshu="update-zsh && clear && cd && fastfetch && echo \"Shell-GPT enabled. Use 'sgpt' to ask questions or 'sgpt -s' to execute commands.\" $argv"
alias edit-config="code $HOME/.nixos-config"
alias bluetooth-hack="hcitool dev && sudo rfkill block bluetooth && hcitool dev"
alias housekeep="nix-channel --update && nix-collect-garbage --delete-old && nix-collect-garbage && sudo nix-env --list-generations --profile /nix/var/nix/profiles/system && sudo nix-env --delete-generations +50 --profile /nix/var/nix/profiles/system"
alias ai="sgpt --model gpt-4o-mini"
alias hrudl="~/.local/bin/screenshotmonitor"
alias files="superfile"
alias nshell="nix-shell $argv --command zsh"
alias gpgu="gpg --homedir .secrets/ --pinentry-mode loopback"

# Shell scripts aliases
alias custom-help="./.scripts/custom-help.sh"
alias update-distrobox="update-distrobox.zsh"
alias configure-distrobox="configure-distrobox.zsh"

alias devtoys="$HOME/.local/bin/DevToys.Linux"

# Shell variables
export DISTROBOX_CUSTOM_HOME="$HOME/.containers"
export GNUPGHOME="$HOME/.secrets/"
export GPG_PINENTRY_MODE="loopback"

# Modify Path
PATH=$PATH:$HOME/.local/bin:$HOME/.scripts

# ---------------------------
# Tools
# ---------------------------

alias nvidia-driver-version="nvidia-smi | grep \"Driver Version\" | awk '{print $3}'"

alias pull-config="cd $HOME/.nixos-config && git pull"

number-of-files-by-type(){
  local filetype="${1:-"py"}"
  find . -type f -name "*.$filetype" | wc -l
}

number-of-files(){
  find . -type f | wc -l
}

lines-of-code() {
  local filetype="${1:-"py"}"
  find . -type f -name "*.$filetype" -print0 | xargs -0 wc -l | awk 'END {print $1}'
}

# ---------------------------
# Functions
# ---------------------------

# Containers
arch() {
  cp $HOME/.nixos-config/dotfiles/zsh/.zshrc $DISTROBOX_CUSTOM_HOME/arch/.zshrc 
  cp $HOME/.nixos-config/dotfiles/zsh/.p10k.zsh $DISTROBOX_CUSTOM_HOME/arch/.p10k.zsh
  distrobox-enter arch
}

ubuntu() {
  cp $HOME/.nixos-config/dotfiles/zsh/.zshrc $DISTROBOX_CUSTOM_HOME/ubuntu/.zshrc 
  cp $HOME/.nixos-config/dotfiles/zsh/.p10k.zsh $DISTROBOX_CUSTOM_HOME/ubuntu/.p10k.zsh
  distrobox-enter ubuntu
}

push-public-config() {
  local cwd=$(pwd)

  cd $HOME/Dev/Hannah-NixOs
  if cd "$HOME/Dev/Hannah-NixOs"; then
    # Add files 
    mv .gitignore .gitignore.bak
    mv README.md README.md.bak
    cp -r $HOME/.nixos-config/* .
    rm .gitignore
    mv readme.md original-readme.md
    mv README.md.bak README.md
    mv .gitignore.bak .gitignore

    git add .

    # Show the diff to the user
    echo "Changes to be committed:"
    git diff --cached --color --compact-summary

    echo -n "Enter a commit message: "
    read commit_message

    # Commit changes
    git commit -m "$commit_message"
    git push
    echo "Changes pushed to remote repository."
  fi
  cd $cwd
}

# Push-Config Function
push-config() {
  local cwd=$(pwd)
  local timestamp=$(date "+%Y-%m-%d_%H:%M:%S")

  export LAST_CONFIG_PUSH_TIMESTAMP=$(date +%s)

  cd $HOME/.nixos-config/
  if cd "$HOME/.nixos-config/"; then
    mkdir -p hardware-conf
    git add .

    # Show the diff to the user
    echo "Changes to be committed:"
    git diff --cached --color --compact-summary

    # Summarize changes and get suggested commit message
    summary=$(git diff --cached | sgpt --model gpt-4o-mini "Please summarize these changes into 3-4 lines and suggest a git commit message at the end.\nThe git commit message should be below 40 charachters and be written out as follows:\n**Suggested commit message:**\n_The git message suggestion_\n\n Git diff:\n")

    # Extract the last line as the suggested commit message
    suggested_message=$(echo "$summary" | tail -n 1)
    summary_without_last_line=$(echo "$summary" | head -n -2)

    # Display summary and ask user for commit message
    echo "$summary"
    echo -n "Enter a commit message (press Enter to use suggested message): "
    read commit_message

    if [ -z "$commit_message" ]; then
      commit_message=$(echo -e "$suggested_message\n$summary_without_last_line")
    fi

    git commit -m "$commit_message (at $timestamp)"

    git push
    echo "Config pushed to GitHub."
  fi
  cd $cwd
}

# Update Function
test-update() {
    local config_name="${1:-$(hostname)}"
    local timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
    local start_time=$(date +%s)

    echo "------------------------- Managing Config Files -------------------------"

    # Create directories if they don't exist
    mkdir -p "$HOME/.nixos-backup"
    mkdir -p "$HOME/.nixos-config"
    mkdir -p "$HOME/.containers"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.nixos-backup/$timestamp"
    mkdir -p "$HOME/.scripts"
    mkdir -p "$HOME/.secrets"
    sudo chmod 700 "$HOME/.secrets"

    # Check if .nixos-config is empty
    if [ -z "$(ls -A "$HOME/.nixos-config")" ]; then
        # Copy current config to .nixos-config
        cp -r /etc/nixos/* "$HOME/.nixos-config/"
        echo "Copied current config to .nixos-config, since it was not yet populated."
        return
    fi

    # Copy current config to backup
    echo "Backing up current config to .nixos-backup/$timestamp"
    cp -r /etc/nixos/* $HOME/.nixos-backup/$timestamp/

    # Copy new config to /etc/nixos
    echo "Copying new config to /etc/nixos"
    sudo rm -rf /etc/nixos/*
    sudo cp -r $HOME/.nixos-config/* /etc/nixos/
    # Managing hardware-configuration.nix
    sudo cp $HOME/.nixos-config/hardware-conf/$(hostname)-hardware-configuration.nix /etc/nixos/hardware-configuration.nix

    echo "------------------------- Building System Update -------------------------"

    # Update nix
    echo "Updating NixOS with config: $config_name"
    sudo nixos-rebuild test --flake /etc/nixos#$config_name --max-jobs 8
    echo "------------------------- System Update Summary -------------------------"
    nvd diff /run/current-system ./result
    echo "------------------------- Applying Update -------------------------"
     # Save diff to update-summary.txt file inside the backup
    nvd diff /run/current-system ./result > "$HOME/.nixos-backup/$timestamp/update-summary.txt"

    # Cleanup
    rm -rf $HOME/.nixos-config/result

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "----------------------------------------------------------------"
    echo "NixOS updated. Took $duration seconds."
    echo "Saved update summary to $HOME/.nixos-backup/$timestamp/update-summary.txt"
    echo "Remember to run any other setup/update scripts located in the .scripts folder if needed!"

    # Check LAST_CONFIG_PUSH_TIMESTAMP when the config was last pushed to GitHub, if it's more than 24 hours ago, ask if the user wants to push the config to GitHub
    if [ -n "$LAST_CONFIG_PUSH_TIMESTAMP" ] && [ "$(( $(date +%s) - $LAST_CONFIG_PUSH_TIMESTAMP ))" -gt 86400 ]; then
        echo "It's been more than 24 hours since the last config push to GitHub."
        echo -n "Do you want to push the config to GitHub? (y/n): "
        read push_config
        if [ "$push_config" = "y" ]; then
            push-config
        fi
    fi
}

# Update Function
update() {
    local config_name="${1:-$(hostname)}"
    local timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
    local start_time=$(date +%s)

    echo "------------------------- Managing Config Files -------------------------"

    # Create directories if they don't exist
    mkdir -p "$HOME/.nixos-backup"
    mkdir -p "$HOME/.nixos-config"
    mkdir -p "$HOME/.containers"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.nixos-backup/$timestamp"
    mkdir -p "$HOME/.scripts"
    mkdir -p "$HOME/.secrets"
    sudo chmod 700 "$HOME/.secrets"

    # Check if .nixos-config is empty
    if [ -z "$(ls -A "$HOME/.nixos-config")" ]; then
        # Copy current config to .nixos-config
        cp -r /etc/nixos/* "$HOME/.nixos-config/"
        echo "Copied current config to .nixos-config, since it was not yet populated."
        return
    fi

    # Copy current config to backup
    echo "Backing up current config to .nixos-backup/$timestamp"
    cp -r /etc/nixos/* $HOME/.nixos-backup/$timestamp/

    # Copy new config to /etc/nixos
    echo "Copying new config to /etc/nixos"
    sudo rm -rf /etc/nixos/*
    sudo cp -r $HOME/.nixos-config/* /etc/nixos/
    # Managing hardware-configuration.nix
    sudo cp $HOME/.nixos-config/hardware-conf/$(hostname)-hardware-configuration.nix /etc/nixos/hardware-configuration.nix

    echo "------------------------- Building System Update -------------------------"

    # Update nix
    echo "Updating NixOS with config: $config_name"
    sudo nixos-rebuild build --upgrade --flake /etc/nixos#$config_name --max-jobs 8
    echo "------------------------- System Update Summary -------------------------"
    nvd diff /run/current-system ./result

    # Ask for confirmation before applying the update
    echo -n "Apply update? (Y/n) "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        echo "Applying update..."
    else
        echo "Update cancelled."
        return
    fi    
    echo "------------------------- Applying Update -------------------------"
    sudo nixos-rebuild switch --flake /etc/nixos#$config_name --max-jobs 8

    # Copy all scripts form the scripts folder to $HOME/.scripts
    update-scripts

    # Save diff to update-summary.txt file inside the backup
    nvd diff /run/current-system ./result > "$HOME/.nixos-backup/$timestamp/update-summary.txt"

    # Cleanup
    rm -rf $HOME/.nixos-config/result

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "----------------------------------------------------------------"
    echo "NixOS updated. Took $duration seconds."
    echo "Saved update summary to $HOME/.nixos-backup/$timestamp/update-summary.txt"
    echo "Remember to run any other setup/update scripts located in the .scripts folder if needed!"

    # Check LAST_CONFIG_PUSH_TIMESTAMP when the config was last pushed to GitHub, if it's more than 24 hours ago, ask if the user wants to push the config to GitHub
    if [ -n "$LAST_CONFIG_PUSH_TIMESTAMP" ] && [ "$(( $(date +%s) - $LAST_CONFIG_PUSH_TIMESTAMP ))" -gt 86400 ]; then
        echo "It's been more than 24 hours since the last config push to GitHub."
        echo -n "Do you want to push the config to GitHub? (y/n): "
        read push_config
        if [ "$push_config" = "y" ]; then
            push-config
        fi
    fi
}

# Update Function
update() {
    local config_name="${1:-$(hostname)}"
    local timestamp=$(date "+%Y-%m-%d_%H:%M:%S")
    local start_time=$(date +%s)

    echo "------------------------- Managing Config Files -------------------------"

    # Create directories if they don't exist
    mkdir -p "$HOME/.nixos-backup"
    mkdir -p "$HOME/.nixos-config"
    mkdir -p "$HOME/.containers"
    mkdir -p "$HOME/.local/bin"
    mkdir -p "$HOME/.nixos-backup/$timestamp"
    mkdir -p "$HOME/.scripts"
    mkdir -p "$HOME/.secrets"
    sudo chmod 700 "$HOME/.secrets"

    # Check if .nixos-config is empty
    if [ -z "$(ls -A "$HOME/.nixos-config")" ]; then
        # Copy current config to .nixos-config
        cp -r /etc/nixos/* "$HOME/.nixos-config/"
        echo "Copied current config to .nixos-config, since it was not yet populated."
        return
    fi

    # Copy current config to backup
    echo "Backing up current config to .nixos-backup/$timestamp"
    cp -r /etc/nixos/* $HOME/.nixos-backup/$timestamp/

    # Copy new config to /etc/nixos
    echo "Copying new config to /etc/nixos"
    sudo rm -rf /etc/nixos/*
    sudo cp -r $HOME/.nixos-config/* /etc/nixos/
    # Managing hardware-configuration.nix
    sudo cp $HOME/.nixos-config/hardware-conf/$(hostname)-hardware-configuration.nix /etc/nixos/hardware-configuration.nix

    echo "------------------------- Building System Update -------------------------"

    # Update nix
    echo "Updating NixOS with config: $config_name"
    sudo nixos-rebuild build --upgrade --flake /etc/nixos#$config_name --max-jobs 8
    echo "------------------------- System Update Summary -------------------------"
    nvd diff /run/current-system ./result

    # Ask for confirmation before applying the update
    echo -n "Apply update? (Y/n) "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]] || [[ -z "$response" ]]; then
        echo "Applying update..."
    else
        echo "Update cancelled."
        return
    fi    
    echo "------------------------- Applying Update -------------------------"
    sudo nixos-rebuild switch --flake /etc/nixos#$config_name --max-jobs 8

    # Copy all scripts form the scripts folder to $HOME/.scripts
    update-scripts

    # Save diff to update-summary.txt file inside the backup
    nvd diff /run/current-system ./result > "$HOME/.nixos-backup/$timestamp/update-summary.txt"

    # Cleanup
    rm -rf $HOME/.nixos-config/result

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo "----------------------------------------------------------------"
    echo "NixOS updated. Took $duration seconds."
    echo "Saved update summary to $HOME/.nixos-backup/$timestamp/update-summary.txt"
    echo "Remember to run any other setup/update scripts located in the .scripts folder if needed!"

    # Check LAST_CONFIG_PUSH_TIMESTAMP when the config was last pushed to GitHub, if it's more than 24 hours ago, ask if the user wants to push the config to GitHub
    if [ -n "$LAST_CONFIG_PUSH_TIMESTAMP" ] && [ "$(( $(date +%s) - $LAST_CONFIG_PUSH_TIMESTAMP ))" -gt 86400 ]; then
        echo "It's been more than 24 hours since the last config push to GitHub."
        echo -n "Do you want to push the config to GitHub? (y/n): "
        read push_config
        if [ "$push_config" = "y" ]; then
            push-config
        fi
    fi
}

update-full() {
  local config_name="${1:-$(hostname)}"

  echo "------------------------- Updating nix flake -------------------------"
  # Updating the flake
  nix flake update $HOME/.nixos-config
  echo "------------------------- Updating nix -------------------------"
  update $config_name 
  housekeep
  echo "------------------------- Distrobox Update -------------------------"
  update-distrobox.zsh
  echo "----------------------------------------------------------------"
  echo "System update fully completed."
}

update-scripts() {
  echo "Copying scripts from $HOME/.nixos-config/scripts to $HOME/.scripts"
  rm -rf "$HOME/.scripts"
  mkdir -p "$HOME/.scripts"
  cp -r $HOME/.nixos-config/scripts/* "$HOME/.scripts/"

  # Make them executable
  chmod +x "$HOME/.scripts"/*
}

update-zsh(){
  echo "Updating zsh"
  source $HOME/.nixos-config/dotfiles/zsh/.zshrc
}

# Shell integrations
if [[ -z "$DISTROBOX_ENTER_PATH" ]]; then
  eval "$(fzf --zsh)"
fi
eval "$(zoxide init --cmd cd zsh)"