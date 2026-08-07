{ user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    inherit user;
    # This machine had a pre-existing /opt/homebrew install; migrate it
    # into nix-homebrew instead of wiping it (keeps installed packages).
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # remove anything not listed here
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      # Trust flags mirror the pre-migration Brewfile: brew 6 refuses to load
      # formulae from untrusted third-party taps during bundle.
      "anomalyco/tap"
      { name = "aws/tap"; trusted = true; }
      { name = "charmbracelet/tap"; trusted = true; }
      "deskflow/tap"
      { name = "garden-io/garden"; trusted = true; }
      { name = "go-task/tap"; trusted = true; }
      { name = "isacikgoz/taps"; trusted = true; }
      { name = "jason0x43/neovim-nightly"; trusted = true; }
      { name = "libsql/sqld"; trusted = true; }
      { name = "oven-sh/bun"; trusted = true; }
      { name = "tilt-dev/tap"; trusted = true; }
      { name = "tursodatabase/tap"; trusted = true; }
      { name = "withgraphite/tap"; trusted = true; }
    ];
    brews = [
      "act"
      "age"
      "agent-browser"
      { name = "anomalyco/tap/opencode"; trusted = true; }
      "awscli"
      "bat"
      "bfg"
      "bitwarden-cli"
      "black"
      "caddy"
      "cmake"
      "colima"
      "coreutils"
      "delve"
      "docker"
      "edencommon"
      "exiftool"
      "fb303"
      "fbthrift"
      "fclones"
      "fd"
      "ffmpeg"
      "figlet"
      "fizz"
      "folly"
      "fzf"
      "gettext"
      "gh"
      "git"
      "git-lfs"
      "gmp"
      "gnu-sed"
      "go"
      "go-task/tap/go-task"
      "golang-migrate"
      "gotop"
      "gum"
      "harfbuzz"
      "hasura-cli"
      "helm"
      "herdr"
      "htop"
      "hyperfine"
      "imagemagick"
      "isacikgoz/taps/tldr"
      "jq"
      "krb5"
      "kubectx"
      "kubernetes-cli"
      "lastpass-cli"
      "lazygit"
      "lefthook"
      "libffi"
      "libgit2"
      "libxml2"
      "libxmu"
      "libxslt"
      "libyaml"
      "lima-additional-guestagents"
      "lsd"
      "mvfst"
      "n"
      "neofetch"
      "neonctl"
      "neovim"
      "nmap"
      "node"
      "nss"
      "nvm"
      "ollama"
      "openssl@3"
      "oven-sh/bun/bun"
      "pipx"
      "poppler"
      "postgresql@15"
      "postgresql@16"
      "postgresql@17"
      "protobuf"
      "pyenv"
      "python-setuptools"
      "python@3.10"
      "python@3.12"
      "python@3.13"
      "python@3.9"
      "qemu"
      "railway"
      "rbenv"
      "readline"
      "ripgrep"
      "rsync"
      "rust"
      "shared-mime-info"
      "starship"
      "stripe-cli"
      "stylua"
      "telnet"
      "temporal"
      "thefuck"
      "tilt-dev/tap/tilt"
      "tmux"
      "tree"
      "tursodatabase/tap/turso"
      "urlview"
      "uv"
      "wangle"
      "watchman"
      "webp"
      "websocat"
      "wget"
      "withgraphite/tap/graphite"
      "woff2"
      "xclip"
      "yarn"
      "yq"
      "yt-dlp"
      "zsh"
      "zsh-autosuggestions"
    ];
    casks = [
      "1password"
      "1password-cli"
      "betterdisplay"
      "claude-code"
      "cmux"
      "codex"
      "cursor"
      "dbeaver-community"
      "deepl"
      "firefox"
      "font-geist-mono-nerd-font"
      "ghostty"
      "google-chrome"
      "grandperspective"
      "handbrake-app"
      "kap"
      "karabiner-elements"
      "keycastr"
      "linear"
      "loom"
      "megasync"
      "neohtop"
      "ngrok"
      "nordvpn"
      "notion"
      "notion-calendar"
      "obs"
      "openlens"
      "openlogi"
      "orbstack"
      "pearcleaner"
      "postman"
      "pritunl"
      "qbittorrent"
      "raycast"
      "rectangle"
      "slack"
      "spotify"
      "topnotch"
      "visual-studio-code"
      "vlc"
      "wezterm"
      "zoom"
    ];
  };
}
