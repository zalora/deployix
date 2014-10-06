lib: let
  subsets = lib.import-subdirs ./. [
    "services"
    "initializers"
    "lib"
    "activations"
  ];
in subsets // {
  compose = lib.nested-compose subsets;
}
