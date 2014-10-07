lib: let
  subsets = lib.import-subdirs ./. [
    "services"
    "lib"
    "activations"
  ];
in subsets // {
  compose = lib.nested-compose subsets;
}
