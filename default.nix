let
  pkgs = import <nixpkgs> {};
  neovim = import ./neovim.nix { inherit pkgs; };
  redshift = pkgs.redshift;
  i3 = import ./i3.nix { inherit pkgs; };
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
    exec ${i3}/bin/i3
  '';
  ssh = pkgs.openssh.overrideDerivation (orig: {
    patches = orig.patches ++ [ ./ssh-paranoid-confirm.patch ];
  });
in
  pkgs.symlinkJoin {
    name = "linus-env";
    paths = [
      neovim
      xsession
      lock
      ssh
    ] ++ (with pkgs; [
      arandr
      bind # for dig
      borgbackup
      chromium
      compton
      dia
      gnome3.eog
      evince
      fbterm
      firefox
      gimp
      gitg
      gnupg
      syncthing
      syncthing-inotify
      idea.idea-community
      inotify-tools
      kakoune
      keepassx2
      libreoffice
      lightdm # for dm-tool
      man-pages
      mupdf
      mpv
      mumble
      gnome3.nautilus
      ncdu
      nethack
      nix-repl
      nmap
      pavucontrol
      potrace
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
    ]);
  }
