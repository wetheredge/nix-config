{
  config,
  vars,
  ...
}: {
  # symlink into place from home-manager to avoid creating ~/.config/git owned by root:root
  age.secrets.git-credentials = {
    owner = vars.user;
    inherit (config.users.users.${vars.user}) group;
  };
}
