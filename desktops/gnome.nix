{ config, lib, pkgs, ... }:

{
  # Enable the GNOME Desktop Environment.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Gnome packages
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.proton-vpn-button
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.ddterm
    gnomeExtensions.toggle-alacritty
  ];
}