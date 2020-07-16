#!/usr/bin/env bash

script=$(basename "$0")
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password=$(find -L "$prefix" -type f -name '*.gpg' -printf '%P\n' |
                sed 's/\.gpg$//' | bemenu --fn Hack -p "" -i --hf=#00ffff)

[[ -n $password ]] || exit

typeit=0
hasuserfield=0
only=0

opts=$(getopt -o tou: --long typeit,only,userfield: -n "$script" -- "$@")
eval set -- "$opts"

while true ; do
    case "$1" in
        -u|--userfield)
            case "$2" in
                "") shift 2 ;;
                *) hasuserfield=1 ; userfield=$2 ; shift 2 ;;
            esac ;;
        -t|--typeit) typeit=1 ; shift ;;
        -o|--only) only=1 ; shift ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

if [ $hasuserfield -eq 1 ] && [ $typeit -eq 1 ]; then
    if [ $only -eq 0 ]; then
        pass show "$password" |
            awk -v userfield="$userfield" 'BEGIN{ORS=""} NR==1 { pw=$0} match($0, userfield) {print $0 "\t" pw; exit}' |
            sed -n "s/${userfield}:\s\?\(.*\)/\1/p" |
            ydotool type --file -
    else
        pass show "$password" |
            awk -v userfield="$userfield" 'match($0, userfield) {print $0; exit}' |
            sed -n "s/${userfield}:\s\?\(.*\)/\1/p" |
            ydotool type --file -
        pass show -c "$password" 2>/dev/null
    fi
elif [ $typeit -eq 1 ]; then
    pass show "$password" |
        awk 'BEGIN{ORS=""} {print; exit}' |
        ydotool type --file -
elif [ $hasuserfield -eq 1 ]; then
    pass show "$password" |
        awk -v userfield="$userfield" 'match($0, userfield) {print $0; exit}' |
        sed -n "s/${userfield}:\s\?\(.*\)/\1/p"
else
    pass show -c "$password" 2>/dev/null
fi
