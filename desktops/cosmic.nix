{ config, lib, pkgs, ... }:

{
    #services.xserver.enable = true;

    services.xserver.enable = true;

    services.xserver.desktopManager.gnome.enable = false;
    services.xserver.displayManager.gdm.enable = false;

    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;

    environment.systemPackages = with pkgs; [
        cosmic-session
        cosmic-greeter
        cosmic-applets
        cosmic-applibrary
        cosmic-bg 
        cosmic-comp
        cosmic-edit
        #cosmic-emoji-picker
        cosmic-files
        cosmic-icons
        cosmic-launcher 
        cosmic-notifications
        cosmic-osd 
        cosmic-panel
        cosmic-protocols
        cosmic-randr
        cosmic-screenshot 
        cosmic-settings-daemon
        cosmic-settings 
        cosmic-store 
        cosmic-tasks 
        cosmic-term 
        cosmic-workspaces-epoch
        #libcosmicAppHook
        pop-launcher 
        xdg-desktop-portal-cosmic
        
        # Custom Packages
        #cosmic-clipboard
    ];
}