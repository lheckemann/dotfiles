{ pkgs ? import <nixpkgs> {} }:
let
  inherit (pkgs) runCommand lib;
  gst = pkgs.gst_all_1;
  components = with gst; [
    gstreamer
    gst-plugins-good
    gst-plugins-base
    gst-plugins-bad
    gst-plugins-ugly
  ];
  searchPath = lib.makeSearchPath "lib/gstreamer-1.0" components;
in
runCommand "gst-tools" {
  GST_PLUGIN_PATH = searchPath;
  buildInputs = [ gst.gstreamer ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
} ''
  mkdir -p "$out"/bin
  makeWrapper "${gst.gstreamer.dev}"/bin/gst-launch-1.0 $out/bin/gst-launch --set GST_PLUGIN_PATH "${searchPath}"
  makeWrapper "${gst.gstreamer.dev}"/bin/gst-inspect-1.0 $out/bin/gst-inspect --set GST_PLUGIN_PATH "${searchPath}"
''
