{ writeTextFile
, emacsConfigText ? ''
    (setq mouse-wheel-scroll-amount '(1 ((shift) . 1)))
    (setq mouse-wheel-progressive-speed nil)
    (set-variable 'inhibit-startup-screen t)
    (setq whitespace-style '(tab-mark face trailing tabs))
    (global-whitespace-mode)
    (require 'evil)
    (evil-set-initial-state 'vterm-mode 'emacs)
    (evil-mode)
    (require 'magit)
    (require 'notmuch)
    (counsel-mode)
    (global-set-key (kbd "C-x f") 'counsel-rg)
  ''
, haskellPackages
, runCommandNoCC
, emacsPackagesFor
, callPackage
, notmuch
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
    yaml-mode
    rust-mode
    dhall-mode
    docbook
    company
    lsp-mode
    lsp-ui
    lsp-haskell
    transpose-frame
    typescript-mode
    counsel
    notmuch.emacs
    jq-mode
    vterm
  ]);
in (emacsPackagesFor emacs).emacsWithPackages packagesFun
