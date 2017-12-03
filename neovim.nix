{ pkgs, ... }:
(
  pkgs.neovim.override {
    configure = {
      customRC = (builtins.readFile ./init.vim) + ''
        let g:racer_cmd = "${pkgs.rustracer}/bin/racer"
        let g:racer_experimental_completer = 1
      '';
      vam.pluginDictionaries = [
        {
          names = [
            "airline"
            "vim-airline-themes"
            "fugitive"
            "Supertab"
            "The_NERD_tree"
            "deoplete-nvim"
            "jellybeans"
            "vim-nix"
            "rust-vim"
            "neomake"
          ];
        }
        {
          name = "deoplete-jedi";
          ft_regex = "python";
        }
        {
          name = "vim-racer";
          filename_regex = ''\(.*\.rs\|Cargo\.\(toml\|lock\)\)'' + "$";
        }
        {
          names = ["haskell-vim"];
          ft_regex = "haskell";
        }
      ];
      vam.knownPlugins = pkgs.vimPlugins // (with pkgs.vimUtils; {
        jellybeans = buildVimPluginFrom2Nix {
          name = "jellybeans-2016-10-18";
          src = pkgs.lib.cleanSource ./jellybeans.vim;
          dependencies = [];
        };

        vim-racer = buildVimPluginFrom2Nix {
          name = "vim-racer-2017-05-08";
          src = pkgs.fetchgit {
            url = "https://github.com/racer-rust/vim-racer";
            rev = "34b7f2a261f1a7147cd87aff564acb17d0172c02";
            sha256 = "13xcbw7mw3y4jwrjszjyvil9fdhqisf8awah4cx0zs8narlajzqm";
          };
          dependencies = [];
        };

        neomake = buildVimPluginFrom2Nix { # created by nix#NixDerivation
          name = "neomake-2017-07-25";
          src = pkgs.fetchgit {
            url = "https://github.com/benekastah/neomake";
            rev = "0d1f1508ce2c9cfcffbf74a6bdea9c5766301fd6";
            sha256 = "0wc9b63s4j80f6irf2g6dmk2nx8w9il4dccbgmzirchmymndw4vh";
          };
          dependencies = [];

        };
      });
    };
  }
)
