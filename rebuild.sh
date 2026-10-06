#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$(uname -s)" = Linux ]; then
  # Home-manager only, so no sudo. Like the Mac's backupFileExtension, rename
  # a pre-existing file at a managed path instead of failing on it.
  export HOME_MANAGER_BACKUP_EXT=hm-backup
  exec nix --extra-experimental-features 'nix-command flakes' \
    run "$DIR#homeConfigurations.linux.activationPackage"
fi
exec sudo darwin-rebuild switch --flake "$DIR#mac"
