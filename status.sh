#!/usr/bin/env bash
exec 5< <(i3status -c ~/.nix-profile/etc/i3status.conf)
while read -u 5 line ; do
    wpa_cli -i wlp4s0 status | grep -q WIFIonICE
    if [[ "$?" == 0 ]] && status=$(curl -sSf https://iceportal.de/api1/rs/status) && speed=$(jq .speed <<<"$status") ; then
        printf "%s\n" "$line" | sed 's/^,\[/,[{"name":"speed","full_text": "🚂 '"$speed"'km\/h"},/'
    else
        printf "%s\n" "$line"
    fi
done
