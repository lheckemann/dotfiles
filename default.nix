let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv writeScriptBin;
  neovim = import ./neovim.nix { inherit pkgs; };
  redshift = pkgs.redshift;
  i3Configured = import ./i3.nix { inherit pkgs; };
  lock = import ./locker;
  xsession = writeScriptBin "xsession" ''
    #!${stdenv.shell}
    ${redshift}/bin/redshift -l 56:-4 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-max $HOME/.background-image
    ${pkgs.dunst}/bin/dunst \
        -padding 5 \
        -horizontal_padding 10 \
        -dmenu ${pkgs.dmenu}/bin/dmenu \
        -context_key XF86LaunchB &
    exec ${i3Configured}/bin/i3
  '';
  ssh = pkgs.openssh.overrideDerivation (orig: {
    patches = orig.patches ++ [ ./ssh-paranoid-confirm.patch ];
  });
  htop = pkgs.htop.overrideAttrs (orig: {
    patches = [./htop-stripstore.patch];
    postPatch = ''
      touch linux/LinuxProcessList.h
    '';
  });
  polybar = pkgs.polybar.override {
    i3Support = true;
  };
  polybarConfigured = writeScriptBin "polybar" ''
    #!${stdenv.shell}
    exec ${polybar}/bin/polybar -c ${./polybar.ini} "$@"
  '';
  tmuxConfigured = writeScriptBin "tmux" ''
    #!${stdenv.shell}
    exec ${pkgs.tmux}/bin/tmux -f ${./tmux.conf} "$@"
  '';
  nox = pkgs.nox.overrideAttrs (orig: {
    src = ./nox;
    buildInputs = orig.buildInputs ++ [ pkgs.git ];
    PBR_VERSION = orig.version;
  });
in
  {
    inherit 
      neovim
      xsession
      lock
      i3Configured
      polybarConfigured
      ssh
      htop
      tmuxConfigured
      nox
      ;
    inherit (pkgs)
      arandr
      audacity
      binutils # mostly for strings
      borgbackup
      chromium
      compton
      dia
      digikam
      evince
      fbterm
      firefox
      gdb
      gimp
      gitg
      gnupg
      syncthing
      syncthing-inotify
      inotify-tools
      kakoune
      keepassx2
      libreoffice
      lightdm # for dm-tool
      man-pages
      mupdf
      mpv
      mumble
      ncdu
      nethack
      nix-repl
      nixops
      nmap
      noto-fonts
      noto-fonts-emoji
      pavucontrol
      potrace
      ripgrep
      kvm
      scrot
      sqlite
      thunderbird
      tmuxp
      unzip
      usbutils
      vlc
      xsel
      zeal
      endless-sky
      ;
    i3 = pkgs.lib.lowPrio pkgs.i3;
    inherit (pkgs.gnome3) eog dconf;
    inherit (pkgs.idea) idea-community;
    inherit (pkgs.gnome3) nautilus;
    inherit (pkgs.bind) dnsutils;
  }
