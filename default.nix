{ sources ? import ./nix/sources.nix { }
, nixpkgs ? sources.nixpkgs
, emacs-overlay ? sources.emacs-overlay
, systems ? null
}:
let
  pkgs = system: import nixpkgs {
    inherit system;
    overlays = [
      (import ./overlay.nix)
      (import emacs-overlay)
    ];
  };
  pkgsNative = pkgs builtins.currentSystem;
in
if systems == null
then pkgsNative.linus-profiles
else pkgsNative.lib.genAttrs systems (system: (pkgs system).linus-profiles)
