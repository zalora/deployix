defnix: let
  inherit (defnix.pkgs) multiplex-activations emulate-inetd execve openssh;

  sshd = "${openssh}/sbin/sshd";

  inherit (defnix.defnixos.activations) socket;

  inherit (defnix.lib.socket-address-families) AF_INET6;
in { passwd, group, sudoers, port, config }: {
  start = multiplex-activations [
    (socket { family = AF_INET6; inherit port; })
  ] (emulate-inetd (execve "run-sshd" {
    filename = sshd;

    argv = [ "sshd" "-D" "-f" config "-i" ];

    settings.bind-mounts = {
      "/etc/passwd" = passwd;

      "/etc/group" = group;

      "/etc/sudoers" = sudoers;

      # TODO: run private nscd instance instead
      "/var/run/nscd" = "/var/empty";
    };
  }));

  on-demand = true;
}
