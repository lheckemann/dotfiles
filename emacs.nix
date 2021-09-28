{ writeTextFile
, emacsConfigText ? ''
    (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
    (setq mouse-wheel-progressive-speed nil)
    (set-variable 'inhibit-startup-screen t)
    (setq whitespace-style '(tab-mark face trailing tabs))
    (global-whitespace-mode)
    (global-undo-tree-mode)
    (require 'evil)
    (evil-set-initial-state 'vterm-mode 'emacs)
    (evil-set-initial-state 'ivy-occur-mode 'emacs)
    (evil-set-initial-state 'ivy-occur-grep-mode 'emacs)
    (evil-mode)
    (require 'magit)
    (require 'notmuch)
    (counsel-mode)
    (global-set-key (kbd "C-x f") 'counsel-rg)
    (global-set-key (kbd "C-c u") 'browse-url-at-point)
    (direnv-mode)
  ''
, buildEnv
, haskellPackages
, runCommandNoCC
, emacsPackagesFor
, callPackage
, notmuch
, linkFarm
, emacs
}:
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
    forge
    flycheck
    yaml-mode
    rust-mode
    dhall-mode
    docbook
    company
    lsp-mode
    lsp-ui
    lsp-haskell
    lsp-ivy
    helm-lsp
    php-mode
    transpose-frame
    typescript-mode
    counsel
    notmuch.emacs
    jq-mode
    undo-tree
    vterm
    vterm-toggle
    keyfreq
    direnv
    scad-mode
  ]);
  nixpkgs-emacs = (emacsPackagesFor emacs).emacsWithPackages packagesFun;
  my-emacs = buildEnv {
    name = "emacs-packages";
    paths = packagesFun (emacsPackagesFor emacs);
    pathsToLink = ["/share/emacs"];
  };
in nixpkgs-emacs
