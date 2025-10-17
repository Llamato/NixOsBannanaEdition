{
  inputs,
  outputs,
  ...
}: {
  system = "armv7l-linux";
  modules = [
    outputs.nixosModules.default # baseline
    #inputs.lix-module.nixosModules.default
    #inputs.ha-linux-desktop.nixosModules.default

    ({
      config,
      pkgs,
      lib,
      ...
    }: {
      # actual configuration
      system.stateVersion = "23.05";
      
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
          neofetch #23.05
        ];
      };

      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;
      environment.systemPackages = with pkgs; [
        git
        wget
        btop
      ];
      # end of  config

      # Lets make an sd image
      sdImage.compressImage = false;
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
        settings = {experimental-features = ["nix-command" "flakes"];};
      };

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
          #permitRootLogin = true;
          # authorizedKeysFiles = lib.mkForce ["/etc/ssh/authorized_keys.d/%u"];
          # settings = {
          #   KbdInteractiveAuthentication = lib.mkDefault false;
          #   PasswordAuthentication = lib.mkDefault false;
          #   PermitRootLogin = lib.mkDefault "yes";
          # };
        };
      };
      #systemd.services.ha-ddc.environment.RUST_LOG = "info,ha_ddc=debug,ha_discovery_config=debug";

      /*users.users.root.openssh.authorizedKeys.keys = [
      ];*/

      #ddcci-driver.enable = true;
      boot = {
        kernelModules = ["i2c-dev"];
      };
    })
  ];
}
