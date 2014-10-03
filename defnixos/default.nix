lib: let
  subsets = lib.import-subdirs ./. [
    "services"
    "activations"
    "lib"
  ];
in subsets // {
  compose = lib.nested-compose subsets;
}
