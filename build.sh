#!/bin/sh
nix build .#sdImage
yes | zstd -d result/sd-image/nixos-image-sd-card-*-armv7l-linux.img.zst -o ./nixos-image-sd-card-armv7l-linux.img
