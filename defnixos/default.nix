lib: let
  subsets = lib.import-subdirs ./. [
    "services"
    "initializers"
    "lib"
  ];
in subsets // {
  compose = lib.nested-compose subsets;
}
