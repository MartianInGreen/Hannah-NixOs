{
  description = "NixOS configuration with NVIDIA drivers, GNOME, and custom packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nix-flatpak, nixpkgs, home-manager, nixos-cosmic, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
      overlays = [
        (final: prev: {
          waveterm = final.callPackage ./packages/waveterm.nix {};
          devtoys = final.callPackage ./packages/devtoys.nix {};
          superfile = final.callPackage ./packages/superfile.nix {};
          cosmic-clipboard = final.callPackage ./packages/cosmic-clipboard.nix {};
        })
        nixos-cosmic.overlays.default
      ];
    };
  in {
    nixosConfigurations = {
      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nix-flatpak.nixosModules.nix-flatpak

          ./configuration.nix
          ./devices/laptop-hp.nix
          ./desktops/gnome.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hannah = { config, ... }: import ./home.nix { inherit config pkgs; isServer = false; };
          }
        ];
        specialArgs = { inherit pkgs; };
      };
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nix-flatpak.nixosModules.nix-flatpak

          # Basic Configuration
          ./configuration.nix
          # Device Configuration
          ./devices/desktop.nix
          # WM Configuration
          ./desktops/gnome.nix
          ./desktops/gnome-wayland-addon.nix
          # Profiles
          ./profiles/gaming.nix
          ./profiles/ai.nix
          ./profiles/dev.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hannah = { config, ... }: import ./home.nix { inherit config pkgs; isServer = false; };
          }
        ];
        specialArgs = { inherit pkgs; };
      };
      desktop-cosmic = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default

          nix-flatpak.nixosModules.nix-flatpak

          # Basic Configuration
          ./configuration.nix
          # Device Configuration
          ./devices/desktop.nix
          # WM Configuration
          ./desktops/cosmic.nix
          # Profiles
          ./profiles/gaming.nix
          ./profiles/ai.nix
          ./profiles/dev.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hannah = { config, ... }: import ./home.nix { inherit config pkgs; isServer = false; };
          }
        ];
        specialArgs = { inherit pkgs; };
      };
      server = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          nix-flatpak.nixosModules.nix-flatpak

          ./configuration.nix
          ./devices/server.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.hannah = { config, ... }: import ./home.nix { inherit config pkgs; isServer = true; };
          }
        ];
        specialArgs = { inherit pkgs; };
      };
    };
  };
}
