{ config, lib, pkgs, ... }:

{
  # Electron support for Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    ELECTRON_ENABLE_FEATURES = "WaylandWindowDecorations";
  };

  # Additional Wayland-related packages
  environment.systemPackages = with pkgs; [
    # Existing packages...
    wl-clipboard
    xdg-desktop-portal
    xdg-desktop-portal-xapp
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ];
}