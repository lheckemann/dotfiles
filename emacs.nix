{ writeTextFile
, emacsConfigText ? ''
    (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
    (setq mouse-wheel-progressive-speed nil)
    (set-variable 'inhibit-startup-screen t)
    (setq whitespace-style '(tab-mark face trailing tabs))
    (global-whitespace-mode)
    (require 'evil)
    (evil-mode)
    (xterm-mouse-mode)
    (require 'agda2)
  ''
, haskellPackages
, runCommandNoCC
, emacsWithPackages }:
let
  emacsConfig = writeTextFile {
    name = "default.el";
    destination = "/share/emacs/site-lisp/default.el";
    text = emacsConfigText;
  };
  agda = haskellPackages.Agda.data;
  agda-mode = runCommandNoCC "agda-emacs" {} ''
    mkdir -p $out/share/emacs/site-lisp/elpa/
    ln -s ${agda}/share/*/*/${agda.name}/emacs-mode $out/share/emacs/site-lisp/elpa/${agda.name}
  '';
  packagesFun = ps: [ emacsConfig agda-mode ] ++ (with ps; [
    evil markdown-mode nix-mode
    haskell-mode
    sudo-edit
  ]);
in emacsWithPackages packagesFun
