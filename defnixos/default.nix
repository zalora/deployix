lib:

rec {
  services-dir = ./services;

  # Extend service-to-nixos-systemd's type setting when new
  # types are supported
  service-types = {
    oneshot = 0;
  };

  service-to-nixos-systemd = { description, start, type }: {
    inherit description;

    # !!! Should handle escaping
    serviceConfig.ExecStart = lib.concatStringsSep " " start;

    serviceConfig.Type = "oneshot";

    serviceConfig.RemainAfterExit = type == service-types.oneshot;
  };
}
