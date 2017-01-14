let
  pkgs = import <nixpkgs> {};
  neovim = import ./neovim.nix { inherit pkgs; };
  redshift = pkgs.redshift;
  i3 = import ./i3.nix { inherit pkgs; };
  xsession = pkgs.writeScriptBin "xsession" ''
    #!${pkgs.stdenv.shell}
    ${redshift}/bin/redshift -l 55:4 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-scale $HOME/.background-image
    exec ${i3}/bin/i3
  '';
in
  pkgs.symlinkJoin {
    name = "linus-env";
    paths = [ neovim xsession ];
  }
