# https://github.com/nix-community/flakelight/issues/22#issuecomment-2224975550
{
  lib,
  flakelight,
  moduleArgs,
  ...
}:
lib.mapAttrs (_: v: v moduleArgs) (flakelight.importDir ./.)
