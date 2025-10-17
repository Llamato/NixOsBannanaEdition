{inputs, ...}: {
  pkgs,
  lib,
  modulesPath,
  ...
}: let
  buildSystem = "x86_64-linux"; # FIXME: parameterize it somehow?
  bananapiDtb = pkgs.runCommand "sun7i-a20-bananapi-m1.dtb" {} ''
    cp ${./dtbs/sun7i-a20-bananapi.dtb} $out
  '';
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
    #boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_15;
    boot = {
      #kernelPackages = lib.mkForce pkgs.linuxPackages;
      /*kernelPatches = [
      {
        name = "enable-nixos-required-features";
        patch = null;
          structuredExtraConfig = with lib.kernel; {
            DEVTMPFS = yes;
            CGROUPS = yes;
            INOTIFY_USER = yes;
            SIGNALFD = yes;
            TIMERFD = yes;
            EPOLL = yes;
            NET = yes;
            SYSFS = yes;
            PROC_FS = yes;
            FHANDLE = yes;
            CRYPTO_USER_API_HASH = yes;
            CRYPTO_HMAC = yes;
            CRYPTO_SHA256 = yes;
            DMIID = yes;
            AUTOFS4_FS = yes;
            TMPFS_POSIX_ACL = yes;
            TMPFS_XATTR = yes;
            SECCOMP = yes;
            TMPFS = yes;
            BLK_DEV_INITRD = yes;
            BINFMT_ELF = yes;
            UNIX = yes;
        };
      }
    ];*/

      initrd = {
        includeDefaultModules = true;
        availableKernelModules = ["mmc_block"];
      };
      supportedFilesystems = lib.mkForce [ "btrfs" "cifs" "f2fs" "jfs" "ntfs" "reiserfs" "vfat" "xfs" ];
    };
    hardware.deviceTree = {
      enable = true;
      #dtbSource = "${bananapiDtb}";
      #name = "sun7i-a20-bananapi-m1.dtb";
    };

    sdImage = { 
      postBuildCommands = ''
      dd if=${pkgs.ubootBananaPi}/u-boot-sunxi-with-spl.bin of=$img bs=1024 seek=8 conv=notrunc
    '';
      populateRootCommands = "";
    };

    # FIXME: is it card2 or card1? or can we somehow search in here?
    /*services.udev.extraRules = ''
      SUBSYSTEM=="ddcci", KERNEL=="ddcci*", ENV{DRM_CONNECTOR_NAME}="card[12]-HDMI-A-1"
    '';*/
  };
}
