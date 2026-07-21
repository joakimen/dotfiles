# config.fish
# Author: Joakim Engeset <joakim.engeset@gmail.com>

# --- Environment variables ---
set -xg EDITOR nvim
set -xg RIPGREP_CONFIG_PATH ~/.config/rg/config
set -xg FZF_DEFAULT_OPTS '--style full --height 50% --border --walker-skip .git,node_modules,.clj-kondo,.cpcache,.venv,lib'
set -xg MANPAGER 'nvim +Man!'
set -xg LC_ALL "en_US.utf-8"
set -xg BAT_THEME base16
set -xg XDG_CONFIG_HOME "$HOME/.config"
set -xg AWS_VAULT_PROMPT osascript
set -xg GG_CLONE_DIR ~/dev/github.com
set -xg CLONE_DIR ~/dev/github.com
set -xg GG_GITHUB_USER joakimen
set -xg ZELLIJ_DEFAULT_SESSION default-session
set -xg HOMEBREW_NO_ENV_HINTS 1
set -xg MR_CONFIG "$HOME/.mrconfig"
set -xg MISE_NODE_DEFAULT_PACKAGES_FILE "$HOME/.config/mise/node-packages"
set -xg LIFLIG_DEV "$HOME/dev/github.com/capralifecycle"
set -xg ENABLE_LSP_TOOL 1

# --- Settings ---
set -g fish_greeting

# --- PATH ---
fish_add_path ~/go/bin ~/bin /usr/local/sbin ~/.emacs.d/bin ~/.local/bin /opt/homebrew/bin ~/.babashka/bbin/bin ~/.bun/bin

# Set gcloud PATH directly (avoids cd which triggers mise hooks)
set -l gcloud_bin "/opt/homebrew/share/google-cloud-sdk/bin"
if test -d $gcloud_bin; and not contains $gcloud_bin $PATH
    set -gx PATH $gcloud_bin $PATH
end


# --- Key bindings ---
function project-cd
    set -l project (scriv ls --absolute-paths | fzf)
    and builtin cd $project
end

function fish_user_key_bindings
    bind \co "project-cd; commandline -f execute"
    bind alt-o "project-cd; commandline -f execute"
    bind f3 "kf-edit; commandline -f execute"
    bind f4 "awsvault exec; commandline -f execute"
    bind f5 "awsvault login; and commandline -f execute"
end

# --- Abbreviations ---
abbr a aws
abbr g git
abbr k kubectl
abbr m make
abbr n npm
abbr cl claude
abbr cm chezmoi
abbr lg lazygit
abbr tf terraform

# --- Aliases ---
alias lk "lefthook"
alias e $EDITOR
alias er "$EDITOR README.md"

## k8s
alias kt kubetail
alias kx kubectx
alias kn kubens
alias kz kustomize

# aws
alias list-functions "aws lambda list-functions | jq '.Functions[].FunctionName' -r | sort"

# clojure 
alias bbi "bbin install"
alias bbl "bbin ls"
alias repl='clojure -J--enable-preview -Sdeps "{:deps {nrepl/nrepl {:mvn/version \"RELEASE\"} cider/cider-nrepl {:mvn/version \"RELEASE\"}}}" -M -m nrepl.cmdline --middleware "[\"cider.nrepl/cider-middleware\"]"'

## system
alias pid 'ps aux | rg'
alias cdm "cd (mktemp -d)"
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."
alias ...... "cd ../../../../.."
alias fd "fd --hidden"
alias kl kill-process
alias standup "fin -c 10:45 | nvim"
alias uuid "uuidgen | tr '[:upper:]' '[:lower:]'"

# git
alias cdd "cd $HOME/dev/github.com"

# maven
alias mci "mvn clean install"
alias mcv "mvn clean verify"
alias mcsv "mvn clean spotless:apply verify"

# npm
alias ep "$EDITOR package.json"
alias nr node-run

# sd (SeeD)
alias sdn "sd task new"
alias sdl "sd task list"
alias sds "sd task set"

alias ev "nvim ~/.config/nvim/init.lua"
alias acc "$LIFLIG_DEV/resources-definition/scripts/acc.ts"
alias idea "$HOME/bin/idea"

if command -q eza
    alias l 'eza --all --long --header --group-directories-first --icons --git'
    alias ls eza
    alias tree 'eza --tree'
else
    alias l 'ls -hlGALF'
    alias ls 'ls -GAF'
end

# --- Source external configs ---
_source ~/.tokens.fish
_source ~/.z.fish
_source ~/.config/liflig/liflig.fish

# --- Tool initialization ---
_cached_source starship init fish --print-full-init
_cached_source atuin init fish
_cached_source fnox activate fish

if status is-interactive
    _cached_source mise activate fish
else
    mise activate fish --shims | source
end

set -l safe_chain "$HOME/.safe-chain/scripts/init-fish.fish"
test -f $safe_chain && source $safe_chain

# ~/.config/fish/conf.d/sd.fish
# functions -c fish_prompt _starship_prompt
# function fish_prompt
#   _starship_prompt
#   if test -f ~/.local/share/sd/prompt.txt
#     set_color bryellow
#     printf ' %s' (cat ~/.local/share/sd/prompt.txt)
#     set_color normal
#   end
# end

function __sd_prompt_hook --on-event fish_prompt
  if test -f ~/.local/share/sd/prompt.txt
    set -gx SD_TASK (cat ~/.local/share/sd/prompt.txt)
  else
    set -e SD_TASK
  end
end

function acc-loop
    while read -P 'acc id: ' id; and test -n "$id"
        acc get $id
    end
end
