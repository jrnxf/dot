export ZSH="$HOME/.oh-my-zsh"

plugins=(git tmux zsh-autosuggestions)

# i like this but it's annoying in vscode
# ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

export PATH=~/bin:~/.local/bin:~/go/bin:~/.cargo/bin:~/Dev/pocus/development/scripts:$PATH

export EDITOR="nvim"

alias dev="~/Dev"
alias p="cd ~/Dev/pocus"
alias reload="source ~/.zshrc"
alias privateip="hostname -I"
alias publicip="curl icanhazip.com"
alias clear="clear && printf '\e[3J'"
alias skrrrt="cd ~/Dev/skrrrt"
alias s="skrrrt"
alias dot="cd ~/dotfiles"
alias x="exit"
alias q="clear"
alias tmux="tmux -2" # keep colorscheme in tmux
alias gotop="gotop --mbps"
alias ls="exa"
alias cat="cat"

alias fzf='fzf --height=90% --preview "bat --line-range :500 {}" --preview-window right,border-left  --padding=0'

alias v='nvim .'
alias vim="nvim"


alias g="git"

# DOCKER
alias d-ra='docker rmi -f $(docker images -aq)' # Remove all images
alias d-rav='docker rm -vf $(docker ps -aq)'    # Remove all volumes
alias d-sac='docker stop $(docker ps -a -q)'    # Stop all containers
alias d-rac='docker rm -f $(docker ps -a -q)'   # Remove all containers
alias d-srac='d-sac && d-rac'                   # Stop and remove all containers
alias d-sp='docker system prune -af --volumes'  # Remove entire docker system

alias luamake=/home/colby/src/language-servers/lua/lua-language-server/3rd/luamake/luamake

# https://github.com/emk/rust-musl-builder
alias rust-musl-builder='docker run --platform linux/amd64 --rm -it -v "$(pwd)":/home/rust/src ekidd/rust-musl-builder'

export HISTTIMEFORMAT="%m/%d/%y %T "

eval $(thefuck --alias)
eval $(starship init zsh)

