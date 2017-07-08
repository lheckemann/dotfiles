let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv writeScriptBin;
  neovim = import ./neovim.nix { inherit pkgs; };
  ssh = pkgs.openssh.overrideDerivation (orig: {
    patches = orig.patches ++ [ ./ssh-paranoid-confirm.patch ];
  });
  htop = pkgs.htop.overrideAttrs (orig: {
    patches = [./htop-stripstore.patch];
    postPatch = ''
      touch linux/LinuxProcessList.h
    '';
  });
  tmuxConfigured = writeScriptBin "tmux" ''
    #!${stdenv.shell}
    exec ${pkgs.tmux}/bin/tmux -f ${./tmux.conf} -S "/run/user/$(id -u)/tmux.1000" "$@"
  '';
  nox = pkgs.nox.overrideAttrs (orig: {
    src = ./nox;
    buildInputs = orig.buildInputs ++ [ pkgs.git ];
    PBR_VERSION = orig.version;
  });
  zshrc = pkgs.writeTextFile {
    name = "zshrc";
    text = builtins.readFile ./zshrc;
    destination = "/etc/zshrc";
  };
in
  {
    inherit
      neovim
      ssh
      htop
      tmuxConfigured
      nox
      zshrc
      ;
    inherit (pkgs)
      binutils # mostly for strings
      borgbackup
      fbterm
      fish
      gdb
      gnupg
      syncthing
      syncthing-inotify
      inotify-tools
      jq
      man-pages
      ncdu
      nethack
      nix-repl
      nixops
      nmap
      potrace
      ripgrep
      sqliteInteractive
      tmuxp
      unzip
      usbutils
      xsel
      ;
    inherit (pkgs.bind) dnsutils;
  }
