# Home Manager session variables, installed by nix-darwin's useUserPackages.
if [[ -r "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]]; then
  source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
fi
