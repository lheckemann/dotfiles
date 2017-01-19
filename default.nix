let
  pkgs = import <nixpkgs> {};
  neovim = import ./neovim.nix { inherit pkgs; };
  redshift = pkgs.redshift;
  i3 = import ./i3.nix { inherit pkgs; };
  xsession = pkgs.writeScriptBin "xsession" ''
    #!${pkgs.stdenv.shell}
    ${redshift}/bin/redshift -l 56:-4 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-scale $HOME/.background-image
    ${pkgs.dunst}/bin/dunst \
        -padding 5 \
        -horizontal_padding 10 \
        -dmenu ${pkgs.dmenu}/bin/dmenu \
        -context_key XF86LaunchB &
    exec ${i3}/bin/i3
  '';
in
  pkgs.symlinkJoin {
    name = "linus-env";
    paths = [ neovim xsession ];
  }
