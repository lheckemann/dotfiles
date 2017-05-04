{ pkgs, ... }:
let
  config = ./i3/config;
  statusConfig = ./i3/status.conf;

in pkgs.stdenv.mkDerivation {
  name = "i3-with-config";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [ i3 i3status ];

  buildCommand = ''
    mkdir -p $out/bin
    mkdir -p $out/etc
    substitute ${config} $out/etc/i3.conf --replace I3STATUS_CONFIG ${statusConfig}
    ln -s ${pkgs.i3}/bin/i3 $out/bin/
    wrapProgram $out/bin/i3 --add-flags "-c ~/.nix-profile/etc/i3.conf"
  '';
}
