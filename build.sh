#!/bin/sh
nix build .#sdImage
yes | zstd -d result/sd-image/nixos-image-sd-card-25.05.20251016.98ff3f9-armv7l-linux.img.zst -o ./nixos-image-sd-card-25.05.20251016.98ff3f9-armv7l-linux.img
