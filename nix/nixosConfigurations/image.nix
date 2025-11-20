{
  inputs,
  outputs,
  ...
}: {
  system = "armv7l-linux";
  modules = [
    outputs.nixosModules.default
    ({
      config,
      pkgs,
      lib,
      ...
    }: let
        sshKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" ];
      in { 
      
      # Lets make an sd image
      sdImage.compressImage = true;
      documentation = {
        doc.enable = false;
        info.enable = false;
        nixos.includeAllModules = true;
      };
     
      # Locale config
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";

      # Enable sound with pipewire.
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      /*services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };*/

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.tina = {
        isNormalUser = true;
        description = "llamato";
        extraGroups = [ "networkmanager" "wheel" "input" ];
        initialPassword = "llamato";
        packages = with pkgs; [  
          sl
          fastfetch
          hyfetch
          abaddon
          pwvucontrol
          ffmpeg
          discordo
          
          # Web browsers
          lynx
          #links2
          browsh
          dillo
        ];
      };
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
            /*(final: prev: {
              xwayland = prev.runCommand "xwayland-disabled" {} 
                "echo 'xwayland not available on armv7l' > $out";
            })*/
        (final: prev: {
      dillo = prev.dillo.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
          final.buildPackages.stdenv.cc.bintools
          final.buildPackages.binutils
          final.buildPackages.gcc  # Add host GCC
          final.buildPackages.python3  # Ensure Python is available
          final.buildPackages.pkg-config
        ];
          RUST_BACKTRACE=''full'';
          preConfigure = ''
            export RUST_BACKTRACE=1
            export HOST_AR=${final.buildPackages.stdenv.cc.bintools}/bin/ar
            echo "Using host AR: $HOST_AR"
          '';
          });
        })
      ];

      services.xserver = {
        enable = false;
        # Minimal setup - just X server, no desktop
        desktopManager = {
          xterm.enable = true;
        };
        displayManager.startx.enable = true;
        windowManager.mwm.enable = true;
        libinput.enable = true;
        /*config = ''
      Section "ServerFlags"
          Option "AutoAddDevices" "false"
          Option "AllowEmptyInput" "false"
      EndSection

      Section "ServerLayout"
          Identifier "Layout0"
          Screen 0 "Screen0"
          InputDevice "Mouse0" "CorePointer"
          InputDevice "Keyboard0" "CoreKeyboard"
      EndSection

      Section "InputDevice"
          Identifier "Keyboard0"
          Driver "kbd"
          Option "XkbLayout" "us"
      EndSection

      Section "InputDevice"
          Identifier "Mouse0"
          Driver "mouse"
          Option "Protocol" "auto"
          Option "Device" "/dev/input/event0"
          Option "Emulate3Buttons" "no"
          Option "ZAxisMapping" "4 5"
      EndSection

      Section "Monitor"
          Identifier "Monitor0"
          Option "DPMS" "false"
      EndSection

      Section "Device"
          Identifier "Device0"
          Driver "modesetting"
          Option "AccelMethod" "none"
      EndSection

      Section "Screen"
          Identifier "Screen0"
          Device "Device0"
          Monitor "Monitor0"
          DefaultDepth 24
      EndSection
    '';*/
      };

      hardware.graphics.enable = true;
      environment.systemPackages = with pkgs; [
        git
        wget
        btop
        labwc
        alacritty
        mesa
        mesa-demos
        motif
        xorg.xset
        xorg.xsetroot
        xorg.xmodmap
        xorg.xinput
        xorg.xev
      ];

      # Clear nix cache every day
      nix = {
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };

        # Mostly ssh key setup
        settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = sshKeys;
        };
      };
      users.users.root.openssh.authorizedKeys.keys = sshKeys; 
      users.users.tina.openssh.authorizedKeys.keys = sshKeys;

      hardware.enableRedistributableFirmware = true;
      
      # Networking config
      networking = {
        hostName = "bpi";
        /*firewall.enable = false;
        useDHCP = true;*/
        useNetworkd = true;
      };
      
      services = {
        openssh = {
          enable = true;
            settings = {
              KbdInteractiveAuthentication = lib.mkDefault false;
              PasswordAuthentication = lib.mkDefault true;
              PermitRootLogin = "prohibit-password";
            };
        };
      };


      boot = {
        kernelModules = ["i2c-dev" "sunxi-ephy"];
        kernelParams = [
          "sunxi_emac.phy_interface=1"
          "sunxi_emac.rx_delay=3"
          "sunxi_emac.tx_delay=3"
        ];
      };

      # System Config (Only change for redeploys and new deployments)
      system.stateVersion = "25.05";
    })
  ];
}