# config.fish
# Author: Joakim Engeset <joakim.engeset@gmail.com>

set -xg EDITOR nvim
set -xg RIPGREP_CONFIG_PATH ~/.config/rg/config
set -xg GO111MODULE on
set -xg FZF_DEFAULT_COMMAND 'fd --type f --hidden'
set -xg FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -xg FZF_DEFAULT_OPTS '--height 40% --border'
set -xg MANPAGER 'nvim +Man!'
set -xg LC_ALL "en_US.utf-8"
set -xg LPASS_AGENT_TIMEOUT 0
set -xg BAT_THEME base16
set -xg XDG_CONFIG_HOME "$HOME/.config"
#set -x DOCKER_HOST 'unix:///Users/joakle/.local/share/containers/podman/machine/podman-machine-default/podman.sock'
set -xg BUILDAH_FORMAT docker
set -xg AWS_VAULT_PROMPT osascript
set -g fish_greeting
set -xg DEFAULT_REGION "eu-west-1"
set -xg AWS_DEFAULT_REGION "eu-west-1"

bind \co "project-cd; commandline -f repaint"
bind \cb "switch-branch; commandline -f repaint"
bind \cy "aws-login; commandline -f repaint"
bind \cx "aws-exec; commandline -f repaint"
bind \e\cy "awschrome.sh capra-personal-admin; commandline -f repaint"
bind \e\ce "code ."

function _source
  [ -s $argv ] && . $argv
end

_source ~/.tokens.fish
_source ~/.z.fish
_source ~/.config/liflig/liflig.fish

set aliasfile $XDG_CONFIG_HOME/shell/aliasrc.fish
. $aliasfile
alias ac "e $aliasfile"

fish_add_path ~/go/bin ~/bin /usr/local/sbin ~/.emacs.d/bin ~/.local/bin /opt/homebrew/bin ~/.babashka/bbin/bin

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

# auto-attach/create tmux-session "main"
if not set -q TMUX; and not set -q TERM_PROGRAM; and not set -q __INTELLIJ_COMMAND_HISTFILE__
  tmux new -A -s main
end

function aws_complete
  complete --command $argv --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end

function timestamp --description "Simple timestamp for filenames"
  date +'%Y-%m-%d-%H-%m-%S'
end

aws_complete "aws"
aws_complete "awslocal"

starship init fish | source

alias bbi "bbin install"
alias bbu "bbin uninstall"
alias bbl "bbin ls"
