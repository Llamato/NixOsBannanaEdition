{ config, lib, pkgs, inputs, buildPlatform, ... }:
let
  unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in
{
  nixpkgs = {
    buildPlatform.system = buildPlatform;
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
      checkMeta = false;
      allowBroken = true;
      allowInsecure = true;
    };
  };

  nix.extraOptions = ''
    # Disable all validation
    allowed-uris = *
    allow-import-from-derivation = true
    restrict-eval = false
    system-features = benchmark big-parallel kvm nixos-test
    
    # Force existing packages
    keep-failed = true
    keep-going = true
  '';

  environment.systemPackages = with pkgs; [
    wayland
    wayland-utils
  ] ++ (with unstable; [
    sway
    #swaylock
    #swayidle
    #waybar
    alacritty
  ]);
  
  programs.sway = {
    enable = true;
    package = unstable.sway;
  };
}