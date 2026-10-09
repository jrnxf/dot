# leaf (https://leaf.rivolink.mg), the markdown renderer the Claude Code /mkd
# mod in home/.claude/skills/mkd runs. It is not in nixpkgs, so the pinned
# upstream release binary is packaged here for both the Mac and the Linux home
# configuration. To upgrade: bump the version, set the hashes to lib.fakeHash,
# run `reload`, and paste the hash Nix reports; get the other system's with
# `nix store prefetch-file <release url>`.
{ pkgs }:

let
  inherit (pkgs) lib;
  inherit (pkgs.stdenv.hostPlatform) system isDarwin isLinux;
  version = "1.28.3";
  # Upstream's release asset for each system packaged here; each is the bare binary.
  release = {
    aarch64-darwin = {
      asset = "leaf-macos-arm64";
      hash = "sha256-3FS8w55z+ZhT8FE4lIHbc5b+yV7/afhduIeFGKP+E98=";
    };
    x86_64-linux = {
      asset = "leaf-linux-x86_64";
      hash = "sha256-Wl4cYJOLLqYcAgf5T2iZo+Rg4INqMIFuUSWV66OAt9Q=";
    };
  };
in
pkgs.stdenvNoCC.mkDerivation ({
  pname = "leaf";
  inherit version;
  src = pkgs.fetchurl {
    url = "https://github.com/RivoLink/leaf/releases/download/${version}/${release.${system}.asset}";
    inherit (release.${system}) hash;
  };
  dontUnpack = true;
  dontFixup = isDarwin; # never touch a prebuilt, ad-hoc signed binary
  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/leaf
    runHook postInstall
  '';
  meta = {
    description = "Terminal markdown previewer";
    homepage = "https://github.com/RivoLink/leaf";
    license = lib.licenses.mit;
    platforms = lib.attrNames release;
    mainProgram = "leaf";
  };
} // lib.optionalAttrs isLinux {
  # The Linux binary links glibc and libgcc_s dynamically; point it at the Nix
  # loader and libraries instead of whatever the host has in /lib64.
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  buildInputs = [ pkgs.stdenv.cc.cc.lib ];
  dontStrip = true;
})
