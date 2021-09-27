{ nixpkgs }:
{
  sources = import ./sources.nix { pkgs = import nixpkgs {}; };
}
