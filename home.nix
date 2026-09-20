{ config, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/dotfiles";
  # The prebuilt fzf-tab module has a Zsh version mismatch; use its shell fallback.
  fzfTab = pkgs.runCommand "zsh-fzf-tab-no-module" { } ''
    cp -r ${pkgs.zsh-fzf-tab} $out
    chmod -R u+w $out
    rm -rf $out/share/fzf-tab/modules
  '';
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
    zsh
    starship
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # Stable package paths for the editable shell configuration.
  home.file.".local/share/zsh-packages/zsh".source = pkgs.zsh;
  home.file.".local/share/zsh-packages/autosuggestions".source = pkgs.zsh-autosuggestions;
  home.file.".local/share/zsh-packages/syntax-highlighting".source = pkgs.zsh-syntax-highlighting;
  home.file.".local/share/zsh-packages/fzf-tab".source = fzfTab;

  home.file.".zshrc".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zshrc";
  home.file.".zshenv".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.zshenv";
  home.file.".config/starship.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/starship.toml";
  home.file.".codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.codex/config.toml";

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
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

  # Claude auto-loads plugins in its skills directory, including MCP-only plugins.
  home.file.".claude/skills/dotfiles-mcp".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/skills/dotfiles-mcp";

  # Share the authored skill across agents without replacing installed skills.
  home.file.".agents/skills/pr-walkthrough".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/pr-walkthrough";
  home.file.".claude/skills/pr-walkthrough".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/pr-walkthrough";
  home.file.".codex/skills/pr-walkthrough".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/pr-walkthrough";

  # Official axi.md catalog skills invoke their CLIs through Homebrew's npx.
  home.file.".agents/skills/gh-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/gh-axi";
  home.file.".claude/skills/gh-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/gh-axi";
  home.file.".codex/skills/gh-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/gh-axi";
  home.file.".agents/skills/chrome-devtools-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/chrome-devtools-axi";
  home.file.".claude/skills/chrome-devtools-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/chrome-devtools-axi";
  home.file.".codex/skills/chrome-devtools-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/chrome-devtools-axi";
  home.file.".agents/skills/lavish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/lavish";
  home.file.".claude/skills/lavish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/lavish";
  home.file.".codex/skills/lavish".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/lavish";
  home.file.".agents/skills/quota-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/quota-axi";
  home.file.".claude/skills/quota-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/quota-axi";
  home.file.".codex/skills/quota-axi".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills/quota-axi";

  # Ghostty keeps runtime state (auto/) next to its config, so link just the file.
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/ghostty/config";

  # Karabiner saves via write-temp-then-rename, which clobbers a file symlink
  # on every GUI edit. Linking the whole directory instead makes those renames
  # land inside the repo, so GUI edits show up as a git diff rather than a
  # broken link. Runtime state written next to the config (assets/,
  # automatic_backups/) ends up in the repo dir too and is gitignored.
  home.file.".config/karabiner".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/karabiner";

  home.file.".curl-format.txt".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.curl-format.txt";

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
