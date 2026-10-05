# Agent CLI tools Firstmate (https://github.com/kunchenguid/firstmate) requires on PATH.
# None are in nixpkgs or Homebrew, and upstream installs them with `curl | sh`
# and `npm install -g`, which leaves nothing reproducible behind. Package the
# pinned upstream releases here instead. To upgrade one: bump its version, set
# its hashes to lib.fakeHash, run `reload`, and paste the hashes Nix reports.
{ pkgs }:

let
  inherit (pkgs) lib;
  owner = "kunchenguid";
  # pnpm 11 from this nixpkgs gets SIGKILLed finishing an install on darwin;
  # the lockfiles are format 9.0, which pnpm 10 reads as-is.
  pnpm = pkgs.pnpm_10;

  # Upstream publishes prebuilt Go binaries; the tarball holds just the binary.
  goRelease = { pname, version, hash, description }:
    pkgs.stdenvNoCC.mkDerivation {
      inherit pname version;
      src = pkgs.fetchurl {
        url = "https://github.com/${owner}/${pname}/releases/download/v${version}/${pname}-v${version}-darwin-arm64.tar.gz";
        inherit hash;
      };
      sourceRoot = ".";
      dontFixup = true; # never touch a prebuilt, ad-hoc signed binary
      installPhase = ''
        runHook preInstall
        install -Dm755 ${pname} $out/bin/${pname}
        runHook postInstall
      '';
      meta = {
        inherit description;
        homepage = "https://github.com/${owner}/${pname}";
        license = lib.licenses.mit;
        platforms = [ "aarch64-darwin" ];
        mainProgram = pname;
      };
    };

  # The axi tools are pnpm TypeScript projects; build each from its release tag
  # against its own lockfile rather than trusting an unlocked `npm install -g`.
  axiTool = { pname, version, hash, pnpmDepsHash, entry, description, extraFiles ? [ ] }:
    pkgs.stdenv.mkDerivation (finalAttrs: {
      inherit pname version;
      src = pkgs.fetchFromGitHub {
        inherit owner hash;
        repo = pname;
        tag = "${pname}-v${version}";
      };
      pnpmDeps = pkgs.fetchPnpmDeps {
        inherit (finalAttrs) pname version src;
        inherit pnpm;
        fetcherVersion = 3;
        hash = pnpmDepsHash;
      };
      nativeBuildInputs = [ pkgs.nodejs pkgs.pnpmConfigHook pnpm pkgs.makeBinaryWrapper ];
      env.CI = "true"; # keep pnpm non-interactive
      buildPhase = ''
        runHook preBuild
        pnpm run build
        pnpm prune --prod --ignore-scripts
        runHook postBuild
      '';
      installPhase = ''
        runHook preInstall
        mkdir -p $out/lib/${pname}
        cp -R package.json dist skills node_modules ${lib.concatStringsSep " " extraFiles} $out/lib/${pname}/
        makeBinaryWrapper ${lib.getExe pkgs.nodejs} $out/bin/${pname} \
          --add-flags $out/lib/${pname}/${entry} \
          --suffix PATH : ${lib.makeBinPath [ pkgs.nodejs ]} # npx fallback, e.g. chrome-devtools-mcp
        runHook postInstall
      '';
      meta = {
        inherit description;
        homepage = "https://github.com/${owner}/${pname}";
        license = lib.licenses.mit;
        mainProgram = pname;
      };
    });
in
[
  (goRelease {
    pname = "treehouse";
    version = "3.1.2";
    hash = "sha256-JGZt3sNGtf0fBGf0dcZH2OLORegOioRUjq3pezU8vks=";
    description = "Pool of reusable git worktrees for parallel agents";
  })
  (goRelease {
    pname = "no-mistakes";
    version = "1.84.0";
    hash = "sha256-Ll+DgwOrcn7czRpgpINAaAJGBsaK59l/3A/e7Ne9TZA=";
    description = "Review, test, and PR validation pipeline behind a git push";
  })
  (axiTool {
    pname = "gh-axi";
    version = "0.1.35";
    hash = "sha256-zuShaNLCh+u5c+CTeX5cgMCk1PUTK8nd7D5zTjTqt9E=";
    pnpmDepsHash = "sha256-Ps93wg2mN1g1Rq4SY1FuNh8g9CF3o1WjCtioBWLcogU=";
    entry = "dist/bin/gh-axi.js";
    description = "GitHub CLI wrapper for agents";
  })
  (axiTool {
    pname = "chrome-devtools-axi";
    version = "0.1.38";
    hash = "sha256-sN2nvkQYqJ1rngVNq7Sxh5nzelTASWVNEUXxMb5dmOg=";
    pnpmDepsHash = "sha256-bkR7KrArylGtteCEwBSQeMsi0J2CJvdMV3TCATPwWt4=";
    entry = "dist/bin/chrome-devtools-axi.js";
    description = "Chrome DevTools browser automation for agents";
  })
  (axiTool {
    pname = "tasks-axi";
    version = "0.2.6";
    hash = "sha256-nf6KkZEoJ+BD7PeGat/GVk8FQbuAJ0AHR5XuX+bwlZo=";
    pnpmDepsHash = "sha256-vZcUSa35SvRJoaeuSUuDpv54FJRtP1fxv+6+tR9euR0=";
    entry = "dist/bin/tasks-axi.js";
    description = "Markdown backlog CLI for agents";
  })
  (axiTool {
    pname = "quota-axi";
    version = "0.1.57";
    hash = "sha256-BSm+SeMflWzSCktcb4+EnSY8ssQ5ZIBcaptVV3PSPm4=";
    pnpmDepsHash = "sha256-3/wWfyrXVF0iTCZhCUgOmfuhNskq9kAw6dIQjHnxpHs=";
    entry = "dist/bin/quota-axi.js";
    description = "Model quota reader for agents";
  })
  (axiTool {
    pname = "lavish-axi";
    version = "0.1.82";
    hash = "sha256-XfAvpjX9b3mab0AbeA8WDi5JQ5fTff2S39StGq4Zn4M=";
    pnpmDepsHash = "sha256-g1MZOKo3DR4x9qGgxEN2Ab9YhQkQcOTupsr3mXtkr4w=";
    entry = "dist/cli.mjs";
    extraFiles = [ "plugin.json" ];
    description = "Reviewable HTML artifacts for agent responses";
  })
]
