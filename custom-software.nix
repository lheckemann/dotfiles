let
  pkgs = import <nixpkgs> {};
  neovim = import ./neovim.nix { inherit pkgs; };
  i3 = import ./i3.nix { inherit pkgs; };
in
  pkgs.symlinkJoin {
    name = "linus-env";
    paths = [ neovim i3 ];
  }
