let
  tryGet = key: default: set: if set ? key then set.${key} else default;
  tryGetList = key: set: tryGet key [] set;
in
self: super: {
  nox = super.nox.overrideAttrs (orig: {
    src = ./nox;
    buildInputs = orig.buildInputs ++ [ super.git ];
    PBR_VERSION = orig.version;
  });
}
