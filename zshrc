: ${DOTFILES_HOME:=~/dotfiles}
ZSH_CACHE="${XDG_CACHE_HOME:=$HOME/.cache}/zsh"
[ -d "$ZSH_CACHE" ] || mkdir -p "$ZSH_CACHE"

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

################
# Fancy prompt #
################
PROMPT_DIR_BG=19
PROMPT_DIR_FG=33
PROMPT_VCS_CLEAN_BG=22
PROMPT_VCS_CLEAN_FG=black
PROMPT_VCS_DIRTY_BG=58
PROMPT_VCS_DIRTY_FG=black
source $DOTFILES_HOME/zsh/agnoster.zsh-theme

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

# Fancy kill completion menu                                   pid      user          comm     etime
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#) #([^ ]#) #([0-9:]#)*=0=0=0=01;36=0=0'
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm,etime -w -w"

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
# TODO add ctrl-right|left mapping to forward|backward-word
b "${terminfo[kcbt]}" reverse-menu-complete # Shift-Tab
unfunction b

###########
# Aliases #
###########

source "$DOTFILES_HOME/zsh/zshmarks/init.zsh"
alias j=jump

###########
# Options #
###########

setopt AUTO_PUSHD PUSHD_IGNORE_DUPS CHASE_LINKS HIST_IGNORE_DUPS EXTENDED_HISTORY
unsetopt SHARE_HISTORY
unsetopt NOMATCH

source "$DOTFILES_HOME/shell-common"
