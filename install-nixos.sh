#!/usr/bin/env bash
set -exuo pipefail

PROGRAM_NAME="$0"

inst() {
    local system="" host="" action="install"
    local -a nixCopyArgs
    while [[ "$#" -gt 0 ]] ; do
        case "$1" in
            -s)
                system="$2"
                shift 2
                ;;
            -h)
                host="$2"
                shift 2
                ;;
            -a)
                action="$2"
                shift 2
                ;;
            --substitute)
                nixCopyArgs+=(-s)
                shift
                ;;
            *)
                echo 'Usage: $PROGRAM_NAME -s <system> -h <host> [-a <action>] [--substitute]'
                exit -1
                ;;
        esac
    done
    : "${system:?pass system with -s}" "${host:?pass host with -h}"
    if [[ "$system" = *.drv ]]; then
        system=$(nix-store -r "$system")
    fi
    nix copy "${nixCopyArgs[@]}" --to ssh://root@"$host" "$system"
    case "$action" in
        install)
            ssh -t root@"$host" nix copy --no-require-sigs "$system" --to /mnt
            ssh root@"$host" nixos-install --no-root-passwd --no-channel-copy --system "$system"
            ;;
        switch|boot)
            ssh root@"$host" nix-env -p /nix/var/nix/profiles/system --set "$system"
            ;&
        *)
            ssh root@"$host" "$system/bin/switch-to-configuration $action"
            ;;
    esac
}

inst "$@"
