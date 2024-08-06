{ config, lib, pkgs, ... }:

{
  # Networking configuration
  networking.hostName = "hannah-nixos";

  # Extra kernel configuration
  boot.extraModulePackages = [ config.boot.kernelPackages.rtl8192eu ]; #config.boot.kernelPackages.rtl88x2bu

  # Enable NVIDIA drivers (Both xserver and wayland)
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics = {
    enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true; # Fix sleep/suspend crashes
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # USB fix 
  boot.kernelParams = [ "usbcore.autosuspend=-1" ]; 

  # Extra sudo configuration
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=300
  '';

  # Extra bluetooth configuration for my desktop
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="7392", ATTRS{idProduct}=="a611", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="2b89", ATTRS{idProduct}=="8761", ATTR{power/control}="on"
  '';

  # Extra packages
  environment.systemPackages = with pkgs; [
    blueman
  ];

  # Swap configuration
  swapDevices = [{
    device = "/swapfile";
    size = 32 * 1024; # 32GB
  }];

  boot.resumeDevice = "/swapfile";
}