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
    (require 'magit)
    (require 'notmuch) ;; notmuch files are included in share/emacs/site-lisp directly by the package
  ''
, haskellPackages
, runCommandNoCC
, emacsPackagesFor
, callPackage
, emacs26-nox
, emacs-nox ? emacs26-nox }:
let
  emacsConfig = writeTextFile {
    name = "default.el";
    destination = "/share/emacs/site-lisp/default.el";
    text = emacsConfigText;
  };
  packagesFun = ps: [ emacsConfig ] ++ (with ps; [
    evil
    markdown-mode
    nix-mode
    haskell-mode
    sudo-edit
    magit
    yaml-mode
    rust-mode
    dhall-mode
    docbook
    company
    lsp-mode
    lsp-ui
    lsp-haskell
    typescript-mode
    counsel
  ]);
in (emacsPackagesFor (callPackage ./emacs-wayland.nix {})).emacsWithPackages packagesFun
