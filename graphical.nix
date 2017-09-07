let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) writeScriptBin stdenv;
  i3Configured = import ./i3.nix { inherit pkgs; };
  lock = import ./locker;
  xsession = writeScriptBin "xsession" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=/run/current-system/sw/share/icons
    ${pkgs.redshift}/bin/redshift -l 56:-4 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-max $HOME/.background-image
    ${pkgs.dunst}/bin/dunst \
        -padding 15 \
        -horizontal_padding 20 \
        -dmenu ${pkgs.dmenu}/bin/dmenu \
        -fn "Liberation Sans 24" \
        -context_key XF86LaunchB &
    exec ${i3Configured}/bin/i3
  '';
  polybar = pkgs.polybar.override {
    i3Support = true;
  };
  polybarConfigured = writeScriptBin "polybar" ''
    #!${stdenv.shell}
    exec ${polybar}/bin/polybar -c ${./polybar.ini} "$@"
  '';
  mupdf = pkgs.mupdf.overrideAttrs (o: {
    patches = (o.patches or []) ++ [./0001-x11-accept-commands-on-stdin-as-well.patch];
  });
in import ./default.nix // {
  inherit
    i3Configured
    lock
    mupdf
    polybarConfigured
    xsession
    ;
  inherit (pkgs)
    arandr
    audacity
    chromium
    compton
    dfeet
    dia
    endless-sky
    evince
    firefox
    gimp
    gitg
    gnupg # Override the non-graphical one from default.nix
    keepassx2
    kvm
    libreoffice
    mpv
    mumble
    noto-fonts
    noto-fonts-emoji
    pavucontrol
    scrot
    thunderbird
    vlc
    xsel
    zeal
    ;
    i3 = pkgs.lib.lowPrio pkgs.i3;
    inherit (pkgs.gnome3) eog dconf nautilus;
    inherit (pkgs.idea) idea-community;
}
