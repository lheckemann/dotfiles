{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
  lock = callPackage ./locker {};
  i3Configured = lib.hiPrio (
    runCommand "i3-with-config" {
      nativeBuildInputs = [ makeWrapper ];
    } ''
      mkdir -p $out/bin
      mkdir -p $out/etc
      cp ${./i3/config} $out/etc/i3.conf
      cp ${./i3/status.conf} $out/etc/i3status.conf
      makeWrapper ${i3}/bin/i3 $out/bin/i3 --add-flags "-c ~/.nix-profile/etc/i3.conf"
      makeWrapper ${i3status}/bin/i3status $out/bin/i3status --add-flags '-c ~/.nix-profile/etc/i3status.conf'
      install -Dm0755 ${./status.sh} $out/bin/wrap-i3status
    ''
  );
  xsession = writeScriptBin "xsession" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=${gnome3.adwaita-icon-theme}/share/icons \
           SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
           EDITOR='emacsclient -a "" -n'
    xrdb -merge - <<EOF
    Xcursor.theme: Adwaita
    EOF
    [[ -r $HOME/.background-image ]] && ${feh}/bin/feh --bg-max $HOME/.background-image
    ${dunst}/bin/dunst \
        -padding 15 \
        -horizontal_padding 20 \
        -dmenu ${dmenu}/bin/dmenu \
        -fn "Liberation Sans 12" \
        -context_key XF86LaunchB &
    exec ${i3Configured}/bin/i3
  '';
in (callPackage ./default.nix {}) // {
  mupdf = mupdf.overrideAttrs (o: {
    patches = (o.patches or []) ++ [./0001-x11-accept-commands-on-stdin-as-well.patch];
  });
  inherit
    i3Configured
    lock
    xsession
    ;
  inherit (pkgs)
    alacritty
    arandr
    audacity
    chromium
    compton
    dfeet
    dillo
    dmenu
    endless-sky
    evince
    feh
    firefox
    gimp
    gitg
    graphicsmagick
    gnupg # Override the non-graphical one from default.nix
    i3status
    inkscape
    keepassxc
    kvm
    libreoffice
    mpv
    mumble
    noto-fonts
    noto-fonts-emoji
    pavucontrol
    redshift
    rustracer
    scrot
    socat
    sqliteman
    tdesktop
    thunderbird
    vlc
    xidlehook
    xsel
    zeal
    ;
  inherit (pkgs.xorg) xbacklight;
  i3 = lib.lowPrio i3;
  switch-user = writeScriptBin "switch-user" ''
    ${dbus}/bin/dbus-send --print-reply --system --dest=org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter
  '';
  emacs = callPackage ./emacs.nix {};
  reconfigure = writeShellScriptBin "reconfigure" ''
    nix-env -f ~/dotfiles/graphical.nix -ir -I nixpkgs=$HOME/nixpkgs-live
  '';
  st = st.override {
    patches = [ ./st-font.patch ./st-terminfo-cursor-shape.patch ];
  };
}
