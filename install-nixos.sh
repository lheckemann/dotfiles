#!/usr/bin/env bash
set -exuo pipefail

PROGRAM_NAME="$0"

inst() {
    local system="" host="" action="install" from="auto" mount=""
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
            -f)
                from="$2"
                shift 2
                ;;
            -m)
                mount=1
                shift
                ;;
            *)
                echo 'Usage: $PROGRAM_NAME -s <system> -h <host> [-a <action>] [--substitute] [-f <store>]'
                exit 1
                ;;
        esac
    done
    : "${system:?pass system with -s}" "${host:?pass host with -h}"
    if [[ "$system" = *.drv ]]; then
        system=$(nix-store --store "$from" -r "$system")
    fi

    if [[ -n "$mount" && "$action" != "install" ]] ; then
        echo "-m specified, but action isn't install"
        exit 1
    fi

    nix copy "${nixCopyArgs[@]}" --from "$from" --to ssh://root@"$host" "$system"
    case "$action" in
        install)
            if [[ -n "$mount" ]] ; then
                ssh root@"$host" findmnt /mnt && ssh root@"$host" umount -Rlv /mnt
                ssh root@"$host" mount -v -T "$system/etc/fstab" --target-prefix /mnt -o X-mount.mkdir /
                ssh root@"$host" mount -v -T "$system/etc/fstab" --target-prefix /mnt -o X-mount.mkdir --all
            fi
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
