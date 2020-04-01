{ emacs26, fetchFromGitHub, wayland, wayland-protocols
, autoreconfHook, texinfo, enableDebugging, lib }:
enableDebugging (emacs26.overrideAttrs (
  { buildInputs, configureFlags ? [], postPatch ? "", nativeBuildInputs ? [], ... }:
  {
    /*
    src = builtins.fetchGit ~/projects/emacs;
    src = builtins.fetchGit {
      url = "https://github.com/masm11/emacs";
      ref = "pgtk";
    };
    */
    src = fetchFromGitHub {
      owner = "masm11";
      repo = "emacs";
      rev = "f88789bd3e87111809e3db25e2604a0f58c17e92";
      sha256 = "10m40qpvnbxy98h84lvlp1f5zpqqarbxihjn7x1v4072hf2fhj3q";
    };

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
