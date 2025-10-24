{ config, pkgs, lib, modulesPath, ... }: let 
        sshKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE5gfkj8BLRw6KBWJhlKbr3PDPzEunDrLH70cLI2VQhlVNccUlcYebS8LdVkPyyzGh9xaSmn0zkIZq7kGZAeOy3rlSQz/sFQ0zRicfb6uD2GVndn51drJQPthdxypGhl24JClyN0knhrils4angEMZFkq+UZr8ku7/wJxiXSbiiO5TUU0L26Ijk2kCEcHlRrjMyANMznE3UYffqcwlLOd+udqOrPwC9Hk/DdyDRzLsXcPVE+6prgFg+vx5OEdvdAO6QuO1S1zxKq9hRDJ7mELEmWjmHjuvfEY+ZVRUaP7dFAejyr+I3GFshhZu7OkGtD5Gd0SF5P4jNzGobcEYaJsJ tina" ];
      in {

      #imports = [ "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix" ];

      # Build config
      nixpkgs.buildPlatform.system = "x86_64-linux";
      #nixpkgs.buildPlatform.system = "armv7l-linux";
      #boot.kernelPackages = pkgs.linuxPackages_latest;
      
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

      nix = {
        # Clear nix cache every day
        gc = {
          automatic = true;
          dates = "daily";
          options = "--delete-older-than 7d";
        };

        # Ssh key setup
        settings = {
          experimental-features = ["nix-command" "flakes"];
          trusted-users = sshKeys;
          extra-substituters = [
            "http://192.168.3.220"
          ];
          extra-trusted-public-keys = [
            "192.168.3.220:svcgrlHBnsczfJT3AbrYfjSmobvGrkn4qAio6lZ6xqg="
          ];
        };
      };
      users.users.root.openssh.authorizedKeys.keys = sshKeys;
      users.users.tina.openssh.authorizedKeys.keys = sshKeys;
      
      # Networking config
      networking.hostName = "bpi";

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

    hardware.enableRedistributableFirmware = true;
    hardware.opengl.enable = true;


  # Do not change !!!
  # Target Platform
  #hardware.deviceTree.enable = false;
  nixpkgs.hostPlatform.system = "armv7l-linux";
  nixpkgs.config.allowUnsupportedSystem = true;

  boot = {
    supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };

    initrd = {
      includeDefaultModules = true;
      availableKernelModules = [ "mmc_block" ];
      kernelModules = [
        #"fbcon"           # Framebuffer console
        "font"            # Font support
        #"bitblit"         # Bit blitting operations (Not found)
        #"softcursor"      # Software cursor
        #"sun4i_fb"        # Banana Pi specific framebuffer driver (Not found) (Not found)
      ];
    };

    kernelModules = [ 
      "i2c-dev" "sunxi-ephy"
      #"sun4i-drm" "drm_kms_helper" "lima"
      #"fbcon"
      "sun4i_fb"

    ];

    kernelParams = [
      "console=tty1"                    # Primary console on HDMI
      "fbcon=font:TER16x32"
      "fbcon=rotate:0"
      
      # Disable other outputs
      "video=Composite-1:d"
      "video=composite:d"
      "video=LVDS-1:d"
      "video=DSI-1:d"
      
      "consoleblank=0"
    ];
    

    #Console does not work with the direct rendering manager for some reason... It does in initial img.
    blacklistedKernelModules = [
      "drm" 
      "sun4i_drm" 
      "sun8i_drm_hdmi" 
      "drm_kms_helper"
      "sun4i_tv"
      "sun4i_lcd"
      "sun4i_drm_lcd"
      "lima"
    ];
  };

  console = {
    enable = true;
    earlySetup = true;
    keyMap = "us";
    #font = "${pkgs.terminus_font}/share/consolefonts/ter-u16n.psf.gz"; #Default
    # Try different large fonts:
    
    # Option 1: Very large (28px height)
    font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
    
    # Option 2: Large (24px height) 
    # font = "${pkgs.terminus_font}/share/consolefonts/ter-u24n.psf.gz";
    
    # Option 3: Extra large (32px height)
    # font = "${pkgs.terminus_font}/share/consolefonts/ter-u32n.psf.gz";
    
    # Option 4: Sun console (very readable)
    # packages = [ pkgs.sunpcfont ];
    # font = "sun12x22";
  };

  systemd.services."getty@tty1" = {
    enable = true;
    after = [ "systemd-vconsole-setup.service" "systemd-udev-settle.service" ];
    wants = [ "systemd-vconsole-setup.service" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = 1;
    };
  };

  fileSystems."/" = lib.mkForce {
    device = "/dev/mmcblk0p2";
    fsType = "ext4";
  };

  networking.useNetworkd = true;
  systemd.network = {
      enable = true;
      networks."99-ethernet-default-dhcp" = {
        matchConfig.Name = "end0";
        networkConfig = {
          DHCP = "yes";
          MulticastDNS = true;
        };
        linkConfig = {
          RequiredForOnline = "routable";
          ActivationPolicy = "always-up";
        };
      };
    };
    systemd.services.bring-up-end0 = {
      description = "Bring up end0 network interface";
      after = ["network.target" "systemd-networkd.service"];
      wants = ["network.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkgs.iproute2}/bin/ip link set end0 up";
      };
      wantedBy = ["multi-user.target"];
    };

  system.stateVersion = "25.05";
}
