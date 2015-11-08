deployix: { ca, cert-archive }: functionalities: let
  inherit (deployix.lib) map-attrs-to-list;

  outgoing-hosts = builtins.concatLists (map-attrs-to-list (name: value:
    value.outgoing-ipsec-hosts or []
  ) functionalities);
in functionalities // {
  strongswan = {
    service = deployix.defnixos.services.strongswan {
      inherit ca cert-archive outgoing-hosts;
    };

    singleton = true;
  };
}
