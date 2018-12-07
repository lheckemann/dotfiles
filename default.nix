{ pkgs ? import <nixpkgs> {} }: with pkgs;
let
  confs = linkFarm "confs" [
    { name = "etc/tmux.conf"; path = ./tmux.conf; }
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
    set -ex
    [[ -n "$1" ]]
    for prog in iptables ip6tables ; do
      for protocol in tcp udp ; do
        $prog -I INPUT 1 -p $protocol -m $protocol --dport "$1" -j ACCEPT
      done
    done
  '';
  nix-prefetch-github = writeShellScriptBin "nix-prefetch-github" ''
    export PATH=${lib.escapeShellArg (lib.makeBinPath [git bash nix gnutar gzip coreutils])}
    exec bash ${./nix-prefetch-github.sh} "$@"
  '';
in
  {
    inherit
      confs
      tmuxConfigured
      tmuxMan
      zshrc
      nix-prefetch-github
      openPort
      ;
    inherit (pkgs)
      binutils # mostly for strings
      fbterm
      fd
      fzf
      gdb
      syncthing
      htop
      inotify-tools
      indent
      isync
      jq
      khal
      lsof
      man-pages
      mcabber
      moreutils
      mosh
      ncdu
      neomutt
      nethack
      notmuch
      nix-index
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
      vdirsyncer
      youtube-dl
      ;
    inherit (bind) dnsutils;
    gnupg = gnupg.override {guiSupport = false;};
    texlive = texlive.combined.scheme-small;
  }
