# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:/Users/joakim/.docker/bin"
# End of Docker Desktop section.

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
set -xg ZELLIJ_DEFAULT_SESSION default-session
set -xg HOMEBREW_NO_ENV_HINTS 1
set -xg MR_CONFIG "$HOME/.mrconfig"
set -xg MISE_FISH_AUTO_ACTIVATE 1
set -xg LIFLIG_DEV "$HOME/dev/github.com/capralifecycle"
set -xg ENABLE_LSP_TOOL 1  # used by claude

# --- Settings ---
set -g fish_greeting

# --- PATH ---
fish_add_path ~/go/bin /usr/local/sbin ~/.emacs.d/bin ~/.local/bin /opt/homebrew/bin ~/.babashka/bbin/bin ~/.bun/bin ~/.cargo/bin 

# Set gcloud PATH directly (avoids cd which triggers mise hooks)
set -l gcloud_bin "/opt/homebrew/share/google-cloud-sdk/bin"
if test -d $gcloud_bin; and not contains $gcloud_bin $PATH
    set -gx PATH $gcloud_bin $PATH
end


# --- Key bindings ---
# cid emits its functions, its aliases (fe, kl, i, b) and cid
# from [shell.bindings] and [shell.aliases] in ~/.config/cid/config.toml, so
# that file is watched alongside the binary.
_cached_source --watch ~/.config/cid/config.toml cid init fish

function fish_user_key_bindings
    cid_key_bindings
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
abbr kt kubetail
abbr kx kubectx
abbr kn kubens
abbr kz kustomize

# --- Aliases ---
alias lk "lefthook"
alias e $EDITOR
alias er "$EDITOR README.md"

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
_source ~/.config/liflig/liflig.fish

# --- Tool initialization ---
_cached_source starship init fish --print-full-init
_cached_source fnox activate fish
# _cached_source zoxide init fish

# set -l safe_chain "$HOME/.safe-chain/scripts/init-fish.fish"
# test -f $safe_chain && source $safe_chain

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

function fix-title
  herdr tab rename $HERDR_TAB_ID (basename $PWD) 1>/dev/null
end

# excluded: gcloud
set -U _tide_right_items status cmd_duration context jobs direnv bun node python rustc java pulumi ruby go terraform aws zig time

