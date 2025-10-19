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

      #System Config
      system.stateVersion = "25.05";
    
      # locale config
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

      # Lets make an sd image
      sdImage.compressImage = true;
      documentation = {
        doc.enable = false;
        info.enable = false;
        nixos.includeAllModules = true;
      };

      nix = {
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };

        settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = sshKeys;
        };
      };
      users.users.root.openssh.authorizedKeys.keys = sshKeys;

      hardware.enableRedistributableFirmware = true;
      networking = {
        hostName = "bpi";
        firewall.enable = false;
      };
      systemd.network.networks."99-ethernet-default-dhcp".networkConfig.MulticastDNS = true;

      services = {
        /*xserver = { #23.xx and earlier only
          enable = true;
          displayManager.sddm.enable = true;
          desktopManager.plasma5.enable = true; # 5 for 23.xx
        };*/
        
        #25.05 only
        /*displayManager.sddm.enable = true;
        desktopManager.plasma6.enable = true;*/
        
        /*pulseaudio.enable = false;
        pipewire = {
          enable = true;
          alsa.enable = true;
          alsa.support32Bit = true;
          pulse.enable = true;
        };*/
        openssh = {
          enable = true;
            #authorizedKeysFiles = lib.mkForce [""];
            settings = {
              KbdInteractiveAuthentication = lib.mkDefault false;
              PasswordAuthentication = lib.mkDefault false;
              PermitRootLogin = lib.mkDefault "yes";
            };
        };
      };
      #systemd.services.ha-ddc.environment.RUST_LOG = "info,ha_ddc=debug,ha_discovery_config=debug";

      
      #ddcci-driver.enable = true;
      boot = {
        kernelModules = ["i2c-dev"];
      };
    })
  ];
}