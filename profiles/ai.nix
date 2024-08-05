{ config, lib, pkgs, ... }:

{
    environment.systemPackages = with pkgs; [
        # Software
        ollama
    ];
}