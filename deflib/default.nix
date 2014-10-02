let 

  trivial = import ./trivial.nix;
  lists = import ./lists.nix;
  strings = import ./strings.nix;
  attrsets = import ./attrsets.nix;
  debug = import ./debug.nix;
  customisation = import ./customisation.nix;

in trivial // lists // strings // attrsets // debug // customisation
