{ config, pkgs, ... }:

let 
  username = "hannah";
  gitName = "Hannah"; 
  gitEmail = "hannah@rennersh.eu";
in
{ 
  home.username = username;
  home.homeDirectory = "/home/${username}";

  home.packages = with pkgs; [
    # Basic Stuff
    flameshot
    nemo-with-extensions
    protonvpn-gui

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
    gitAndTools.gh

    # Personal 
    obsidian
  ];

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
  };

  programs.zsh = {
    enable = true; 
    initExtra = builtins.readFile ./dotfiles/zsh/.zshrc;
  };

  home.file.".p10k.zsh".text = builtins.readFile ./dotfiles/zsh/.p10k.zsh;

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

  # Fastfetch
  home.file.".config/fastfetch/config.jsonc".text = builtins.readFile ./dotfiles/fastfetch/config.jsonc;
  home.file.".config/fastfetch/config-tiny.jsonc".text = builtins.readFile ./dotfiles/fastfetch/config-tiny.jsonc;

  # Superfile
  home.file.".config/superfile/config.toml".text = builtins.readFile ./dotfiles/superfile/config.toml;
  home.file.".config/superfile/hotkeys.toml".text = builtins.readFile ./dotfiles/superfile/hotkeys.toml;

  # Desktop files
  home.file.".local/share/applications/screenshotmonitor.desktop".source = ./dotfiles/desktop-files/screenshotmonitor.desktop;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
