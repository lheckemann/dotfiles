{ pkgs, ... }:
let
  clang = pkgs.llvmPackages.clang-unwrapped;
  clangVersion = (builtins.parseDrvName clang.name).version;
in
(
  pkgs.neovim.override {
    configure = {
      customRC = (builtins.readFile ./init.vim) + ''
        let g:deoplete#sources#clang#libclang_path='${clang}/lib/libclang.so'
        let g:deoplete#sources#clang#clang_header='${clang}/lib/clang/${clangVersion}/include'
      '';
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
            "jellybeans"
            "vim-nix"
            "rust-vim"
            "deoplete-clang"
          ];
        }
        {
          name = "deoplete-jedi";
          ft_regex = "python";
        }
        {
          name = "rust-vim";
          filename_regex = "\(.*\.rs\|Cargo\.\(toml\|lock\)\)$";
        }
        {
          names = [ "haskell-vim" "neco-ghc" "vim-proc" ];
          ft_regex = "haskell";
        }
      ];
      vam.knownPlugins = pkgs.vimPlugins // (with pkgs.vimUtils; {
        jellybeans = buildVimPluginFrom2Nix {
          name = "jellybeans-2016-10-18";
          src = pkgs.fetchFromGitHub {
            owner = "nanotech";
            repo = "jellybeans.vim";
            rev = "fd089ca8a242263f61ae7bddce55a007d535bc65";
            sha256 = "00knmhmfw9d04p076cy0k5hglk7ly36biai8p9b6l9762irhzypp";
          };
          dependencies = [];
        };

        deoplete-clang = buildVimPluginFrom2Nix {
          name = "deoplete-clang-2016-12-29";
          src = pkgs.fetchgit {
            url = "https://github.com/zchee/deoplete-clang";
            rev = "29dd29be59e1a800c3f6b99520305b86bfb512fc";
            sha256 = "0qnjpsnxlw71awd8w6ax78xhgnd8340lvli5di3b6az3sn5y63p7";
          };
          dependencies = [];
        };
      });
    };
  }
)
