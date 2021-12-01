#!/bin/bash

IFS='' read -r -d '' USER_SETTINGS <<"EOF"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Prompt Colors
NC='\[\033[m\]'
RED='\[\033[1;31m\]'
YELLOW='\[\033[1;34m\]'
CYAN='\[\033[38;5;11m\]'
LIGHTPURPLE='\[\033[1;35m\]'

function fancy_prompt {
  if [[ $? == 0 ]]; then
    PROMPT_END="$NC>"
  else
    PROMPT_END="$RED>$NC"
  fi
  if [[ $(id -u) -eq 0 ]]; then
    PROMPT_USER="$RED\u$NC"
  else
    PROMPT_USER="$CYAN\u$NC"
  fi
  if [[ -z $SSH_CLIENT ]]; then
    PS1="$PROMPT_USER $YELLOW\w$NC $PROMPT_END "
  else
    PS1="$PROMPT_USER@$LIGHTPURPLE\h $YELLOW\w$NC $PROMPT_END "
  fi
}
PROMPT_COMMAND="fancy_prompt"

# Nagivation
alias cdf='cd $(ls | fzf)'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Listing 
alias ll="ls -l"
alias lo="ls -o"
alias lh="ls -lh"
alias la="ls -la"
alias hidden="history -d $((HISTCMD-1))"

# History
export HISTFILESIZE=20000
export HISTSIZE=10000
shopt -s histappend
shopt -s cmdhist
export HISTCONTROL="ignoredups:ignorespace"
export HISTIGNORE="&:ls:[bf]g:exit"
export EDITOR=vim

# Traverse directories
function up {
  local d=""
  limit=$1
  for ((i=1 ; i <= limit ; i++))
    do
      d=$d/..
    done
  d=$(echo $d | sed 's/^\///')
  if [ -z "$d" ]; then
    d=..
  fi
  cd $d
}

# Awk Column -- df -h|fawk 2
function fawk {
    first="awk '{print "
    last="}'"
    cmd="${first}\$${1}${last}"
    eval $cmd
}

#dirsize - finds directory sizes and lists them
function dirsize {
    du -shx * .[a-zA-Z0-9_]* 2> /dev/null | \
    egrep '^ *[0-9.]*[MG]' | sort -n > /tmp/list
    egrep '^ *[0-9.]*M' /tmp/list
    egrep '^ *[0-9.]*G' /tmp/list
    rm -rf /tmp/list
}

# Manpage colors
man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

# Extract archive
function extract {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)  tar xvjf $1   ;;
      *.tar.gz)   tar xvzf $1   ;;
      *.bz2)     bunzip2 $1    ;;
      *.rar)     unrar x $1     ;;
      *.gz)      gunzip $1    ;;
      *.tar)     tar xvf $1    ;;
      *.tbz2)    tar xvjf $1   ;;
      *.tgz)     tar xvzf $1   ;;
      *.zip)     unzip $1     ;;
      *.Z)      uncompress $1  ;;
      *.7z)      7z x $1      ;;
      *)        echo "don't know how to extract '$1'..." ;;
    esac
  else
    echo "'$1' is not a valid file!"
  fi
}
EOF

IFS='' read -r -d '' RC_SOURCE <<"EOF"
# SCRIPT MANAGED | Source .bashrc to not lose default user settings
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

IFS='' read -r -d '' ADD_BINARIES <<"EOF"
# SCRIPT MANAGED | Add common binaries to user path
PATH=$PATH:$HOME/.local/bin
export PATH
EOF

if [[ ! -f ~/.bash_profile ]]; then
    printf '%s\n%s\n%s\n' "$USER_SETTINGS" "$RC_SOURCE" "$ADD_BINARIES" > ~/.bash_profile
else
    if grep -q '.bashrc' ~/.bash_profile; then
      if grep -q 'fancy_prompt' ~/.bash_profile; then
        exit 0 # nothing to do
      else
        printf '%s\n%s\n%s\n' "$USER_SETTINGS" "$ADD_BINARIES" "$(cat ~/.bash_profile)" > ~/.bash_profile
      fi
    else
      printf '%s\n%s\n%s\n%s\n' "$USER_SETTINGS" "$RC_SOURCE" "$ADD_BINARIES" "$(cat ~/.bash_profile)" > ~/.bash_profile
    fi
fi
