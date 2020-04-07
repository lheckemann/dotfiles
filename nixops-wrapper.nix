{ writeShellScriptBin, nixops
, name
, requireConfirm ? true
, pre ? ""
}:
writeShellScriptBin name ''
  export NIXOPS_DEPLOYMENT=${name}
  if [[ " $*" = *\ deploy\ * ]] && [[ "$*" != *\ --dry-activate* ]] && [[ "$*" != *\ --build-only* ]] ; then
     read -p "really deploy? " confirm
     [[ $confirm = y ]] || exit
  fi
  exec nixops "$@"
''
