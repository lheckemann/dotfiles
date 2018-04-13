{ runCommand, makeWrapper, i3 }:
let
  config = ./i3/config;
  statusConfig = ./i3/status.conf;
in runCommand "i3-with-config" {
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  mkdir -p $out/etc
  substitute ${config} $out/etc/i3.conf --replace I3STATUS_CONFIG ${statusConfig}
  makeWrapper ${i3}/bin/i3 $out/bin/i3 --add-flags "-c ~/.nix-profile/etc/i3.conf"
''
