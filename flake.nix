{
  description = "NixOS on Banana Pi M1";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    #nixpkgs-mod.url = "github:llamato/nixpkgs/master";
    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default";
  };

  outputs = {flakelight, ...} @ inputs:
    flakelight ./. ({
        lib,
        outputs,
        ...
      } @ flArgs: let
        systems = import inputs.systems;
      in {
        inherit inputs systems;
        
        outputs.packages = let
          pkgs' = outputs.nixosConfigurations.image.pkgs;
          inherit (outputs.nixosConfigurations.image.config.system) build;
        in
          lib.genAttrs systems (
            _system: {
              inherit (build) toplevel sdImage;
              uboot = pkgs'.ubootBananaPi;
              manpage = build.manual.nixos-configuration-reference-manpage;
              default = build.toplevel;
            }
          );
        outputs.repl = flArgs // {inherit inputs;};
        formatter = pkgs: pkgs.coreutils.overrideAttrs (prev: {meta = prev.meta // {mainProgram = "true";};});
      });
}
