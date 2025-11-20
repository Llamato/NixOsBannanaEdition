# Stub out some packages that are included by NixOS, impossible to
# override, and definitely useless on this system - replace them with
# an empty package
final: _prev: let
  stub = final.emptyDirectory.overrideAttrs (prev': {
    # xfsprogs.bin is called somewhere
    passthru = (prev'.passthru or {}) // {bin = final.emptyDirectory;};
  });
in {
  efivar = stub; # does not (cross)build
  efibootmgr = stub; # depends on efivar
  xfsprogs = stub;
  #xwayland = stub;
}
