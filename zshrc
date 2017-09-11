ZSH_CACHE="${XDG_CACHE_HOME:=$HOME/.cache}/zsh"
[ -d "$ZSH_CACHE" ] || mkdir -p "$ZSH_CACHE"

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000

##############
# Completion #
##############

autoload -Uz compinit
compinit -D -d "$ZSH_CACHE/compdump"

# Hyphen and case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|[._-]=* r:|=*'

# Highlight current menu element
zstyle ':completion:*:*:*:*:*' menu select

# Enable caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path "$ZSH_CACHE"

# Menu completion colours matching ls
eval $(dircolors)
zstyle ':completion:*:default' list-colors "${(s.:.)LS_COLORS}"

############
# Bindings #
############
bindkey -e # Emacs
bindkey '^r' history-incremental-search-backward
b() {
    [ -n "$1" ] && bindkey "$1" "$2"
}
b "${terminfo[kcuu1]}" up-line-or-search # Up
b "${terminfo[kcud1]}" down-line-or-search # Down
b "${terminfo[kcbt]}" reverse-menu-complete # Shift-Tab
unfunction b


###########
# Aliases #
###########

export EDITOR=nvim
alias grep="grep --color=auto"
alias rg="rg -S"
alias ix="curl -F 'f:1=<-' ix.io"

#############
# Functions #
#############

wait_for() {
    local wait_pid
    if [[ $1 =~ ^[0-9]+$ ]] ; then
        if ps $1 > /dev/null ; then
            wait_pid=$1
        else
            print -- "PID given but process does not exist."
            return -1
        fi
    else
        # We only want one process, so let's get the newest and hope it's the
        # right one :)
        if ! wait_pid=$(pgrep -xn $1) ; then
            print -- "$1: process not found"
            return -1
        fi
    fi
    print "Waiting for PID $wait_pid."
    ps "$wait_pid"
    while ps $wait_pid > /dev/null ; do
        sleep 1
    done
}

closure() {
    nix-store -qR "$@" | xargs du -chd0 | sort -h
}


technical-details() {
    printf '- System: '
    nixos-version
    printf '- Nix version: '
    nix-env --version
    printf '- Nixpkgs version: '
    nix-instantiate --eval '<nixpkgs>' -A lib.nixpkgsVersion
    printf '- Sandboxing enabled: '
    grep build-use-sandbox /etc/nix/nix.conf | sed s/.*=//
}

storepath() {
    readlink -f $(which "$@")
}

###########
# Options #
###########

setopt AUTO_PUSHD PUSHD_IGNORE_DUPS CHASE_LINKS HIST_IGNORE_DUPS EXTENDED_HISTORY
unsetopt SHARE_HISTORY
unsetopt NOMATCH

zshaddhistory() {
    [[ $* =~ reboot ]] && return 1
    return 0
}
