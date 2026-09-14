/*
  Per-machine overrides, not shared across machines.

  This file is tracked with a neutral default (below) so every clone has
  *something* here - required for the flake's git-based evaluation to see it
  at all (a gitignored file is invisible to `darwin-rebuild --flake $DIR#mac`,
  since nix upgrades that bare path to a git+file:// fetch that only sees
  tracked content).

  To set a real override on THIS machine only:
    1. Edit the excludeCasks list below.
    2. Run: git update-index --skip-worktree local.nix
       This hides your local edit from git status/diff/add so it can never
       be accidentally committed. (Undo with --no-skip-worktree.)
*/
{
  excludeCasks = [ ];
}
