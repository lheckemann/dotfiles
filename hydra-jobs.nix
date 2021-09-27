{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {}
, declInput ? {}
}:
let
  defaults = {
    enabled = "1";
    description = "";
    enableemail = false;
    emailoverride = "";
    hidden = false;
    nixexprinput = "nix-config";
    keepnr = 50;
    schedulingshares = 100;
    checkinterval = 1800;
    type = 0;
    inputs = {
      nix-config = {
        type = "git";
        value = "https://git.sr.ht/~linuxhackerman/nix-config master";
        emailresponsible = false;
      };
    };
  };
  jobsets = rec {
    sources = pkgs.lib.recursiveUpdate defaults {
      nixexprpath = "nix/sources-hydra.nix";
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/nixos/nixpkgs nixos-21.05";
      };
    };
    /*
    dotfiles = {
      nixexprpath = "default.nix";
      keepnr = 50;
      schedulingshares = 100;
      checkinterval = 1800;
      type = 0;
      inputs = {
        nix-config = {
          type = "git";
          value = "https://git.sr.ht/~linuxhackerman/nix-config master";
          emailresponsible = false;
        };
        nixpkgs = {
          type = "git";
          value = "https://github.com/nixos/nixpkgs nixos-21.05";
        };
      };
    };*/
  };
  jobsetsJSON = (pkgs.formats.json {}).generate "jobsets.json" jobsets;
in { jobsets = jobsetsJSON; }
