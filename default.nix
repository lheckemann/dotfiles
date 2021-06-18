{ sources ? import ./nix/sources.nix {}
, pkgs ? import sources.nixpkgs {
  overlays = [
    (self: super: {
      sway_screenshot = super.runCommand "sway_screenshot" {
        src = super.fetchFromGitHub {
          owner = "yschaeff";
          repo = "sway_screenshots";
          rev = "ad27b1b6e42f536b61dd5d8d0a3fe26c60017c41";
          sha256 = "1m53d020m549y76dj1nn11k82z24z78sh2jhsl6b9avxkwk32ycw";
        };
      } ''
        runHook unpackPhase
        cd $sourceRoot
        mkdir -p $out/bin
        cat >$out/bin/screenshot - <(sed '/MENU=/d' screenshot.sh) <<EOF
        #!${pkgs.runtimeShell}
        export PATH=PATH:${super.lib.escapeShellArg (super.lib.makeBinPath (with self; [ procps coreutils sway xdg-user-dirs feh grim slurp jq wl-clipboard libnotify wf-recorder bemenu ]))}
        MENU="bemenu --fn Hack"
        EOF
        chmod a+x $out/bin/screenshot
      '';
      nix-bisect = super.callPackage (
        super.fetchFromGitHub {
          owner = "timokau";
          repo = "nix-bisect";
          rev = "v0.4.0";
          sha256 = "1akxs605dma8xdixj62l48nk145nss9d1a8l8k0wxn5hwkqfr4vy";
        }
      ) {};
      sway-unwrapped = super.enableDebugging super.sway-unwrapped;
      wlroots = super.enableDebugging super.wlroots;
      tigervnc = super.tigervnc.override { fontDirectories = []; };
    })
    (import sources.emacs-overlay)
  ];
} }: with pkgs;
let
  confs = lib.hiPrio (linkFarm "confs" [
    { name = "etc/tmux.conf"; path = "${./tmux.conf}"; }
    { name = "etc/sway/config"; path = "${./sway-config}"; }
    { name = "etc/i3status-rs.toml"; path = "${./i3status-rs.toml}"; }
    { name = "etc/mako.conf"; path = "${./mako.conf}"; }
    { name = "etc/alacritty.yml"; path = "${./alacritty.yml}"; }
  ]);
  tmuxConfigured = writeScriptBin "tmux" ''
    #!${stdenv.shell}
    exec ${tmux}/bin/tmux -f ~/.nix-profile/etc/tmux.conf -S "/run/user/$(id -u)/tmux.1000" "$@"
  '';
  tmuxMan = runCommandNoCC "tmux-man" {} ''
    ln -s ${tmux.man} $out
  '';
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
  inherit confs tmuxConfigured nix-prefetch-github src openPort vim;
  inherit (pkgs) binutils file htop jq lsof moreutils ncdu pv rsync strace tcpdump units;
  inherit (pkgs) lnav;
  inherit (pkgs.bind) dnsutils;
  build-on = pkgs.writeShellScriptBin "build-on" ''
    set -ex
    host="$1"
    shift
    if [[ "$1" = *.drv ]] ; then
      drvs="$1"
    else
      drvs=$(nix-instantiate "$@")
    fi
    nix-copy-closure --to "$host" $drvs
    nix-store --store ssh-ng://"$host" -r $drvs --keep-going
  '';
};
basic = basicLight // {
  # So that `nix-env -f dotfiles -i` installs the basic set
  recurseForDerivations = true;
  inherit (pkgs) git fd ripgrep;
};
desktop-nographic = basic // {
  inherit (pkgs)
    borgbackup
    dnsmasq
    esphome
    gdb
    syncthing
    inotify-tools
    isync
    k9s
    khal
    kubectl
    man-pages
    mosh
    msmtp
    notmuch
    niv
    nix-bisect
    nix-diff
    nix-index
    nix-tree
    nixops
    nmap
    picocom
    pwgen
    ripgrep
    sqliteInteractive
    sipcalc
    sshfs
    unzip
    vdirsyncer
    ;
  trainspeed = writeShellScriptBin "trainspeed" ''
    wls=$(wpa_cli -iwlp3s0 status)
    if [[ "$wls" = *WIFI* ]] ; then
      json=$(curl -v --resolve iceportal.de:443:172.18.1.110 https://iceportal.de/api1/rs/status)
      speed=$(echo "$json" | jq .speed)
      echo 🚂 $speed km/h
    fi
  '';
  gnupg = gnupg.override {guiSupport = false;};
  install-nixos = pkgs.writeScriptBin "install-nixos" (builtins.readFile ./install-nixos.sh);
  nixopses =
    lib.recurseIntoAttrs (
      lib.mapAttrs
        (name: settings: lib.hiPrio (callPackage ./nixops-wrapper.nix ({inherit name;} // settings)))
        (import ./nixops-deployments.nix));
  inherit (python3Packages) binwalk;
};
desktop-full = desktop-nographic // rec {
  inherit (pkgs)
    audacity
    bemenu
    chromium dfeet
    ddcutil
    endless-sky
    evince feh firefox-wayland
    ffmpeg-full
    font-awesome_4
    gammastep
    gimp graphicsmagick
    glib # for gdbus
    gnupg # Replace the non-graphical one from desktop-nographic
    hack-font
    i3status-rust inkscape kvm libreoffice mako mpv noto-fonts
    kanshi
    pass-wayland pavucontrol rdesktop remmina
    signal-desktop socat
    samba
    sway sway_screenshot
    tdesktop terminus_font tigervnc vlc youtube-dl
    virt-manager
    wdisplays wl-clipboard
    ;
  alacritty = pkgs.writeScriptBin "alacritty" ''
    #!${pkgs.runtimeShell}
    exec ${pkgs.alacritty}/bin/alacritty --config-file $HOME/.nix-profile/etc/alacritty.yml "$@"
  '';
  noto-fonts-emoji = lib.hiPrio pkgs.noto-fonts-emoji;
  mupdf = pkgs.mupdf.overrideAttrs (o: {
      patches = (o.patches or []) ++ [ ./0001-x11-accept-commands-on-stdin-as-well.patch ];
  });
  mumble = pkgs.mumble.overrideAttrs (o: { patches = o.patches ++ [ ./mumble-dbus-ptt.patch ]; });
  inherit (androidenv.androidPkgs_9_0) platform-tools;
  inherit (gnome3) eog dconf adwaita-icon-theme;
  inherit (pkgs.xorg) xhost;
  emacs = lib.hiPrio (callPackage ./emacs.nix { emacs = pkgs.emacsPgtkGcc; });
  emacs-x = callPackage ./emacs.nix {};
  editor = pkgs.writeShellScriptBin "editor" ''
    export TERM=xterm-256color
    exec emacsclient -c -- "$@"
  '';
  sway-session = writeScriptBin "sway-session" ''
    #!${pkgs.runtimeShell}
    export \
      EDITOR='editor' \
      MOZ_ENABLE_WAYLAND=1 \
      QT_QPA_PLATFORM=wayland \
      SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
      XCURSOR_PATH=${gnome3.adwaita-icon-theme}/share/icons \
      XDG_BACKEND=wayland \
      XDG_CONFIG_DIRS=$HOME/.nix-profile:$XDG_CONFIG_DIRS \
      XDG_CURRENT_DESKTOP=sway \
      XDG_SESSION_TYPE=wayland
    exec &>~/.cache/sway-session.log
    systemctl --user import-environment QT_QPA_PLATFORM MOZ_ENABLE_WAYLAND XCURSOR_PATH XDG_BACKEND XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    dbus-update-activation-environment QT_QPA_PLATFORM MOZ_ENABLE_WAYLAND XCURSOR_PATH XDG_BACKEND XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
    exec sway -c ~/.nix-profile/etc/sway/config
  '';

  passmenu = lib.hiPrio (pkgs.runCommandNoCC "passmenu" {} ''
    install -Dm0755 ${./passmenu.sh} $out/bin/passmenu
  '');

  bgssh = writeScriptBin "bgssh" ''
    #!${pkgs.runtimeShell}
    ssh -o ServerAliveInterval=10 "$1" true
    ssh "$1" 'while sleep 10; do date; done' >/dev/null &
  '';
};
give-me-x = { extraPackages ? [] }: mkShell {
  name = "give-me-x";
  nativeBuildInputs = let
    packageNames = if lib.isList extraPackages then extraPackages else lib.splitString " " extraPackages;
    packages = map (name: pkgs.${name}) packageNames;
  in [ tigervnc icewm pwgen minica ] ++ packages;
  shellHook = builtins.readFile ./give-me-x.sh;
};
}
