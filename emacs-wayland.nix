{ emacs26, fetchFromGitHub, wayland, wayland-protocols
, autoreconfHook, texinfo, enableDebugging, lib }:
enableDebugging (emacs26.overrideAttrs (
  { buildInputs, configureFlags ? [], postPatch ? "", nativeBuildInputs ? [], ... }:
  {
    src = builtins.fetchGit ~/projects/emacs;
    /*
    src = builtins.fetchGit {
      url = "https://github.com/masm11/emacs";
      ref = "pgtk";
    };
    src = fetchFromGitHub {
      owner = "masm11";
      repo = "emacs";
      rev = "4fd0e8e06ea8fc12e8c995810fd407719465fa6a";
      sha256 = "1zsmwd0qksvls677sgm7i609vij7fcr60lq77xkszqx0fx3f6g88";
    };
    */

    patches = [];
    buildInputs = buildInputs ++ [ wayland wayland-protocols];
    nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook texinfo ];

    configureFlags = configureFlags ++ [ "--without-x" "--with-cairo" "--with-modules" ];

    /*
    postPatch = ''
      ${postPatch}
      substituteInPlace Makefile.in --replace /usr/bin/glib-compile-schemas glib-compile-schemas
    '';
    */
  }
))
