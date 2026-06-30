{
  config,
  vars,
  ...
}: {
  age.secrets.itch-dl = {
    owner = vars.user;
    inherit (config.users.users.${vars.user}) group;
  };
}
