{ emacs27, fetchFromGitHub, wayland, wayland-protocols
, autoreconfHook, texinfo, enableDebugging, lib }:
enableDebugging (emacs27.overrideAttrs (
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
      rev = "2d5e81ce9487217f87c954af0c501a9515b67413";
      sha256 = "18kd82h1ib1ldar2ikcf9w1jdqhjmwbak8yccbbga4yk3szymyja";
    };

    patches = [];
    buildInputs = buildInputs ++ [ wayland wayland-protocols];
    nativeBuildInputs = nativeBuildInputs ++ [ autoreconfHook texinfo ];

    configureFlags = configureFlags ++ [ "--without-x" "--with-cairo" "--with-modules" "--with-pgtk" ];

    /*
    postPatch = ''
      ${postPatch}
      substituteInPlace Makefile.in --replace /usr/bin/glib-compile-schemas glib-compile-schemas
    '';
    */
  }
))
