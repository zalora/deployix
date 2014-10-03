lib:

let
  activations = (lib.import-exprs ./. [
    "certs"
  ]);
in activations // {
  compose = lib.compose activations;
}
