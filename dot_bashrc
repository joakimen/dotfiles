# ============================================================================= 
# .bashrc
# Author: Joakim Engeset <joakim.engeset@gmail.com> 
# ============================================================================= 

# sourcing -----------------------------------------------------------------{{{

# global bashrc
[[ -f /etc/bashrc ]] && . /etc/bashrc

# api tokens
#[[ -f ~/.tokens ]] && . ~/.tokens

# enable completion
[[ -f /etc/bash_completion ]] && . /etc/bash_completion 

# fzf-bindings for bash
[[ -f ~/.fzf.bash ]] && . ~/.fzf.bash

# }}}
# options -----------------------------------------------------------------{{{

shopt -s histappend # Append to the history file
shopt -s checkwinsize # Check the window size after each command 

# }}}
# environment variables ----------------------------------------------------{{{

export PLATFORM=$(uname -s)
export EDITOR=nvim
export HISTSIZE=
export HISTCONTROL=ignoreboth:erasedups
export HISTFILESIZE=
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "
export COPYFILE_DISABLE=true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export XDG_CONFIG_HOME="$HOME/.config"

[ -z "$TMPDIR" ] && TMPDIR=/tmp

if [ -z "$PATH_EXPANDED" ]; then
  export PATH=~/bin:~/ruby:/opt/bin:/usr/local/bin:/usr/local/share/python:/usr/local/opt/go/libexec/bin:$PATH
  export PATH_EXPANDED=1
fi

if [ "$PLATFORM" != 'Darwin' ]; then
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.:/usr/local/lib
fi

# fzf
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200'"
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden --bind '?:toggle-preview'"
command -v blsd > /dev/null && export FZF_ALT_C_COMMAND='blsd'
command -v tree > /dev/null && export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# }}}

# aliases
source $XDG_CONFIG_HOME/shell/aliasrc

# functions ----------------------------------------------------------------{{{

# tarball all files in $PWD
ext() {
  local name=$(basename $(pwd))
  cd ..
  tar -cvzf "$name.tgz" --exclude .git --exclude target --exclude "*.log" "$name"
  cd -
  mv ../"$name".tgz .
}

# fuzzy-cd
fd() {
  DIR=`find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf-tmux` \
    && cd "$DIR"
}

# determine if we're currently in a git repository
is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

# fuzzy-checkout git branch
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fuzzy-find to vim
fe() {
  local file
  file=$(fzf-tmux --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-nvim} "$file"
}

# git diff
gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-tmux -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

# git branch
gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-tmux --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

# git tag
gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-tmux --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

# git history
gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph |
  fzf-tmux --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

# git remote
gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-tmux --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

# determine largest static-data files
staticdata() {
  ls $W_REPO/WigginDB/Data/*.sql | xargs wc -l | sort -k 1 -r | fzf-tmux
}

# return ip of parallels instance
prl_ip() {
  prlctl list "Windows 10" -o ip | grep -o '\d\{1,3\}\.\d\{1,3\}\.\d\{1,3\}\.\d\{1,3\}'
}

# check network connectivity
n() {
  nc -z google.com 80 -G 2
}

# }}}
# prompt -------------------------------------------------------------------{{{

if [ "$PLATFORM" = Linux ]; then
  PS1="\[\e[1;38m\]\u\[\e[1;34m\]@\[\e[1;31m\]\h\[\e[1;30m\]:"
  PS1="$PS1\[\e[0;38m\]\w\[\e[1;35m\]> \[\e[0m\]"
else
  # git-prompt
  __git_ps1() { :;}
  if [ -e ~/.git-prompt.sh ]; then
    source ~/.git-prompt.sh
  fi

  PROMPT_COMMAND='history -a; printf "\[\e[38;5;59m\]%$(($COLUMNS - 4))s\r" "$(__git_ps1) ($(date +%m/%d\ %H:%M:%S))"'
  PS1="\[\e[34m\]\u\[\e[1;32m\]@\[\e[0;33m\]\h\[\e[35m\]:"
  PS1="$PS1\[\e[m\]\w\[\e[1;31m\]> \[\e[0m\]"
fi

# }}}
