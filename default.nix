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
    text = builtins.readFile ./zshrc + builtins.readFile ./agnoster.zsh-theme;
    destination = "/etc/zshrc";
  };
in
  {
    inherit
      neovim
      tmuxConfigured
      nox
      zshrc
      ;
    inherit (pkgs)
      binutils # mostly for strings
      fbterm
      fish
      gdb
      syncthing
      syncthing-inotify
      htop
      inotify-tools
      indent
      jq
      lsof
      man-pages
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
      tmuxp
      unzip
      usbutils
      ;
    inherit (pkgs.bind) dnsutils;
    gnupg = pkgs.gnupg.override {guiSupport = false;};
    texlive = pkgs.texlive.combined.scheme-small;
  }
