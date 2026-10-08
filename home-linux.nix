# The Linux home configuration, for a headless machine that runs agents:
# everything shared, plus what Homebrew provides on the Mac.
{ config, lib, pkgs, pkgsUnstable, ... }:

let
  # The host half of Moshi, the phone terminal: `moshi-hook host setup` prints
  # the QR the app pairs from, and the daemon below answers the app and relays
  # agent events to it. Upstream ships a static binary and nixpkgs has no
  # package. The version and hash are the ones upstream's Homebrew formula
  # pins (github.com/rjyo/homebrew-moshi), so bump both together from there.
  moshi-hook = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "moshi-hook";
    version = "0.4.21";
    src = pkgs.fetchurl {
      url = "https://cdn.getmoshi.app/hook/v${finalAttrs.version}/moshi-hook_Linux_x86_64.tar.gz";
      hash = "sha256-IEYARe3DlEXJOAPFFK2tef08IdWaAbYk7A5f4LI2brU=";
    };
    sourceRoot = ".";
    dontFixup = true; # a static binary: nothing to patch or strip
    installPhase = ''
      runHook preInstall
      install -Dm755 moshi-hook $out/bin/moshi-hook
      ln -s moshi-hook $out/bin/moshi
      runHook postInstall
    '';
    meta = {
      description = "Daemon and CLI that bridge coding agents to the Moshi mobile app";
      homepage = "https://getmoshi.app";
      platforms = [ "x86_64-linux" ];
    };
  });

  # Captain's Deck, the herdr plugin that draws Firstmate's flow as a kanban
  # board. Upstream publishes no releases or tags, so this pins a commit of its
  # default branch (plugin version 0.7.1); bump rev and hash together.
  captains-deck = pkgs.fetchFromGitHub {
    owner = "deimantasnork";
    repo = "captains-deck";
    rev = "06c8284b1a8e17b7ec0acaa8d32c3bcbb23ec9c3";
    hash = "sha256-0gFRuxQS8Vx4/kJjBTeGs0drQF9QYHn2kcAOEuEpFTk=";
  };
in

{
  imports = [ ./home.nix ];

  home.packages = (with pkgs; [
    git
    gh
    nodejs
    bun
    tmux
    # uvx launches the Semble MCP server
    uv
    # the shared .zshrc aliases cat and ls to these
    bat
    lsd
    # the browser chrome-devtools-axi drives headless, and a font for it to
    # render text with
    chromium
    dejavu_fonts
    # the Captain's Deck plugin registered below runs on it
    python3
  ]) ++ [ moshi-hook ] ++ (with pkgsUnstable; [
    # Homebrew follows the latest release of these on the Mac; the release
    # branch the rest of this config is pinned to lags too far behind for them.
    claude-code
    herdr
  ]);
  fonts.fontconfig.enable = true;

  # This machine hosts Firstmate, so every herdr started here uses the tinted
  # config home.nix generates. herdr's sockets, logs and session state stay in
  # ~/.config/herdr; only the config file moves.
  home.sessionVariables.HERDR_CONFIG_PATH =
    "${config.home.homeDirectory}/.config/herdr-firstmate/config.toml";

  # Register Captain's Deck with herdr, enabled. herdr has no plugin setting in
  # config.toml: plugins live in a registry it owns (~/.config/herdr/plugins.json),
  # written through its CLI, so this is an activation step rather than a linked
  # file. `plugin link` takes a local directory, here the pinned store path,
  # where `plugin install` would clone the repository again on every rebuild.
  # It replaces any earlier registration of the same plugin, and works with or
  # without a herdr server running; a running one sees the plugin at once.
  # A failure fails the rebuild, so this runs after the other activation steps
  # and none of them is skipped.
  home.activation.herdrCaptainsDeck = lib.hm.dag.entryAfter [
    "linkGeneration"
    "installPackages"
    "onFilesChange"
    "reloadSystemd"
    "workOverlays"
  ] ''
    run --quiet ${pkgsUnstable.herdr}/bin/herdr plugin link ${captains-deck} --enabled
  '';

  # The Moshi daemon, as the unit `moshi-hook service install` would write but
  # owned by Home Manager, so it follows the package across version bumps.
  # Upstream's unit also pins PATH to /usr/local/bin:/usr/bin:/bin, which has
  # no herdr; this one adds the Nix profile, and the herdr config every other
  # herdr on this machine gets.
  systemd.user.services.moshi-hook = {
    Unit = {
      Description = "Moshi hook daemon";
      After = [ "network-online.target" ];
    };
    Service = {
      ExecStart = "${moshi-hook}/bin/moshi-hook serve";
      Restart = "on-failure";
      RestartSec = 5;
      Environment = [
        "PATH=${config.home.profileDirectory}/bin:/usr/local/bin:/usr/bin:/bin"
        "HERDR_CONFIG_PATH=${config.home.sessionVariables.HERDR_CONFIG_PATH}"
      ];
      WorkingDirectory = "%h";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
