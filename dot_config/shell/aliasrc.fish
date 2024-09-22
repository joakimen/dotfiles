# -*-sh-*-

alias lk "lefthook"

# quick edit
alias e $EDITOR
# alias fe "bf edit"

alias er "$EDITOR README.md"

## k8s
alias k kubectl
alias kt kubetail
alias kx kubectx
alias kn kubens
alias kz kustomize

# aws
alias list-functions="aws lambda list-functions | jq ".Functions[].FunctionName" -r | sort"

# clojure 
alias bbi "bbin install"
alias bbl "bbin ls"
alias repl='clojure -J--enable-preview -Sdeps "{:deps {nrepl/nrepl {:mvn/version \"RELEASE\"} cider/cider-nrepl {:mvn/version \"RELEASE\"}}}" -M -m nrepl.cmdline --middleware "[\"cider.nrepl/cider-middleware\"]"'

## system
alias pid 'ps aux | rg'
alias info 'info --vi-keys'
alias cdm "cd (mktemp -d)"
alias .. "cd .."
alias ... "cd ../.."
alias .... "cd ../../.."
alias ..... "cd ../../../.."
alias ...... "cd ../../../../.."
alias fd "fd --hidden"
alias kl kill-process
alias standup "fin -c 10:45 | nvim"

# git
alias g git
#alias c "git add . && git commit"
alias c "gi commit"
alias cdd "cd $HOME/dev/github.com"
alias cm chezmoi
alias ztig "bf git"
alias lg lazygit
alias nb "gi branch-create"
alias cpr "gi pr-checkout"

# maven
alias mci "mvn clean install"
alias mcv "mvn clean verify"
alias mcsv "mvn clean spotless:apply verify"

# terraform
alias tf terraform
alias tfi "terraform init"
alias tfp "terraform plan"
alias tfa "terraform apply"

# npm
alias n npm
alias ep "$EDITOR package.json"
alias nr node-run

# gpg
alias keys show-gpg-pubkey

if which eza &>/dev/null
    alias l 'eza -al'
    alias ls eza
    alias tree 'eza --tree'
else
    alias l 'ls -hlGALF'
    alias ls 'ls -GAF'
end
