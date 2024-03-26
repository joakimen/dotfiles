# -*-sh-*-

# aws
alias totp "td get-aws-totp | pbcopy"

alias lk "lefthook"
# quick edit
alias e $EDITOR
alias fe "bf edit"
alias er "$EDITOR README.md"

## k8s
alias k kubectl
alias kt kubetail
alias kx kubectx
alias kn kubens
alias kz kustomize

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

# tmux
alias t "tmux new -A -s main"
alias tmux "tmux -2 -u"
alias tks "tmux kill-server"
alias tn tmux-new-session

# git
alias g git
#alias c "git add . && git commit"
alias c "gi commit"
alias cdd "cd $HOME/dev/github.com"
alias cm chezmoi
alias gw "gh repo view -w"
alias fb switch-branch
alias co switch-remote-branch
alias ztig "bf git"
alias lg lazygit
alias nb "gi branch-create"
alias cpr "gi pr-checkout"

# docker
#alias docker podman
#alias d podman
alias din docker-inspect
alias dpsa "docker ps -a"
alias dr docker-run
alias dcu "docker-compose up"
alias dco "docker-compose down"
alias dps docker-image-push
alias dil docker-image-list
alias dcs docker-container-start
alias dct docker-container-stop

# maven
alias mci "mvn clean install"
alias mcv "mvn clean verify"
alias mcsv "mvn clean spotless:apply verify"

# terraform
alias tf terraform
alias tfi "terraform init"
alias tfp "terraform plan"
alias tfa "terraform apply"

# ansible
alias ap ansible-playbook
alias av ansible-vault
alias update-macos "ansible-playbook $HOME/.config/ansible/mac.yml"



# npm
alias n npm
alias nr node-run
alias ep "$EDITOR package.json"

# gpg
alias keys show-gpg-pubkey


if which eza &>/dev/null
    alias l 'eza -al'
    alias ls eza
    alias tree 'eza --tree'
else if which lsd &>/dev/null
    alias l 'lsd -l --date=relative'
    alias ls lsd
    alias tree 'lsd --tree'
else
    echo "lsd missing"
    alias l 'ls -hlGALF'
    alias ls 'ls -GAF'
end
