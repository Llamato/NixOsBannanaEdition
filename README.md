### NixOs ported to the banana pi m1 of 2014. 

The goal of this project is to evaluate the nix package management system in an embedded systems context.
The idea here is to generate img images intended for SD cards using nix. This allows for rapid deployment of many cheap pis with completely identical configuration.
In addition to rapid, reliable and reproducible deployment the nix system allows for synchronized updates across a fleet of PIs using a shared configuration repo. For an example of such a repo see:   https://github.com/Llamato/dotfiles

use `build.sh` to build an sd card image containing an armv7-l NixOS instillation with the configuration declared in ./nix/nixosConfigurations

/image.nix applied.

Please note this project is highly experimental and not meant for any production with any form of stakes involved

Kind regards
Llamato / Tina
