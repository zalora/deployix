lib: let
  subsets = lib.import-subdirs ./. [
    "services"
    "activations"
  ];
in subsets // {
  compose = lib.nested-compose subsets;
}
