rec {
  self = builtins.getFlake (builtins.toString ./.);
  system = builtins.currentSystem;
  nixosConfiguration = self.nixosConfigurations.image;
  inherit (nixosConfiguration) config pkgs lib;
  packages = self.packages.${system};
}
