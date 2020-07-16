{ writeScriptBin, nixops, bashInteractive
, name
, requireConfirm ? true
, pre ? ""
}:
writeScriptBin name ''
  #!${bashInteractive}${bashInteractive.shellPath}
  export NIXOPS_DEPLOYMENT=${name}
  ${pre}
  if [[ " $*" = *\ deploy\ * ]] && [[ "$*" != *\ --dry-activate* ]] && [[ "$*" != *\ --build-only* ]] ; then
     read -p "really deploy? " -N1 confirm
     echo
     [[ $confirm = y ]] || exit
  fi
  exec nixops "$@"
''
