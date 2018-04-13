let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv writeScriptBin;
  neovim = import ./neovim.nix { inherit pkgs; };
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
    text = builtins.readFile ./agnoster.zsh-theme + builtins.readFile ./zshrc;
    destination = "/etc/zshrc";
  };
  openPort = pkgs.writeShellScriptBin "openport" ''
    set -ex
    [[ -n "$1" ]]
    for prog in iptables ip6tables ; do
      for protocol in tcp udp ; do
        $prog -I INPUT 1 -p $protocol -m $protocol --dport "$1" -j ACCEPT
      done
    done
  '';
in
  {
    inherit
      neovim
      tmuxConfigured
      nox
      zshrc
      openPort
      ;
    inherit (pkgs)
      binutils # mostly for strings
      fbterm
      fish
      gdb
      syncthing
      htop
      inotify-tools
      indent
      jq
      lsof
      man-pages
      moreutils
      ncdu
      nethack
      nix-index
      nix-repl
      nixops
      nmap
      pandoc
      potrace
      ripgrep
      sqliteInteractive
      sshuttle
      tmuxp
      unzip
      usbutils
      ;
    inherit (pkgs.bind) dnsutils;
    gnupg = pkgs.gnupg.override {guiSupport = false;};
    texlive = pkgs.texlive.combined.scheme-small;
  }
