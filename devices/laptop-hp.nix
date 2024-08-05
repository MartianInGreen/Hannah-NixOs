{ config, lib, pkgs, ... }:

{
  # Networking configuration
  networking.hostName = "hannah-laptop";

  # Extra kernel configuration
  # -/-

  # Extra packages
  # -/-

  # Swap configuration
  swapDevices = [{
    device = "/swapfile";
    size = 8 * 1024; # 16GB
  }];
}