{
  outputs,
  ...
}: 
let
  remotebuildUsers = [ "tina" ]; # Replace with the appropriate users on your client machine
  sshKeyFile = "/home/tina/.ssh/remotebuild"; # The ssh keyfile containing the private key of the remotebuild user on the client system
in
{
  system = "armv7l-linux";
  modules = [
    outputs.nixosModules.default
    ({
      pkgs,
      lib,
      ...
    }: let
        sshKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" ];
        password = "llamato";
      in { 
      
      # Lets make an sd image
      sdImage.compressImage = true;
      documentation = {
        doc.enable = false;
        info.enable = false;
        nixos.includeAllModules = true;
      };

      nix = {
        settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = sshKeys;
          distributedBuilds = true;
          builders-use-substitutes = true;
        };
      };

      # Nixpkgs configuration
      nixpkgs.config.allowUnfree = true;
      nixpkgs.overlays = [
        (final: prev: {
      dillo = prev.dillo.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [
          final.buildPackages.stdenv.cc.bintools
          final.buildPackages.binutils
          final.buildPackages.gcc
          final.buildPackages.python3
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

      boot = {
        kernelModules = ["i2c-dev" "sunxi-ephy"];
        kernelParams = [
          "sunxi_emac.phy_interface=1"
          "sunxi_emac.rx_delay=3"
          "sunxi_emac.tx_delay=3"
        ];
      };

      hardware = {
        enableRedistributableFirmware = true;
        graphics.enable = true;
      };
     
      # Locale config
      time.timeZone = "Europe/Berlin";
      i18n.defaultLocale = "en_US.UTF-8";

      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users = {
        tina = {
          isNormalUser = true;
          description = "llamato";
          extraGroups = [ "networkmanager" "wheel" "input" ];
          initialPassword = password;
          openssh.authorizedKeys.keys = sshKeys; 
        };
        root = {
          initialPassword = password;
          openssh.authorizedKeys.keys = sshKeys;
        };
      };

      environment.systemPackages = with pkgs; [
        git
        wget
        btop
        sl fastfetch hyfetch
        ethtool mtr
        minicom picocom
      ];

      services = {
        openssh = {
          enable = true;
            settings = {
              KbdInteractiveAuthentication = lib.mkDefault false;
              PasswordAuthentication = lib.mkDefault true;
              PermitRootLogin = "yes"; # Debug / dev !!!
            };
        };
      };
      
      # Networking config
      networking = {
        hostName = "nixbpi";
        useNetworkd = true;
      };

      # System Config (Only change for redeploys and new deployments)
      system.stateVersion = "25.05";
    })
  ];
}