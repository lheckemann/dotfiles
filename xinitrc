#!/bin/bash
CMD=
case "$(ps -o args= -p "$$")" in
    sh*)
        exec bash $0
        ;;
    bash*)
        ;;
    *)
        echo "Unknown interpreter"
        ;;
esac

message() {
    printf "%s" -- "$*" | fold -s -w ${COLUMNS:-80} | tee /dev/fd/3 3> >(xmessage -file -)
}

error_message() {
    message "$*"
    exit -1
}

ERRORS="$HOME/.xsession-errors"
if [[ -w $ERRORS ]] || touch "$ERRORS"
then
    exec &> >(tee -a "$ERRORS") 2>&1
else
    error_message "Error: Cannot write to $ERRORS"
fi

[[ $1 = failsafe ]] && exec x-terminal-emulator
[[ -r $HOME/.xsessionrc ]] && . "$HOME/.xsessionrc"
xhost "+si:localuser:$(id -un)"

if ssh-add -l &>/dev/null ; [[ $? = 2 ]]
then
    export SSH_AUTH_SOCK="/run/user/$UID/ssh-agent.sock"
    if ssh-add -l &>/dev/null; [[ $? = 2 ]]
    then
        eval $(ssh-agent -a "/run/user/$UID/ssh-agent.sock")
    fi
fi

export _JAVA_AWT_WM_NONREPARENTING=1

export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/dbus-session.sock"
dbus-daemon --session "--address=$DBUS_SESSION_BUS_ADDRESS" &

xautolock -locker 'i3lock -c 006060' -time 10 &

# TODO: GPG agent?

exec i3
