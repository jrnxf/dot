export ZSH="$HOME/.oh-my-zsh"
export POCUS_GARDEN_ENVIRONMENT="cloud"
export GARDEN_LOGGER_TYPE="basic"
export AWS_PROFILE="pocus-dev"

plugins=(git tmux zsh-autosuggestions)

# ZSH_TMUX_AUTOSTART=true # can be annoying 🙃

source $ZSH/oh-my-zsh.sh

export PATH=~/bin:~/.local/bin:~/go/bin:~/.cargo/bin:~/.pyenv:~/Dev/pocus/development/scripts:$PATH

export EDITOR="nvim"
export PYENV_ROOT=~/.pyenv
alias dev="~/Dev"
alias p="cd ~/Dev/pocus"
alias reload="source ~/.zshrc"
alias privateip="hostname -I"
alias publicip="curl icanhazip.com"
alias clear='printf "\33c\e[3J"'
alias skrrrt="cd ~/Dev/skrrrt"
alias s="skrrrt"
alias dot="cd ~/dotfiles"
alias x="exit"
alias q="clear"
alias tmux="tmux -2" # keep colorscheme in tmux
alias gotop="gotop --mbps"
alias ls="exa"
alias cat="bat"
alias vimdiff='nvim -d'

alias v='nvim'
alias vim="nvim"

# DOCKER
alias d-ra='docker rmi -f $(docker images -aq)' # Remove all images
alias d-rav='docker rm -vf $(docker ps -aq)'    # Remove all volumes
alias d-sac='docker stop $(docker ps -a -q)'    # Stop all containers
alias d-rac='docker rm -f $(docker ps -a -q)'   # Remove all containers
alias d-srac='d-sac && d-rac'                   # Stop and remove all containers
alias d-sp='docker system prune -af --volumes'  # Remove entire docker system

alias luamake=/home/colby/src/language-servers/lua/lua-language-server/3rd/luamake/luamake


# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" |
      fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

export FZF_DEFAULT_COMMAND='rg --files --hidden' # set rg as the default source for fzf instead of find
# terafox
export FZF_DEFAULT_OPTS='
 --color=fg:#6d7f8b,bg:#0f1c1e,hl:#7aa4a1
 --color=fg+:#8aa4a1,bg+:#0f1c1e,hl+:#7aa4a1
 --color=info:#ad5c7c,prompt:#ad5c7c,pointer:#7aa4a1
 --color=marker:#6d7f8b,spinner:#ad5c7c,header:#ad5c7c
 --height=60% --layout=reverse'
# ansi theme will attempt to match terminal styles
export CUSTOM_FZF_PREVIEW_OPTS="bat --style=numbers --theme=ansi --color=always --line-range :500 {}"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND" # To apply the command to CTRL-T as well
export FZF_CTRL_T_OPTS="--preview \"$CUSTOM_FZF_PREVIEW_OPTS\""

export FZF_TMUX_OPTS="-r 75% --multi --reverse" # opens in a new tmux pane

# (EXPERIMENTAL) Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
  v | vim | nvim) fzf "$@" --preview "$CUSTOM_FZF_PREVIEW_OPTS" ;;
  ssh) fzf "$@" --preview 'dig {}' ;;
  *) fzf "$@" ;;
  esac
}

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

eval $(thefuck --alias)
eval $(starship init zsh)

