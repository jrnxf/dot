# The Linux home configuration, for a headless machine that runs agents:
# everything shared, plus what Homebrew provides on the Mac.
{ config, pkgs, pkgsUnstable, ... }:

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

  # Firstmate's model and effort choices per task, kept here because the guest
  # has no backup.
  home.file."firstmate/config/crew-dispatch.json".source =
    ./home/firstmate/crew-dispatch.json;
}
