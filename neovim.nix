{ pkgs, ... }: (
  pkgs.neovim.override {
    configure = {
      customRC = builtins.readFile ./init.vim;
      vam.pluginDictionaries = [
        {
          names = [
            "airline"
            "vim-airline-themes"
            "neomake"
            "fugitive"
            "Supertab"
            "The_NERD_tree"
            "deoplete-nvim"
            "deoplete-jedi"
            "vim-addon-vim2nix"
            "jellybeans"
            "vim-nix"
          ];
        }
      ];
      vam.knownPlugins = pkgs.vimPlugins // {
        jellybeans = pkgs.vimUtils.buildVimPluginFrom2Nix {
          name = "jellybeans-2016-10-18";
          src = pkgs.fetchgit {
            url = "git://github.com/nanotech/jellybeans.vim";
            rev = "fd089ca8a242263f61ae7bddce55a007d535bc65";
            sha256 = "00knmhmfw9d04p076cy0k5hglk7ly36biai8p9b6l9762irhzypp";
          };
          dependencies = [];
        };
      };
    };
  }
)
