args:
#!!! a readdir primop would be great here...
builtins.listToAttrs (map (name: { inherit name; value = import (./. + "/${name}.nix") args; })
  [ "strongswan"
  ])
