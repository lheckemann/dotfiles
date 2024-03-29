#!/usr/bin/env nix-shell
#!nix-shell -i bash -p tigervnc icewm pwgen minica
setup() {
    local tmpDir xsocket passwd viewpasswd bold end
    tmpDir=$(mktemp -d --tmpdir give-me-x.XXXXXXXX)
    for i in {0..20} ; do
        # Check if X display is available
        ! [[ -e /tmp/.X11-unix/X$i ]] || continue
        # Check if VNC port is available
        netstat -ltnW | awk '{print $4}' | grep -Eq ":$((5900+i))\$" || break
    done
    export DISPLAY=:$i
    xsocket=/tmp/.X11-unix/X$i

    passwd=$(pwgen -s 8 1)
    viewpasswd=$(pwgen -s 8 1)
    echo "$passwd"$'\n'"$viewpasswd" | vncpasswd -f > "$tmpDir/vncpasswd"

    ( cd "$tmpDir" || exit; minica --domains "$(hostname)" ; mv ./*/{cert,key}.pem . )
    cat "$tmpDir/cert.pem" "$tmpDir/minica.pem" > "$tmpDir/chain.pem"


    Xvnc $DISPLAY -SecurityTypes X509Vnc -rfbauth "$tmpDir/vncpasswd" -X509Cert "$tmpDir/chain.pem" -X509Key "$tmpDir/key.pem" &> "$tmpDir/xvnc.log" &
    xvncpid=$!

    bold=$'\e[1m'
    end=$'\e[m'
    sleep 0.2
    until [[ -e $xsocket ]] ; do
        if [[ $((waiting++)) -gt 5 ]] ; then
            echo "Timed out waiting for X socket"
            kill $xvncpid
            exit 1
        fi
    done
    icewm &>"$tmpDir/icewm.log" &

    cat <<EOF
${bold}Display:${end} :$i (VNC port $((i + 5900)))
${bold}Password:${end} $passwd
${bold}View-only password:${end} $viewpasswd
${bold}CA cert:${end} $tmpDir/minica.pem   ($(openssl x509 -in "$tmpDir/minica.pem" -noout -fingerprint))
${bold}Server cert:${end} $tmpDir/cert.pem ($(openssl x509 -in "$tmpDir/cert.pem" -noout -fingerprint))

Forward the port via SSH or make sure it is opened in the firewall to proceed.
EOF
    bash
    echo Cleaning up...
    kill "$xvncpid"
    rm -rf "$tmpDir"
}
{ setup; }
