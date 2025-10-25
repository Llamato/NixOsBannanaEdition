{
  description = "NixOS on Banana Pi M1";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    gcalc = {
      url = "github:llamato/gcalc";
    };

    gcrypt = {
      url = "github:llamato/gcrypt";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.51.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    easymotion = {
      url = "github:zakk4223/hyprland-easymotion";
      inputs.hyprland.follows = "hyprland";
    };

    hyprsplit = {
      url = "github:shezdy/hyprsplit";
      inputs.hyprland.follows = "hyprland";
    };

    split-monitor-workspaces = {
      inputs.hyprland.follows = "hyprland";
      url = "github:Duckonaut/split-monitor-workspaces";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... } @inputs: {
    nixosConfigurations = {
      bpi = nixpkgs.lib.nixosSystem {
      system = "armv7l-linux";
      specialArgs = { 
          inherit inputs;
          #buildPlatform = "armv7l-linux";
          buildPlatform = builtins.currentSystem or "x86_64-linux";
      };
        modules = [ 
          ./nix/nixosConfigurations/bpi.nix
          #./nix/nixosModules/hyprland.nix
          ./nix/nixosModules/lxde.nix
        ];
      };
    };
  };
}