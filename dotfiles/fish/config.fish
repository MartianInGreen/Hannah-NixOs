# If shell type is interactive
if status is-interactive
    clear && cd && fastfetch && echo "Shell-GPT enabled. Use 'sgpt' to ask questions or 'sgpt -s' to execute commands."
end

# Function to store last command output in LAST variable
#function fish_postexec --on-event fish_postexec
#  set -g LAST (eval $argv)
#end

# Update Function
function update --wraps='sudo nixos-rebuild switch --upgrade --flake /etc/nixos#"$1"' --description 'alias update sudo nixos-rebuild switch --upgrade --flake /etc/nixos#"$1"'
    sudo nixos-rebuild switch --upgrade --flake /etc/nixos#$argv[1]
end