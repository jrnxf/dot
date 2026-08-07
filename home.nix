{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # fzf keybindings (ctrl-t, ctrl-r) and completion, replacing the old
  # oh-my-zsh fzf plugin.
  programs.fzf.enable = true;

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    plugins = [
      {
        # tab completion in an fzf popup, replacing the old omz custom plugin
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];
    initContent = ''
      bindkey '^f' autosuggest-accept
      bindkey "^ " fzf-tab-complete

      # ---- PATH (carried over from pre-nix zshrc) ----
      export PATH="$HOME/bin:$PATH"
      export PATH="$HOME/.local/bin:$PATH"
      export PATH="$HOME/go/bin:$PATH"
      export PATH="$HOME/.cargo/bin:$PATH"
      export PATH="$HOME/Dev/pocus/development/scripts:$PATH"
      export PATH="$HOME/.bun/bin:$PATH"
      export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
      export PATH="$HOME/.volta/bin:$PATH"
      export PATH="$HOME/.nvm/versions/node/v24.4.1/bin:$PATH"

      # ---- Environment ----
      export EDITOR="code --wait"
      export MANPAGER='nvim +Man!'
      export LC_ALL=en_US.UTF-8
      export AWS_PAGER=""
      export NEXT_PUBLIC_WORKSPACE_PREFIX="colby"
      export NODE_OPTIONS="--max-old-space-size=8192"
      ulimit -n 10240

      # ---- FZF ----
      export FZF_DEFAULT_COMMAND='rg --files --hidden'
      export FZF_DEFAULT_OPTS='
       --bind ctrl-b:preview-half-page-up,ctrl-f:preview-half-page-down
       --height=60% --layout=reverse'
      export CUSTOM_FZF_PREVIEW_OPTS="bat --style=numbers --theme=ansi --color=always --line-range :500 {}"
      export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
      export FZF_CTRL_T_OPTS="--preview \"$CUSTOM_FZF_PREVIEW_OPTS\""
      export FZF_TMUX_OPTS="-r 75% --multi --reverse"
      _fzf_comprun() {
        local command=$1
        shift
        case "$command" in
        v | vim | nvim) fzf "$@" --preview "$CUSTOM_FZF_PREVIEW_OPTS" ;;
        ssh) fzf "$@" --preview 'dig {}' ;;
        *) fzf "$@" ;;
        esac
      }

      # ---- Completion / fzf-tab ----
      zstyle ':completion:*:git-checkout:*' sort false
      zstyle ':completion:*' menu no
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd --color=always $realpath'
      zstyle ':fzf-tab:complete:ls:*' fzf-preview 'bat --color=always $realpath'
      zstyle ':fzf-tab:complete:*' popup-pad 30 0 fzf-completion-opts --multi
      zstyle ':fzf-tab:*' switch-group ',' '.'
      zstyle ':fzf-tab:complete:git*:*' continuous-trigger ""

      # ---- Functions: git ----
      fbr() {
        local branches branch
        branches=$(git branch --all | grep -v HEAD) &&
          branch=$(echo "$branches" |
            fzf-tmux -d $((2 + $(wc -l <<<"$branches"))) +m) &&
          git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
      }
      gri() {
        if [ -z "$1" ]; then
          echo "Please provide the number of commits to rebase"
          return 1
        fi
        git rebase -i HEAD~"$1"
      }
      gwtf() {
        local dir=$(git worktree list | fzf | awk '{print $1}')
        [[ -n "$dir" ]] && cd "$dir"
      }
      glc() {
        git rev-parse HEAD
        git rev-parse HEAD | pbcopy
      }

      # ---- Functions: kubectl ----
      kp() {
        kubectl get po
      }
      kpl() {
        pod="$(kubectl get po | tail -n+2 | fzf -n1 --reverse --tac | awk '{print $1}')"
        if [[ -n $pod ]]; then
          kubectl logs --tail=3000 --all-containers=true $pod -f
        fi
      }
      kplp() {
        pod="$(kubectl get po | tail -n+2 | fzf-tmux -n1 --reverse -r 75% --tac --preview='kubectl logs --tail=20 --all-containers=true {1}' --preview-window=right:50% | awk '{print $1}')"
        if [[ -n $pod ]]; then
          kubectl logs --tail=500 --all-containers=true $pod -f
        fi
      }

      # ---- Functions: misc ----
      kj() {
        kill -9 $(jobs -l | awk '{print $3}')
      }
      function request-godmode() { lumos request --app-like "Apollo - Godmode Access Request - Temporal" --for-me --length 12h --reason "$*" --wait; }

      # homelab ssh picker wrapper (managed by ansible pre-migration)
      ssh() {
        if [[ "$1" == "homelab" ]]; then
          shift
          local target
          target="$("$HOME/.local/bin/homelab-ssh-pick")" || return $?
          [[ -n "$target" ]] || return 1
          command ssh "$target" "$@"
        else
          command ssh "$@"
        fi
      }

      # ---- Tool initialization ----
      [[ $commands[kubectl] ]] && source <(kubectl completion zsh)
      eval "$(thefuck --alias)"
      [ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
      _gt_yargs_completions() {
        local reply
        local si=$IFS
        IFS=$'\n' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "''${words[@]}"))
        IFS=$si
        _describe 'values' reply
      }
      compdef _gt_yargs_completions gt
      export PNPM_HOME="$HOME/Library/pnpm"
      case ":$PATH:" in
        *":$PNPM_HOME:"*) ;;
        *) export PATH="$PNPM_HOME:$PATH" ;;
      esac
      eval "$(rbenv init - zsh)"
      # Keep Homebrew bins ahead of rbenv shims so `tilt` (Homebrew) wins over
      # the rbenv `tilt` gem shim.
      export PATH="/opt/homebrew/bin:$PATH"
      if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi
      if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

      # LeadGenie native Rails (Docker services on localhost)
      export MONGO_ENDPOINT="localhost:27021"
      export ES_ENDPOINT="localhost:9200"
      export REDIS_HOST="localhost"
      export REDIS_RATELIMITER_HOST="localhost"
      export REDIS_CACHE_URL="redis://localhost:6379/0"
      export RAILS_HOST="127.0.0.1:3001"

      # Local, untracked overrides (secrets, machine-specific env, etc.)
      [ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";

      # ---- carried over from pre-nix zshrc ----
      # shell
      reload = "source ~/.zshrc";
      clear = ''printf "\33c\e[3J"'';
      x = "exit";
      q = "clear";
      dev = "cd ~/Dev";
      dot = "cd ~/dotfiles";
      u = "cd ~/Dev/une.haus";
      # editor
      v = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
      # core tools
      ls = "lsd -lah";
      cat = "bat";
      tmux = "tmux -2";
      gotop = "gotop --mbps";
      ason = "ZSH_AUTOSUGGEST_STRATEGY=(history completion)";
      asoff = "ZSH_AUTOSUGGEST_STRATEGY=()";
      # git
      gca = "git commit --amend --no-edit";
      gaca = "git commit -a --amend --no-edit";
      sc = "git commit -m 'squash [skip-ci]'";
      dc = ''git commit -m "$(date +%m/%d/%y\ %H:%M)"'';
      # graphite
      gtc = "gt continue";
      gtms = "gt modify && gt ss";
      gtn = "gt create";
      # apollo
      lg = "cd ~/Dev/leadgenie";
      # bun / pnpm
      bbs = "bun run build && bun run start";
      bpf = "bun run preflight";
      pn = "pnpm";
      # docker
      d-ra = "docker rmi -f $(docker images -aq)";
      d-rav = "docker rm -vf $(docker ps -aq)";
      d-sac = "docker stop $(docker ps -a -q)";
      d-rac = "docker rm -f $(docker ps -a -q)";
      d-srac = "d-sac && d-rac";
      d-sp = "docker system prune -af --volumes";
      # homelab
      sshh = "ssh homelab";
      tilt = "/opt/homebrew/bin/tilt";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".config/herdr".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";
  home.file.".claude/statusline-command.sh".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/statusline-command.sh";
  home.file.".claude/agents".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/agents";
  home.file.".claude/hooks".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/hooks";
  home.file.".claude/commands".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/commands";

  # Ghostty keeps runtime state (auto/) next to its config, so link just the file.
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty/config";

  home.file.".gitconfig".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitconfig";
  home.file.".gitignore".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitignore";
  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.tmux.conf";

  # Keep Pi's credential and runtime state local by linking only authored files and directories.
  home.file.".pi/agent/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes";
  home.file.".pi/agent/extensions".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";

  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
