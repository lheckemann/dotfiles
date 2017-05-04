let
  pkgs = import <nixpkgs> {};
  neovim = import ./neovim.nix { inherit pkgs; };
  redshift = pkgs.redshift;
  i3Configured = import ./i3.nix { inherit pkgs; };
  lock = import ./locker;
  xsession = pkgs.writeScriptBin "xsession" ''
    #!${pkgs.stdenv.shell}
    ${redshift}/bin/redshift -l 56:-4 -t 5500:2800 &
    [[ -r $HOME/.background-image ]] && ${pkgs.feh}/bin/feh --bg-scale $HOME/.background-image
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
in
  {
    inherit 
      neovim
      xsession
      lock
      i3Configured
      ssh
      htop;
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
      nox
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
    inherit (pkgs.gnome3) eog;
    inherit (pkgs.idea) idea-community;
    inherit (pkgs.gnome3) nautilus;
    inherit (pkgs.bind) dnsutils;
  }
