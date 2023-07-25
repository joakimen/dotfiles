# -*-sh-*-

# quick edit
alias e $EDITOR
alias em "open -a Emacs"
alias vc "e ~/.config/nvim/init.lua"
alias kc "e ~/.config/kitty/kitty.conf"
alias ekc "e ~/.kube/config"
alias fc "e ~/.config/fish/config.fish"
alias tc "e ~/.tmux.conf"
alias bc "e ~/.bashrc"
alias zc "e ~/.zshrc"
alias gc "e ~/.gitconfig"
alias oc "e ~/.okrc"
alias srcz "source ~/.zshrc"
alias fe "bf edit"

alias er "$EDITOR README.md"

## k8s
alias k kubectl
alias kt kubetail
alias kx kubectx
alias kn kubens
alias kz kustomize

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

# tmux
alias t "tmux new -A -s main"
alias tmux "tmux -2 -u"
alias tks "tmux kill-server"
alias tn tmux-new-session

# git
alias g git
alias c "git add . && git commit"
alias cdd "cd $HOME/dev/github.com"
alias cm chezmoi
alias gw "gh repo view -w"
alias fb switch-branch
alias co switch-remote-branch
alias ztig ztig.sh
alias lg lazygit

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

# terraform
alias tf terraform
alias tfi "terraform init"
alias tfp "terraform plan"
alias tfa "terraform apply"

# ansible
alias ap ansible-playbook
alias av ansible-vault

# npm
alias n npm

# gpg
alias keys show-gpg-pubkey

if which lsd &>/dev/null
    alias l 'lsd -l --date=relative'
    alias l 'lsd -l'
    alias ls lsd
    alias tree 'lsd --tree'
else
    echo "lsd missing"
    alias l 'ls -hlGALF'
    alias ls 'ls -GAF'
end
