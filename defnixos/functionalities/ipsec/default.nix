defnix: functionalities: let
  inherit (defnix.lib) map-attrs-to-list;

  get-attr-if-all-same = attr: let
    vals = builtins.concatLists (map-attrs-to-list (name: value:
      if value ? ${attr} then [ value.${attr} ] else []
    ) functionalities);

    val-head = builtins.head vals;
  in if builtins.length vals == 0
    then throw "No functionalities have a value for ${attr}"
  else if defnix.lib.all (v: v == val-head) vals
    then val-head
    else throw "Deployments of functionalities with mixed ${attr} values not yet supported";

  ca = get-attr-if-all-same "ipsec-ca";

  cert-archive = get-attr-if-all-same "ipsec-cert-archive";

  outgoing-hosts = builtins.concatLists (map-attrs-to-list (name: value:
    value.outgoing-ipsec-hosts or []
  ) functionalities);
in functionalities // {
  strongswan = {
    service = defnix.defnixos.services.strongswan {
      inherit ca cert-archive outgoing-hosts;
    };

    singleton = true;
  };
}
