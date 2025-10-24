{config, lib, pkgs, inputs, ...}: let
  hyprland = inputs.hyprland.packages.${pkgs.system}.hyprland;
  hyprsplit = inputs.hyprsplit.packages.${pkgs.system}.hyprsplit;
  easymotion = inputs.easymotion.packages.${pkgs.system}.hyprland-easymotion;
  xdg-desktop-portal-hyprland = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  split-monitor-workspaces = inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces;
  hyprtrails = inputs.hyprland-plugins.packages.${pkgs.system}.hyprtrails; #As of yet unused

in {
  imports = [
    inputs.hyprland.nixosModules.default
  ];

  programs.hyprland = {
    enable = true;
    package = hyprland;
    xwayland.enable = true;
    portalPackage = xdg-desktop-portal-hyprland;
    plugins = [split-monitor-workspaces hyprsplit easymotion];
  };

  fonts.packages = with pkgs; [
    font-awesome
    nerd-fonts.jetbrains-mono
  ];

  environment.systemPackages = with pkgs; [
    clipse wl-clipboard
    grim slurp ffmpegthumbnailer
    waybar dunst anyrun kitty nautilus imv
    gtk-engine-murrine gnome-themes-extra
    killall xorg.xrandr libnotify playerctl
    kdePackages.breeze kdePackages.breeze-icons qt6ct
    hyprpaper hypridle hyprlock hyprpicker hyprpolkitagent
    adwaita-icon-theme phinger-cursors tokyonight-gtk-theme 
    pwvucontrol networkmanagerapplet nwg-look
  ];

services.displayManager.sddm.enable = true;
}