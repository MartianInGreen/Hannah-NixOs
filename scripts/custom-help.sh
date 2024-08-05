#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p python312 python312Packages.rich

# -*- coding: python -*-

from rich import print # type: ignore

text = """
Custom Help & Cheat sheet
--------------- Updates -------------------
[bold]update[/bold] #flake-name - [dim]Updates the system with the given flake[/dim]
[bold]update-full[/bold] #flake-name - [dim]Updates the system with the given flake, and updates the Distrobox enviorements.[/dim]
[bold]update-scripts[/bold] - [dim]Updates the scripts in the .scripts folder[/dim]
[bold]update-zsh[/bold] - [dim]Sources the current zshrc from the .nixos-config folder[/dim]
[bold]push-config[/bold] - [dim]Pushes the current config to GitHub[/dim]
--------------- Aliases -------------------
[bold]nsh[/bold] - [dim]Clears the screen, changes directory, runs fastfetch, and prints a message[/dim]
[bold]nshu[/bold] - [dim]Updates zsh-source, clears the screen, changes directory, runs fastfetch, and prints a message[/dim]
[bold]edit-config[/bold] - [dim]Opens the current config in VS Code[/dim]
[bold]pull-config[/bold] - [dim]Pulls the latest config from GitHub[/dim]
[bold]bluetooth-hack[/bold] - [dim]Blocks bluetooth and unblocks it[/dim]
[bold]housekeep[/bold] - [dim]Updates nix, cleans up old generations, and deletes old generations[/dim]
[bold]ai[/bold] - [dim]Opens the Shell-GPT interface[/dim]
[bold]arch[/bold] - [dim]Enters the Arch container[/dim]
[bold]ubuntu[/bold] - [dim]Enters the Ubuntu container[/dim]
--------------- Tools -------------------
[bold]lines-of-code[/bold] filetype - [dim]Prints the number of lines of code in the given file type in this directory and all subdirectories.[/dim]
"""

print(text)