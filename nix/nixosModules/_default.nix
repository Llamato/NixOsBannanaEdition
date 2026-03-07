{inputs, ...}: {
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  buildSystem = "x86_64-linux"; # FIXME: parameterize it somehow?
  #buildSystem = "armv7l-linux"; # Somehow now completely broken....
in {
  imports = ["${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"];
  config = {
    nixpkgs = {
      config = {
        allowUnsupportedSystem = true;
        allowEmulation = true;
      };
      hostPlatform.system = "armv7l-linux";
      buildPlatform.system = buildSystem;
      overlays = [inputs.self.overlays.default];
    };

    nix.settings = {
    eval-system = pkgs.system;
    sandbox = false;
    experimental-features = [ "nix-command" "flakes" ];
    distributedBuilds = true;
  };

    boot = {
      initrd = {
        includeDefaultModules = true;
        availableKernelModules = ["mmc_block"];
      };
      supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    };

    hardware.deviceTree.enable = false;
    
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

    sdImage = { 
      postBuildCommands = ''
      dd if=${pkgs.ubootBananaPi}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
      populateRootCommands = "";
    };
  };
}
