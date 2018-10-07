let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv writeScriptBin;
  neovim = import ./neovim.nix { inherit pkgs; };
  tmuxConfigured = writeScriptBin "tmux" ''
    #!${stdenv.shell}
    exec ${pkgs.tmux}/bin/tmux -f ${./tmux.conf} -S "/run/user/$(id -u)/tmux.1000" "$@"
  '';
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
      zshrc
      openPort
      ;
    inherit (pkgs)
      binutils # mostly for strings
      fbterm
      fish
      fzf
      gdb
      syncthing
      htop
      inotify-tools
      indent
      jq
      lsof
      man-pages
      moreutils
      mosh
      ncdu
      nethack
      nix-index
      nix-repl
      nixops
      nmap
      pandoc
      potrace
      ripgrep
      scaleway-cli
      sqliteInteractive
      sshfs
      sshuttle
      tmuxp
      units
      unzip
      youtube-dl
      ;
    inherit (pkgs.bind) dnsutils;
    gnupg = pkgs.gnupg.override {guiSupport = false;};
    texlive = pkgs.texlive.combined.scheme-small;
  }
