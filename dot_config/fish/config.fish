# config.fish
# Author: Joakim Engeset <joakim.engeset@gmail.com>

# this voodoo makes awyeah async stuff work consistently in babashka
set -xg BABASHKA_PRELOADS "(alter-var-root #'clojure.core.async/go (constantly @#'clojure.core.async/thread))"
set -xg EDITOR nvim
set -xg RIPGREP_CONFIG_PATH ~/.config/rg/config
set -xg FZF_DEFAULT_COMMAND 'fd --type f --hidden'
set -xg FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -xg FZF_DEFAULT_OPTS '--height 40% --border'
set -xg MANPAGER 'nvim +Man!'
set -xg LC_ALL "en_US.utf-8"
set -xg BAT_THEME base16
set -xg XDG_CONFIG_HOME "$HOME/.config"
#set -x DOCKER_HOST 'unix:///Users/joakle/.local/share/containers/podman/machine/podman-machine-default/podman.sock'
set -xg BUILDAH_FORMAT docker
set -xg AWS_VAULT_PROMPT osascript
set -g fish_greeting
set -xg DEFAULT_REGION "eu-west-1"
set -xg AWS_DEFAULT_REGION "eu-west-1"
set -xg ANSIBLE_LOCALHOST_WARNING false
set -xg ANSIBLE_INVENTORY_UNPARSED_WARNING false
set -xg SPACESHIP_EXIT_CODE_SHOW true
# set -xg GIT_USER_PREFIX "jol"


# if updated, run $ mise where python@3.12 for the current path
set -xg CLOUDSDK_PYTHON "~/.local/share/mise/installs/python/3.12.3/bin/python3"

bind \co "project-cd; commandline -f execute"
bind \cb "gi branch-switch; commandline -f execute"
# add support for multiple pattterns/teams
bind -k f2 "goland-open; commandline -f execute"
bind -k f3 "kf edit; commandline -f execute"
bind -k f4 "awsvault exec; commandline -f execute"
bind -k f5 "awsvault login; and commandline -f execute"
bind \e\ce "code ."
bind \e\cb nvim


set aliasfile $XDG_CONFIG_HOME/shell/aliasrc.fish
alias ac="e $aliasfile"

function _source
  [ -s $argv ] && . $argv
end

_source ~/.tokens.fish
_source ~/.z.fish
_source ~/.config/liflig/liflig.fish
_source $aliasfile

# this file contains aliases to run cli tools (gh, etc)
# with credentials from 1Password
# _source ~/.config/op/plugins.sh

fish_add_path ~/go/bin ~/bin /usr/local/sbin ~/.emacs.d/bin ~/.local/bin /opt/homebrew/bin ~/.babashka/bbin/bin 
# ~/.local/bin/google-cloud-sdk/bin


function sudo --description '!!-support for sudo'
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

# Use fd instead of the default find for listing path candidates.
function _fzf_compgen_path
    fd --hidden --follow --exclude ".git" . "$1"
end

# Use fd to generate the list for directory completion
function _fzf_compgen_dir
    fd --type d --hidden --follow --exclude ".git" . "$1"
end

# not needed while using wezterm
# auto-attach/create tmux-session "main"
# if not set -q TMUX; and not set -q TERM_PROGRAM; and not set -q __INTELLIJ_COMMAND_HISTFILE__
#   tmux new -A -s main
# end

function aws_complete
  complete --command $argv --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end

function timestamp --description "Simple timestamp for filenames"
  date +'%Y-%m-%d_%H-%M-%S'
end

aws_complete "aws"
aws_complete "awslocal"

# The next line updates PATH for the Google Cloud SDK.
source "/opt/homebrew/share/google-cloud-sdk/path.fish.inc"

starship init fish | source
atuin init fish | source

# used to activate shims for non-interactive shells, such as when running VS Code
if status is-interactive
  mise activate fish | source
else
  mise activate fish --shims | source
end

alias assume="source (brew --prefix)/bin/assume.fish"

