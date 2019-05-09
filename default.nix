{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
  confs = linkFarm "confs" [
    { name = "etc/tmux.conf"; path = "${./tmux.conf}"; }
  ];
  tmuxConfigured = writeScriptBin "tmux" ''
    #!${stdenv.shell}
    exec ${tmux}/bin/tmux -f ~/.nix-profile/etc/tmux.conf -S "/run/user/$(id -u)/tmux.1000" "$@"
  '';
  tmuxMan = runCommandNoCC "tmux-man" {} ''
    ln -s ${tmux.man} $out
  '';
  zshrc = writeTextFile {
    name = "zshrc";
    text = builtins.readFile ./agnoster.zsh-theme + builtins.readFile ./zshrc;
    destination = "/etc/zshrc";
  };
  openPort = writeShellScriptBin "openport" ''
    set -e
    trace() {
      printf "%q " "$@"
      echo
      "$@"
    }
    trace [ -n "$1" ]
    for prog in iptables ip6tables ; do
      for protocol in tcp udp ; do
        trace $prog -I INPUT 1 -p $protocol -m $protocol --dport "$1" -j ACCEPT
      done
    done
  '';
  nix-prefetch-github = writeShellScriptBin "nix-prefetch-github" ''
    export PATH=${lib.escapeShellArg (lib.makeBinPath [git bash nix gnutar gzip coreutils])}
    exec bash ${./nix-prefetch-github.sh} "$@"
  '';
  src = writeShellScriptBin "src" ''
    set -x
    test -n "$1"
    exec nix-shell '<nixpkgs>' -A "$1" --run 'runHook unpackPhase'
  '';

in rec {
basicLight = {
  inherit confs tmuxConfigured nix-prefetch-github src openPort;
  inherit (pkgs) binutils fd htop jq lsof moreutils ncdu strace units;
  inherit (pkgs.bind) dnsutils;
};
basic = basicLight // {
  # So that `nix-env -f dotfiles -i` installs the basic set
  recurseForDerivations = true;
  inherit (pkgs) ripgrep;
};
desktop-nographic = basic // {
  inherit (pkgs)
    gdb
    syncthing
    inotify-tools
    isync
    khal
    man-pages
    mcabber
    mosh
    msmtp
    notmuch
    nix-index
    nixops
    nmap
    pandoc
    potrace
    ripgrep
    sqliteInteractive
    sshfs
    sshuttle
    tmuxp
    unzip
    vagrant
    vdirsyncer
    ;
  gnupg = gnupg.override {guiSupport = false;};
  texlive = texlive.combined.scheme-small;
};
desktop-full = desktop-nographic // rec {
  inherit (pkgs)
    alacritty audacity chromium compton dfeet dmenu endless-sky
    evince feh firefox gimp graphicsmagick
    gnupg # Replace the non-graphical one from desktop-nographic
    i3status inkscape kvm libreoffice mpv mumble mupdf noto-fonts
    noto-fonts-emoji pass pavucontrol redshift scrot socat
    tdesktop terminus_font vlc xidlehook xsel youtube-dl
    ;
  inherit (gnome3) eog dconf;
  inherit (python3Packages) binwalk;
  emacs = callPackage ./emacs.nix {};
  lock = callPackage ./locker {};
  i3 = lib.lowPrio pkgs.i3;
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
           EDITOR='emacsclient -a ""'
    xrdb -merge - <<EOF
    Xcursor.theme: Adwaita
    EOF
    [[ -r $HOME/.background-image ]] && ${feh}/bin/feh --bg-max $HOME/.background-image
    ${dunst}/bin/dunst \
        -padding 15 \
        -horizontal_padding 20 \
        -dmenu ${dmenu}/bin/dmenu \
        -fn "Liberation Sans 18" \
        -history_key Redo \
        -context_key SunProps &
    gpg-connect-agent /bye
    exec ${i3Configured}/bin/i3
  '';
  switch-user = writeScriptBin "switch-user" ''
    ${dbus}/bin/dbus-send --print-reply --system --dest=org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter
  '';
};
}
