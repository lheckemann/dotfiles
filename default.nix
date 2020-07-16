{ pkgs ? import <nixpkgs> {
  overlays = [ (self: super: {
    wlroots = super.wlroots.overrideAttrs (o: {
      src = super.fetchFromGitHub {
        owner = "swaywm";
        repo = "wlroots";
        rev = "refs/tags/0.11.0";
        sha256 = "08d5d52m8wy3imfc6mdxpx8swhh2k4s1gmfaykg02j59z84awc6p";
      };
      patches = (o.patches or []) ++ [(super.fetchpatch {
        url = https://github.com/alejor/wlroots/commit/a11f13a97f6355a84c578ad5355b3cf4e43e7246.patch;
        sha256 = "0i2x9rrndm3rx71l59d10j736man8p4pifpx7hwlcb055rhrylmr";
      })];
      mesonFlags = (o.mesonFlags or []) ++ ["-Dlogind-provider=systemd"];
    });
    sway-unwrapped = super.sway-unwrapped.overrideAttrs (o: {
      version = "1.5";
      src = super.fetchFromGitHub {
        owner = "swaywm";
        repo = "sway";
        rev = "refs/tags/1.5";
        sha256 = "0r3b7h778l9i20z3him9i2qsaynpn9y78hzfgv3cqi8fyry2c4f9";
      };
    });
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
  }) ];
} }: with pkgs;
let
  confs = lib.hiPrio (linkFarm "confs" [
    { name = "etc/tmux.conf"; path = "${./tmux.conf}"; }
    { name = "etc/sway/config"; path = "${./sway-config}"; }
    { name = "etc/i3status-rs.toml"; path = "${./i3status-rs.toml}"; }
    { name = "etc/mako.conf"; path = "${./mako.conf}"; }
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
  inherit (pkgs) binutils file htop jq lsof moreutils ncdu pv strace tcpdump units;
  inherit (pkgs) lnav;
  inherit (pkgs.bind) dnsutils;
  build-on = pkgs.writeShellScriptBin "build-on" ''
    set -ex
    host="$1"
    shift
    drv=$(nix-instantiate "$@")
    nix-copy-closure --to "$host" "$drv"
    nix-store --store ssh-ng://"$host" -r "$drv"
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
    gdb
    syncthing
    inotify-tools
    isync
    khal
    man-pages
    mosh
    msmtp
    notmuch
    nix-bisect
    nix-diff
    nix-index
    nixops
    nmap
    picocom
    pwgen
    ripgrep
    sqliteInteractive
    sshfs
    unzip
    vdirsyncer
    ;
  gnupg = gnupg.override {guiSupport = false;};
  nixopses =
    lib.recurseIntoAttrs (
      lib.mapAttrs
        (name: settings: lib.hiPrio (callPackage ./nixops-wrapper.nix ({inherit name;} // settings)))
        (import ./nixops-deployments.nix));
  inherit (python3Packages) binwalk;
};
desktop-full = desktop-nographic // rec {
  inherit (pkgs)
    alacritty audacity
    bemenu
    chromium dfeet
    ddcutil
    endless-sky
    evince feh firefox-wayland gimp graphicsmagick
    glib # for gdbus
    gnupg # Replace the non-graphical one from desktop-nographic
    hack-font
    i3status-rust inkscape kvm libreoffice mako mpv noto-fonts
    kanshi
    pass-wayland pavucontrol redshift-wlr rdesktop remmina socat
    sway sway_screenshot
    tdesktop terminus_font tigervnc vlc youtube-dl
    wdisplays wl-clipboard
    ;
  noto-fonts-emoji = lib.hiPrio pkgs.noto-fonts-emoji;
  mupdf = pkgs.mupdf.overrideAttrs (o: {
      patches = (o.patches or []) ++ [ ./0001-x11-accept-commands-on-stdin-as-well.patch ];
  });
  mumble = pkgs.mumble.overrideAttrs (o: { patches = o.patches ++ [ ./mumble-dbus-ptt.patch ]; });
  inherit (androidenv.androidPkgs_9_0) platform-tools;
  inherit (gnome3) eog dconf adwaita-icon-theme;
  emacs-wayland = callPackage ./emacs-wayland.nix {};
  emacs = lib.hiPrio (callPackage ./emacs.nix { emacs = emacs-wayland; });
  emacs-x = callPackage ./emacs.nix {};
  editor = pkgs.writeShellScriptBin "editor" ''
    export TERM=xterm-256color
    exec emacsclient -nw -c -- "$@"
  '';
  sway-session = writeScriptBin "sway-session" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=${gnome3.adwaita-icon-theme}/share/icons \
           SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
           EDITOR='editor' \
           QT_QPA_PLATFORM=wayland \
           MOZ_ENABLE_WAYLAND=1 \
           XDG_BACKEND=wayland
    systemctl import-environment QT_QPA_PLATFORM MOZ_ENABLE_WAYLAND XCURSOR_PATH XDG_BACKEND
    dbus-update-activation-environment QT_QPA_PLATFORM MOZ_ENABLE_WAYLAND XCURSOR_PATH XDG_BACKEND
    exec sway -c ~/.nix-profile/etc/sway/config
  '';

  passmenu = lib.hiPrio (pkgs.runCommandNoCC "passmenu" {} ''
    install -Dm0755 ${./passmenu.sh} $out/bin/passmenu
  '');
};
}
