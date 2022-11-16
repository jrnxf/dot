export ZSH="$HOME/.oh-my-zsh"

plugins=(git tmux zsh-autosuggestions)

# i like this but it's annoying in vscode
# ZSH_TMUX_AUTOSTART=true

source $ZSH/oh-my-zsh.sh

export PATH=~/bin:~/.local/bin:~/go/bin:~/.cargo/bin:~/Dev/pocus/development/scripts:$PATH

export EDITOR="nvim"
export POCUS_GARDEN_ENVIRONMENT="cloud"

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




alias v='nvim'
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

# this isn't expected export that fzf looks for, but i use it below
export FZF_PREVIEW_OPTS="bat --style=numbers --theme=Nord --color=always --line-range :500 {}"

# set fd as the default source for fzf
export FZF_DEFAULT_COMMAND='rg --files --hidden'
  # fzf --bind 'ctrl-r:reload(eval "$FZF_DEFAULT_COMMAND")' \
  #    --header 'Press CTRL-R to reload' --header-lines=1 \
  #    --height=50% --layout=reverse
export FZF_DEFAULT_OPTS='--height 60%'

# Now fzf (w/o pipe) will use fd instead of find
# fzf

# To apply the command to CTRL-T as well
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview \"$FZF_PREVIEW_OPTS\""

# export FZF_COMPLETION_OPTS='--info=inline'

export FZF_TMUX_OPTS="-r 75% --multi --reverse"

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    v|vim|nvim)           fzf "$@" --preview "$FZF_PREVIEW_OPTS" ;;
    ssh)                  fzf "$@" --preview 'dig {}' ;;
    *)                    fzf "$@" ;;
  esac
}

# alias fzf='fzf --height=90% --preview "bat --line-range :500 {}" --preview-window right,border-left  --padding=0'

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
eval $(starship init zsh)

