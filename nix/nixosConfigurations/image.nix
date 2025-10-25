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
      security.rtkit.enable = true;

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.tina = {
        isNormalUser = true;
        description = "llamato";
        extraGroups = [ "networkmanager" "wheel" ];
        initialPassword = "llamato";
        packages = with pkgs; [  
          sl
          fastfetch
        ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        git
        wget
        btop
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
        /*xserver = { #23.xx and earlier only
          enable = true;
          displayManager.sddm.enable = true;
          desktopManager.plasma5.enable = true; # 5 for 23.xx
        };*/
        
        #25.05 only
        displayManager.sddm.enable = true;
        desktopManager.plasma6.enable = true;
        
        pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };
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
          # Alternative parameters to try
          #"libahci.ignore_sss=1"
          #"ahci.sunxi_enable_0=1"
        ];
      };

      system.activationScripts.setupDevConfig = let
        flakeFiles = pkgs.stdenv.mkDerivation {
          name = "bananapi-flake-files";
          src = ../../dotfiles/.;
          installPhase = ''
            mkdir -p $out
            cp -R ./* $out/
            rm -f $out/result*
          '';
        };
      in ''
        mkdir -p /etc/nixos
        cp -R ${flakeFiles}/* /etc/nixos/
        chown -R root:root /etc/nixos
        chmod -R u+w /etc/nixos
      '';

      # System Config (Only change for redeploys and new deployments)
      system.stateVersion = "25.05";
    })
  ];
}