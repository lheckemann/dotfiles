SHELL=/bin/zsh
# Lines configured by zsh-newuser-install
#HISTFILE=~/.histfile
#HISTSIZE=5000
#SAVEHIST=5000
#setopt appendhistory autocd beep extendedglob nomatch
#unsetopt notify
#bindkey -v
## End of lines configured by zsh-newuser-install
## The following lines were added by compinstall
#zstyle :compinstall filename '/home/linus/.zshrc'
#
#autoload -Uz compinit
#compinit
## End of lines added by compinstall

# Path to your oh-my-zsh installation.
export ZSH=$HOME/software/oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="agnoster"
PROMPT_DIR_BG=19
PROMPT_DIR_FG=33
PROMPT_VCS_CLEAN_BG=22
PROMPT_VCS_CLEAN_FG=black
PROMPT_VCS_DIRTY_BG=58
PROMPT_VCS_DIRTY_FG=black

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zshmarks)
source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias j=jump

setopt AUTO_PUSHD
setopt CHASE_LINKS
unsetopt SHARE_HISTORY
unsetopt NOMATCH

source ${DOTFILES_PATH:-~/dotfiles/}shell-common
