{ config, lib, pkgs, ... }:

let
  my-python-packages = python-packages: with python-packages; [
    rich
    ipython
  ];
  my-python = pkgs.python3.withPackages my-python-packages;
in
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  services.timesyncd.enable = true;

  # Configure firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
    allowedUDPPorts = [ ];
    extraCommands = ''
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --set
      iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
      iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    '';
  };

  # Configure SSH
  # services.openssh = {
  #   enable = true;
  #   settings = {
  #     PasswordAuthentication = false;
  #     KbdInteractiveAuthentication = false;
  #     PermitRootLogin = "no";
  #   };
  # };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  # Enable sound with PipeWire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define your username
  users.users.hannah = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ]; # Enable 'sudo' for the user.
  };
  users.defaultUserShell = pkgs.zsh;
  programs.fish.enable = true;
  programs.zsh.enable = true; 

  # Allow unfree packages (needed for NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix = {
    package = pkgs.nixFlakes;
    settings.experimental-features = [ "nix-command" "flakes"];
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Virtualization
  virtualisation.docker.enable = true;

  # Package managers
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "me.iepure.devtoolbox"
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    # Basic Stuff
    vim
    nano
    wget
    git
    fastfetch
    btop
    killall
    direnv
    fzf
    ffmpeg
    mpv
    neovim
    nvtopPackages.full
    gparted
    unrar
    unzip
    icu
    tree
    tldr
    bintools
    dmidecode
    nix-prefetch-git
    exiftool
    nvd
    pciutils
    usbutils

    # Dev
    python3
    my-python
    gitui
    waveterm
    #devtoys
    distrobox

    # Shell
    shell-gpt
    starship
    zoxide
    superfile

    # Languages
    aspell
    aspellDicts.de
    aspellDicts.en
    aspellDicts.en-computers
    aspellDicts.en-science
  ];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    fontDir.enable = true;
    packages = with pkgs; [
      carlito
      dejavu_fonts
      fira
      fira-code
      fira-code-symbols
      fira-mono
      font-awesome
      intel-one-mono
      jetbrains-mono
      liberation_ttf
      meslo-lgs-nf
      nerdfonts
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
      roboto
      roboto-mono
      roboto-serif
      ubuntu_font_family
    ];
  };

  # Cron jobs
  # services.cron = {
  #   enable = true;
  #   systemCronJobs = [];
  # };

  home-manager.backupFileExtension = "backup";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  system.stateVersion = "24.05"; # Did you read the comment?
}
