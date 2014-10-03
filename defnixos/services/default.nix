lib:

let
  services = (lib.import-exprs ./. [
    "strongswan"
  ]);
in services // {
  compose = lib.compose services;
}
