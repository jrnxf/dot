# Home Manager session variables, installed by nix-darwin's useUserPackages.
if [[ -r "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
  source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
fi

# Linux uses standalone Home Manager, which installs into the per-user Nix
# profile. Nix's installer only hooks interactive shells there, so load both
# here or commands run over ssh and by agents miss everything Nix installed.
if [[ $OSTYPE == linux* ]]; then
  if [[ -r /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi
  if [[ -r "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]]; then
    source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
  fi
fi
