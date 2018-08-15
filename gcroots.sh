#!/usr/bin/env bash
err_log=$(mktemp --tmpdir gcroots-XXXXXXX)
exec 2>$err_log
trap 'status=$?; cat '"$err_log"'; exit $status' err
#trap "rm $err_log" exit
set -ex
usage() {
    echo "Usage: $0 <gcroot-dir-name> <drv>"
    exit -1
}
[[ -z "$1" ]] || [[ -z "$2" ]] && usage

gcroot_dir=/nix/var/nix/gcroots/per-user/$USER/$1
mkdir $gcroot_dir
nix-store -qR "$2" | (
    i=0
    while read drv; do
        ((i++)) || true
        ln -s $drv $gcroot_dir/$i
    done
)
for link in $gcroot_dir/*; do
    [[ $(readlink $link) = *.drv ]] || continue
    nix-store -q --outputs $link | (
        i=0
        while read output; do
            ((i++)) || true
            ln -s $output $link.$i
        done
    )
done

echo "Created $gcroot_dir"
