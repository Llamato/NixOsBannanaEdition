{inputs, ...}: {
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  buildSystem = "x86_64-linux"; # FIXME: parameterize it somehow?
in {
  imports = ["${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix"];
  config = {
    nixpkgs = {
      config.allowUnsupportedSystem = true;
      hostPlatform.system = "armv7l-linux";
      buildPlatform.system = buildSystem;
      overlays = [inputs.self.overlays.default];
    };

    nix.settings.eval-system = pkgs.system;

    boot = {
      initrd = {
        includeDefaultModules = true;
        availableKernelModules = ["mmc_block"];
      };
      supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    };

    hardware.deviceTree.enable = false; #Comes with uboot

    sdImage = { 
      postBuildCommands = ''
      dd if=${pkgs.ubootBananaPi}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
      populateRootCommands = "";
    };
  };
}
