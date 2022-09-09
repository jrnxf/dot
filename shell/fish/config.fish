# fzf nord theme
# set -x FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
#     --color=fg:#e5e9f0,bg:#22262E,hl:#81a1c1
#     --color=fg+:#e5e9f0,bg+:#22262E,hl+:#81a1c1
#     --color=info:#eacb8a,prompt:#bf6069,pointer:#b48dac
#     --color=marker:#a3be8b,spinner:#b48dac,header:#a3be8b'

set --export EDITOR nvim

fish_add_path --move $HOME/.local/bin
fish_add_path $HOME/bin
fish_add_path $HOME/go/bin
fish_add_path $HOME/.cargo/bin
fish_add_path /opt/homebrew/bin

# disable greeting
set fish_greeting

alias dev="~/Dev"
alias reload="source ~/.config/fish/config.fish"
alias privateip="hostname -I"
alias publicip="curl icanhazip.com"
alias clear="clear && printf '\e[3J'"
alias celar="clear" # always fat finger this lol
alias skrrrt="~/Dev/skrrrt"
alias s="cd ~/studio"
alias ss="cd ~/studio/stx"
alias sf="cd ~/studio/frontend"
alias sb="cd ~/studio/backend"
alias sd="cd ~/studio/design-system"
alias m="cd ~/studio"
alias ms="cd ~/studio/stx"
alias mf="cd ~/studio/frontend"
alias mb="cd ~/studio/backend"
alias md="cd ~/studio/design-system"
alias dot="cd ~/dotfiles"
alias x="exit"
alias q="clear"
alias tmux="tmux -2" # keep colorscheme in tmux
alias gotop="gotop --mbps -f"
alias ls="exa"
alias cat="cat"

alias f='fzf --height=30%'

alias v='nvim'
alias fzf='fzf --height=90% --preview "bat --line-range :500 {}" --preview-window right,border-left  --padding=0'
alias vim="nvim"
alias vv='v "$(git ls-files | f)"'
alias vd='cd ~/dotfiles && vv'

alias g="git"

alias t="tmux"
alias ta="tmux a"

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

starship init fish | source

if status is-interactive
    # Commands to run in interactive sessions can go here
end