{ nixpkgs ? <nixpkgs>
, pkgs ? import nixpkgs {}
, lib ? pkgs.lib
, declInput ? {}
}:
let
  blankJob = {
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
  defaultJob = lib.recursiveUpdate blankJob {
    inputs = {
      nixpkgs = {
        type = "build";
        value = "sources:nixpkgs";
      };
      emacs-overlay = {
        type = "build";
        value = "sources:emacs-overlay";
      };
    };
  };
  jobsets = rec {
    sources = lib.recursiveUpdate blankJob {
      nixexprpath = "nix/sources-hydra.nix";
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/nixos/nixpkgs nixos-21.05";
      };
    };
    user-config = lib.recursiveUpdate defaultJob {
      nixexprpath = "default.nix";
    };
    user-config-unpinned = lib.recursiveUpdate defaultJob {
      nixexprpath = "default.nix";
      inputs.nixpkgs = {
        type = "git";
        value = "https://github.com/nixos/nixpkgs nixos-21.05";
      };
      inputs.emacs-overlay = {
        type = "git";
        value = "https://github.com/nix-community/emacs-overlay master";
      };
      checkinterval = 86400;
      keepnr = 5;
    };
  };
  jobsetsJSON = (pkgs.formats.json {}).generate "jobsets.json" jobsets;
in { jobsets = jobsetsJSON; }
