let
  pkgs = import <nixpkgs> {};
  inherit (pkgs) stdenv xorg ffmpeg;
  gst = pkgs.gst_all_1;
  inherit (gst) gstreamer;
  i3lock = pkgs.i3lock.overrideDerivation (orig: {
    patches = [./i3lock.patch];
  });
in
stdenv.mkDerivation {
  name = "locker";
  src = ./lockscript;
  buildInputs = [ xorg.xdpyinfo gstreamer i3lock ];

  inherit (stdenv) shell;
  inherit (pkgs.xorg) xdpyinfo;
  inherit ffmpeg i3lock;
  gstPluginsPath = pkgs.lib.makeSearchPath "lib/gstreamer-1.0" (with gst;
  [gstreamer gst-plugins-good gst-plugins-base]);
  gstreamer = gstreamer.dev; # gst-launch-1.0 is in dev output
  installPhase = ''
    mkdir -p $out/bin
    substituteAll lock $out/bin/lock
    chmod a+x $out/bin/lock
    mkdir -p $out/share/lockscript
    cp lock.png $out/share/lockscript/
  '';
}
