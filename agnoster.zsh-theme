# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
# A Powerline-inspired theme for ZSH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://github.com/Lokaltog/powerline-fonts).
# Make sure you have a recent version: the code points that Powerline
# uses changed in 2012, and older versions will display incorrectly,
# in confusing ways.
#
# In addition, I recommend the
# [Solarized theme](https://github.com/altercation/solarized/) and, if you're
# using it on Mac OS X, [iTerm 2](http://www.iterm2.com/) over Terminal.app -
# it has significantly better color fidelity.
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

setopt PROMPT_SUBST

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

# Special Powerline characters

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"
  SEGMENT_SEPARATOR=$'\ue0b0' # 
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
PROMPT_CONTEXT_BG=${PROMPT_CONTEXT_BG:-black}
PROMPT_CONTEXT_FG=${PROMPT_CONTEXT_FG:-default}
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment $PROMPT_CONTEXT_BG $PROMPT_CONTEXT_FG "%(!.%{%F{yellow}%}.)${USER}@%m"
  fi
}

PROMPT_VCS_UNTRACKED_BG=${PROMPT_VCS_UNTRACKED_BG:-red}
PROMPT_VCS_UNTRACKED_FG=${PROMPT_VCS_UNTRACKED_FG:-white}
PROMPT_VCS_CLEAN_BG=${PROMPT_VCS_CLEAN_BG:-green}
PROMPT_VCS_CLEAN_FG=${PROMPT_VCS_CLEAN_FG:-black}
PROMPT_VCS_DIRTY_BG=${PROMPT_VCS_DIRTY_BG:-yellow}
PROMPT_VCS_DIRTY_FG=${PROMPT_VCS_DIRTY_FG:-black}
# Git: branch/detached head, dirty status
prompt_git() {
  type git &>/dev/null || return

  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path
  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(git status --porcelain --untracked-files=no --ignore-submodules=dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment $PROMPT_VCS_DIRTY_BG $PROMPT_VCS_DIRTY_FG
    else
      prompt_segment $PROMPT_VCS_CLEAN_BG $PROMPT_VCS_CLEAN_FG
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:git:*' unstagedstr '●'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

prompt_hg() {
  type hg &>/dev/null || return
  local rev st id branch
  id="$(hg id --num --branch 2>/dev/null)" || return
  st=""
  rev=${id%%[ +]*}
  branch=${id##* }
  if [[ -n $(hg status --unknown) ]] ; then
    prompt_segment ${PROMPT_VCS_UNTRACKED_BG} ${PROMPT_VCS_UNTRACKED_FG}
    st='±'
  elif [[ $id == *+\ * ]]; then
    prompt_segment ${PROMPT_VCS_DIRTY_BG} ${PROMPT_VCS_DIRTY_FG}
    st='±'
  else
    prompt_segment ${PROMPT_VCS_CLEAN_BG} ${PROMPT_VCS_CLEAN_FG}
  fi
  echo -n "☿ $rev@$branch" $st
}

# Dir: current working directory
PROMPT_DIR_BG=${PROMPT_DIR_BG:-blue}
PROMPT_DIR_FG=${PROMPT_DIR_FG:-black}
PROMPT_MAX_DIRLEN=${PROMPT_MAX_DIRLEN:-40}
PROMPT_CHOPPED_DIRLEN=$(( $PROMPT_MAX_DIRLEN - 2 ))
prompt_dir() {
  local wd="${${(%):-%~}}"
  [ "${#wd}" -gt "$PROMPT_MAX_DIRLEN" ] && wd="..${wd:(-$PROMPT_CHOPPED_DIRLEN)}"
  prompt_segment $PROMPT_DIR_BG $PROMPT_DIR_FG "$wd"
}

# Virtualenv: current working virtualenv
PROMPT_VENV_BG=${PROMPT_VENV_BG:-blue}
PROMPT_VENV_FG=${PROMPT_VENV_FG:-black}
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV" shell_name="${name:-nix-shell}"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment $PROMPT_VENV_BG $PROMPT_VENV_FG "(`basename $virtualenv_path`)"
  fi
  if [[ $IN_NIX_SHELL ]]; then
    prompt_segment $PROMPT_VENV_BG $PROMPT_VENV_FG "${shell_name%-*}"
  fi
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"
  type systemd-tty-ask-password-agent &>/dev/null && [[ -n $(systemd-tty-ask-password-agent --list) ]] && symbols+="%{%F{yellow}%}🔑"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_hg
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
