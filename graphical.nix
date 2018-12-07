{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
  i3Configured = pkgs.callPackage ./i3.nix {};
  lock = callPackage ./locker {};
  xsession = writeScriptBin "xsession" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=/run/current-system/sw/share/icons \
           SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh
    ${pkgs.redshift}/bin/redshift -l 48:11 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-max $HOME/.background-image
    ${pkgs.dunst}/bin/dunst \
        -padding 15 \
        -horizontal_padding 20 \
        -dmenu ${pkgs.dmenu}/bin/dmenu \
        -fn "Liberation Sans 12" \
        -context_key XF86LaunchB &
    exec ${i3Configured}/bin/i3
  '';
  mupdf = pkgs.mupdf.overrideAttrs (o: {
    patches = (o.patches or []) ++ [./0001-x11-accept-commands-on-stdin-as-well.patch];
  });
in import ./default.nix // {
  inherit
    i3Configured
    lock
    mupdf
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
    keepassx2
    kvm
    libreoffice
    mpv
    mumble
    noto-fonts
    noto-fonts-emoji
    pavucontrol
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
  i3 = pkgs.lib.lowPrio pkgs.i3;
  inherit (pkgs.gnome3) eog dconf nautilus networkmanagerapplet;
  switch-user = pkgs.writeScriptBin "switch-user" ''
    ${pkgs.dbus}/bin/dbus-send --print-reply --system --dest=org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter
  '';
  emacs = pkgs.callPackage ./emacs.nix {};
  reconfigure = pkgs.writeShellScriptBin "reconfigure" ''
    nix-env -f ~/dotfiles/graphical.nix -ir -I nixpkgs=$HOME/nixpkgs-live
  '';
  st = pkgs.st.override {
    patches = [ ./st-font.patch ];
  };
}
