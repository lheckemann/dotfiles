{ writeTextFile, nixops, bashInteractive, shellcheck
, name
, requireConfirm ? true
, pre ? ""
}:
writeTextFile {
  inherit name;
  destination = "/bin/${name}";
  executable = true;
  checkPhase = ''
    ${shellcheck}/bin/shellcheck $out/bin/${name}
  '';
  text = ''
    #!${bashInteractive}${bashInteractive.shellPath}
    export NIXOPS_DEPLOYMENT=${name}
    ${pre}
    if [[ " $*" = *\ deploy\ * ]]; then
      case "$*" in
        *\ --dry-activate* | *\ --build-only* | *\ --dry-run* | *\ --copy-only*) ;;
        *)
          read -rp "really deploy? " -N1 confirm
          echo
          [[ $confirm = y ]] || exit
          ;;
      esac
    fi
    exec nixops "$@"
  '';
}
