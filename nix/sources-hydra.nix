{ nixpkgs }:
let lib = import (nixpkgs + "/lib");
in lib.mapAttrs (_: value: value.outPath) (import ./sources.nix { pkgs = import nixpkgs {}; });
