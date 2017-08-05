let
  pkgs = import <nixpkgs> {};
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
runCommand "boing" {
  GST_PLUGIN_PATH = searchPath;
  buildInputs = [ gst.gstreamer ];
} ""
