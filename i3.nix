{ pkgs, ... }:
let
  config = ./i3/config;
  statusConfig = ./i3/status.conf;

in pkgs.stdenv.mkDerivation {
  name = "i3-with-config";

  nativeBuildInputs = [ pkgs.makeWrapper ];

  buildInputs = with pkgs; [ i3 i3status i3lock ];

  buildCommand = ''
    mkdir -p $out/bin
    mkdir -p $out/i3
    cp ${config} $out/i3/config
    substituteInPlace $out/i3/config --replace I3STATUS_CONFIG ${statusConfig}
    ln -s ${pkgs.i3}/bin/i3 $out/bin/i3
    wrapProgram $out/bin/i3 --add-flags "-c $out/i3/config"
  '';
}
