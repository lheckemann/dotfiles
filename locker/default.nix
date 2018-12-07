{ stdenv, lib, xorg, ffmpeg, gst_all_1, i3lock }:
let
  gst = gst_all_1;
  inherit (gst) gstreamer;
in
stdenv.mkDerivation {
  name = "locker";
  src = ./lockscript;
  buildInputs = [ xorg.xdpyinfo gstreamer i3lock ];

  inherit (stdenv) shell;
  inherit (xorg) xdpyinfo;
  inherit ffmpeg i3lock;
  gstPluginsPath = lib.makeSearchPath "lib/gstreamer-1.0"
    (with gst; [gstreamer gst-plugins-good gst-plugins-base]);
  gstreamer = gstreamer.dev; # gst-launch-1.0 is in dev output
  installPhase = ''
    mkdir -p $out/bin
    substituteAll lock $out/bin/lock
    chmod a+x $out/bin/lock
    mkdir -p $out/share/lockscript
    cp lock.png $out/share/lockscript/
  '';
}
