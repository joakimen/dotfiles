# config.fish
# Author: Joakim Engeset <joakim.engeset@gmail.com>

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
# set -xg DEFAULT_REGION "eu-west-1"
# set -xg AWS_DEFAULT_REGION "eu-west-1"
# set -xg ANSIBLE_LOCALHOST_WARNING false
# set -xg ANSIBLE_INVENTORY_UNPARSED_WARNING false
set -xg GG_CLONE_DIR ~/dev/github.com
set -xg CLONE_DIR ~/dev/github.com
set -xg GG_GITHUB_USER joakimen
set -xg SPACESHIP_EXIT_CODE_SHOW true
set -xg ZELLIJ_DEFAULT_SESSION "default-session"
set -xg HOMEBREW_NO_ENV_HINTS 1
set -xg MR_CONFIG "$HOME/.mrconfig"
# if updated, run $ mise where python@3.12 for the current path
# set -xg CLOUDSDK_PYTHON "~/.local/share/mise/installs/python/3.12.3/bin/python3"

set -g fish_greeting

# regular keyboard
bind \co "project-cd; commandline -f execute"
# glove80
bind alt-o "project-cd; commandline -f execute"

bind \cb "gi branch-switch; commandline -f execute"

# add support for multiple pattterns/teams
bind f3 "kf-edit; commandline -f execute"
bind f4 "awsvault exec; commandline -f execute"
bind f5 "awsvault login; and commandline -f execute"

set aliasfile $XDG_CONFIG_HOME/shell/aliasrc.fish

set -xg LIFLIG_DEV "$HOME/dev/github.com/capralifecycle"

alias acc="$LIFLIG_DEV/resources-definition/scripts/acc.ts"
alias ac="e $aliasfile"

function _source
  [ -s $argv ] && . $argv
end

_source ~/.tokens.fish
_source ~/.z.fish
_source ~/.config/liflig/liflig.fish
_source $aliasfile

function fe
  set file (fzf)
  if test -n "$file"
    $EDITOR $file
  end
end

function kf-edit
    set file (kf list | fzf)
    if test -n "$file"
        $EDITOR (eval echo $file)
    end
end

# this file contains aliases to run cli tools (gh, etc)
# with credentials from 1Password
# _source ~/.config/op/plugins.sh

fish_add_path ~/go/bin ~/bin /usr/local/sbin ~/.emacs.d/bin ~/.local/bin /opt/homebrew/bin ~/.babashka/bbin/bin 
# ~/.local/bin/google-cloud-sdk/bin

set bindir "$HOME/bin"
alias idea "$bindir/shell/idea"

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

function aws_complete
  complete --command $argv --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)'
end

function timestamp --description "Simple timestamp for filenames"
  date +'%Y-%m-%d_%H-%M-%S'
end

function ztig
  set file (git ls-files | fzf --preview 'bat {} --line-range :30')
  if test -n "$file"
    lazygit -f "$file"
  end
end

function erg
    set matches (rg --vimgrep $argv[1])
    if test $status -eq 0
        printf "%s\n" $matches | nvim -c 'cb | copen' -
    end
end

function nr
    set scripts ($bindir/node/npmscripts.ts)
    if test -z "$scripts"
        return
    end
    set script (printf "%s\n" $scripts | gum filter --height 8)
    if test -z "$script"
        return
    end
    npm run "$script"
end

aws_complete "aws"
aws_complete "awslocal"

function bmise
    switch $argv[1]
        case install
            set lang (mise plugin ls --core --user | fzf)
            if test -z "$lang"
                return
            end
            set lang_version (mise ls-remote "$lang" | fzf)
            if test -z "$version"
                return
            end
            echo "Installing $lang@$lang_version"
            mise install "$lang@$lang_version"
        case use
            set lang (mise ls --json | jq 'keys[]' -r | fzf)
            if test -z "$lang"
                return
            end
            set lang_version (mise ls "$lang" --json | jq '.[].version' -r | fzf)
            if test -z "$lang_version"
                return
            end
            echo "Using $lang@$lang_version"
            mise use "$lang@$lang_version"
        case '*'
            echo "Usage: bmise install|use <version>"
    end
end

function kill-process
    set pid (ps axo user=,pid=,time=,args= | fzf | awk '{print $2}')
    if test -n "$pid"
        echo "killing process: $pid"
        kill -9 $pid
    end
end

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
