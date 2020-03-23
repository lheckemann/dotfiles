{ pkgs ? import <nixpkgs> {
  overlays = [ (self: super: {
    wlroots = super.wlroots.overrideAttrs (o: {
      src = super.fetchFromGitHub {
        owner = "swaywm";
        repo = "wlroots";
        rev = "34303e1b47defc7aca518983ac3aaea6c881d112";
        sha256 = "0g7l23p9fzksi5prmcjry09s2sagxg8416lvrydfvd0q7njnrvvc";
      };
    });
    sway-unwrapped = super.sway-unwrapped.overrideAttrs (o: {
      version = "sway-unwrapped-2020-03-23-unstable";
      src = super.fetchFromGitHub {
        owner = "swaywm";
        repo = "sway";
        rev = "e553e38270afa28ac7da8caf1d7e06890f476086";
        sha256 = "01yzpahwvp75wvw3ng5bm7zwyw8kx3nw1cg2acddcp64r77464hz";
      };
    });
  }) ];
} }: with pkgs;
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

  vim = ((vimUtils.makeCustomizable pkgs.vim).customize {
    name = "vim";
    vimrcConfig = {
      customRC = ''
        syntax on
        command! -nargs=1 Spaces set shiftwidth=<args> softtabstop=<args> tabstop=17 expandtab autoindent
        command! -nargs=1 Tabs set shiftwidth=<args> softtabstop=<args> tabstop=<args> noexpandtab autoindent
        Spaces 4
        set is si ai ic hls mouse=a ttymouse=xterm2 backspace=2 laststatus=2 statusline=%f\ %l+%c/%L\ %p%%
        noremap <ScrollWheelUp> <C-y>
        noremap <ScrollWheelDown> <C-e>

        if exists($TMUX) || $TERM == 'alacritty'
          " normal mode: default cursor
          let &t_EI = "\<Esc>[0 q"
          " insert mode: vertical line
          let &t_SI = "\<Esc>[6 q"
          " replace mode: underline
          let &t_SR = "\<Esc>[3 q"
        endif
      '';
      packages.m.start = with pkgs.vimPlugins; [ vim-nix ];
    };
  });

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
    mcabber
    mosh
    msmtp
    notmuch
    nix-diff
    nix-index
    nixops
    nmap
    pandoc
    picocom
    potrace
    pwgen
    ripgrep
    sqliteInteractive
    sshfs
    sshuttle
    tmuxp
    unzip
    vdirsyncer
    ;
  gnupg = gnupg.override {guiSupport = false;};
  texlive = texlive.combined.scheme-small;
  inherit (python3Packages) binwalk;
};
desktop-full = desktop-nographic // rec {
  inherit (pkgs)
    autorandr arandr
    alacritty audacity chromium compton dfeet dmenu endless-sky
    evince feh firefox font-awesome gimp graphicsmagick
    glib # for gdbus
    gnupg # Replace the non-graphical one from desktop-nographic
    hack-font
    i3status i3status-rust inkscape kvm libreoffice mako mpv noto-fonts
    pass-wayland pavucontrol redshift-wlr rdesktop scrot socat
    sway
    tdesktop terminus_font tigervnc vlc xidlehook xsel youtube-dl
    wdisplays wl-clipboard
    ;
  noto-fonts-emoji = lib.hiPrio pkgs.noto-fonts-emoji;
  mupdf = pkgs.mupdf.overrideAttrs (o: {
      patches = (o.patches or []) ++ [ ./0001-x11-accept-commands-on-stdin-as-well.patch ];
  });
  mumble = pkgs.mumble.overrideAttrs (o: { patches = o.patches ++ [ ./mumble-dbus-ptt.patch ]; });
  inherit (androidenv.androidPkgs_9_0) platform-tools;
  inherit (gnome3) eog dconf adwaita-icon-theme;
  emacs = callPackage ./emacs.nix {};
  editor = pkgs.writeShellScriptBin "editor" ''
    export TERM=xterm-256color
    exec emacsclient -nw -c -- "$@"
  '';
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
    ''
  );
  xsession = writeScriptBin "xsession" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=${gnome3.adwaita-icon-theme}/share/icons \
           SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
           EDITOR='editor'
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
  sway-session = writeScriptBin "sway-session" ''
    #!${stdenv.shell}
    export XCURSOR_PATH=${gnome3.adwaita-icon-theme}/share/icons \
           SSH_AUTH_SOCK=/run/user/1000/gnupg/S.gpg-agent.ssh \
           EDITOR='env TERM=xterm-256color emacsclient -nw -c' \
           QT_QPA_PLATFORM=wayland \
           MOZ_ENABLE_WAYLAND=1
    exec sway
  '';
  screenshot = pkgs.runCommand "screenshot" {
    src = fetchFromGitHub {
      owner = "yschaeff";
      repo = "sway_screenshots";
      rev = "c94a4f286c88f73acd4a82515820ac1d2cb0ae7f";
      sha256 = "1i5zdas3qkd6l70g5rqnf72g10zc6i64yadrivicd0q2cskyv106";
    };
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    runHook unpackPhase
    cd $sourceRoot
    mkdir -p $out/bin
    cat >$out/bin/screenshot - ${~/projects/sway_screenshots/screenshot.sh} <<EOF
    #!${pkgs.runtimeShell}
    export PATH=PATH:${lib.escapeShellArg (lib.makeBinPath (with pkgs; [ procps dmenu coreutils sway xdg-user-dirs feh grim slurp jq wl-clipboard libnotify wf-recorder ]))}
    EOF
    chmod a+x $out/bin/screenshot
  '';
  bemenu = pkgs.bemenu.overrideAttrs (_: {
    src = fetchFromGitHub {
      owner = "hexd0t";
      repo = "bemenu";
      rev = "d6165784ecd9dafbf9fde6aac14a0e4e983c1f1d";
      sha256 = "1zq0hyg6xjilxpnxglgzzafxrn0bic0mc4q6dlx7q4m9sdhzcmhf";
    };
    cmakeFlags = ["-DBEMENU_WAYLAND_RENDERER=ON" "-DBEMENU_X11_RENDERER=OFF"];
  });
  passmenu = lib.hiPrio (pkgs.runCommandNoCC "passmenu" {} ''
    mkdir -p $out/bin
    cat >$out/bin/passmenu - ${./passmenu.sh} <<EOF
    #!${pkgs.runtimeShell}
    export PATH=${lib.escapeShellArg (lib.makeBinPath (with pkgs; [ bemenu pass-wayland findutils coreutils gnused gawk ydotool utillinux wl-clipboard ]))}
    EOF
    chmod +x $out/bin/passmenu
  '');

  switch-user = writeScriptBin "switch-user" ''
    ${dbus}/bin/dbus-send --print-reply --system --dest=org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter
  '';
};
}
