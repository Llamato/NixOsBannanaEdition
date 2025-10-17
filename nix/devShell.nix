pkgs: {
  packages = [
    pkgs.stylua
    pkgs.nil # nix lsp

    # for crankfile dev/debug support
    pkgs.lua-language-server
    pkgs.lua5_4
    pkgs.lua5_4.pkgs.inspect # for debugging
  ];
}
