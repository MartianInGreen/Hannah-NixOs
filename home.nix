{ config, pkgs, isServer, ... }:

let 
  username = "hannah";
  gitName = "MartianInGreen"; 
  gitEmail = "github@rennersh.eu";
  keyID = "EFBEF921499D8E20";
in
{ 
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    #
    # Common Packages
    #

    # System
    imagemagick
    
    # Distrobox
    distrobox
    xorg.xhost

    # Dev
    gitAndTools.gh

  ] ++ (if !isServer then [
    #
    # Desktop Packages
    #

    # Basic Stuff
    flameshot
    nemo-with-extensions
    protonvpn-gui
    qalculate-gtk

    # Web
    firefox
    brave

    # Office
    gimp
    pix
    audacity
    krita
    xournalpp
    wpsoffice

    # Dev
    vscode
    alacritty
    peazip
    ventoy-full
    virt-manager

    # Personal 
    obsidian
  ] else [
    #
    # Server Packages
    #
  ]);


  programs.gh.enable = true;

  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-uri = "https://i.pinimg.com/originals/08/ad/ab/08adab072227f435c95a9b49f3a227a1.jpg";
      picture-uri-dark = "https://i.pinimg.com/originals/08/ad/ab/08adab072227f435c95a9b49f3a227a1.jpg";
    };
  };

  programs.git = {
    enable = true;
    userName = gitName;
    userEmail = gitEmail;
    extraConfig = {
      user.signingkey = keyID;
      commit.gpgsign = true;
      gpg.homedir = "$HOME/.secrets";
    };
  };

  programs.zsh = {
    enable = true; 
    initExtra = builtins.readFile ./dotfiles/zsh/.zshrc;
  };

  # # GTK Theme
  # gtk = {
  #   enable = true;
  #   theme = "Adwaita";
  #   iconTheme = "Papirus-Dark";
  #   cursorTheme = "Breeze_Snow";
  # };

  # # Mimetypes
  # xdg.mimeapps.defaultApplications = {
  #   "text/plain" = [ "code" ];
  #   "text/html" = [ "brave" ];
  #   "application/pdf" = [ "brave" ];
  #   "image/*" = [ "brave" ];
  #   "video/*" = [ "brave" ];
  # };


  # ------------------------------------------------
  # Dotfiles management
  # ------------------------------------------------

  home.file = {
    # p10k
    ".p10k.zsh".text = builtins.readFile ./dotfiles/zsh/.p10k.zsh;

    # Fastfetch
    ".config/fastfetch/config.jsonc".text = builtins.readFile ./dotfiles/fastfetch/config.jsonc;
    ".config/fastfetch/config-tiny.jsonc".text = builtins.readFile ./dotfiles/fastfetch/config-tiny.jsonc;

    # Superfile
    ".config/superfile/config.toml".text = builtins.readFile ./dotfiles/superfile/config.toml;
    ".config/superfile/hotkeys.toml".text = builtins.readFile ./dotfiles/superfile/hotkeys.toml;

    # Package version
    ".current-user-packages".text =
      let
        packages = builtins.map (p: "${p.name}") config.home.packages;
        sortedUnique = builtins.sort builtins.lessThan (pkgs.lib.lists.unique packages);
        formatted = builtins.concatStringsSep "\n" sortedUnique;
      in
        formatted;
    
  } // (if !isServer then {
    # Alacritty
    ".config/alacritty/alacritty.toml".text = builtins.readFile ./dotfiles/alacritty.toml;

    # Nemo (File Manager) Actions
    ".local/share/nemo/actions/peazip.nemo_action".source = ./dotfiles/nemo/peazip.nemo_action;
    ".local/share/nemo/actions/alacritty.nemo_action".source = ./dotfiles/nemo/alacritty.nemo_action;

    # Cosmic
    "./home/hannah/.config/cosmic/com.system76.CosmicComp/v1/xkb_config".source = ./dotfiles/cosmic/xkb_config;
    "./home/hannah/.config/cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".source = ./dotfiles/cosmic/keys_custom;

    # Desktop files
    ".local/share/applications/screenshotmonitor.desktop".source = ./dotfiles/desktop-files/screenshotmonitor.desktop;
    ".local/share/icons/screenshotmonitor.png".source = ./dotfiles/icons/time_space_icon.png;

    ".local/share/applications/DevToys.desktop".source = ./dotfiles/desktop-files/DevToys.desktop;
    ".local/share/icons/devtoys.png".source = ./dotfiles/icons/devtoys.png;
  } else {});


  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
