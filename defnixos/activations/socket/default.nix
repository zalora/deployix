defnix:

addr: let
  inherit (defnix.build-support) compile-c serialize-c-value;

  inherit (defnix.lib) socket-address-families;

  inherit (defnix.defnixos.activations) activation-header;

  inherit (addr) family;

  filename = compile-c [
    "-shared"
    "-fPIC"
    ''-DACTIVATION_HEADER="${activation-header}"''
  ] ./socket.so.c;

  symbol = "activate";

  type = if family == socket-address-families.AF_UNIX
    then "socket_addr_un"
    else "socket_addr_ipv6";

  filename_size = builtins.stringLength filename.outPath + 1;

  symbol_size = builtins.stringLength symbol + 1;

  path_size = builtins.stringLength addr.path + 1;

  value-type = if family == socket-address-families.AF_UNIX
    then "un_addr(${
      toString filename_size
    }, ${
      toString symbol_size
    }, ${
      toString path_size
    })"
    else "ipv6_addr(${
      toString filename_size
    }, ${
      toString symbol_size
    })";


  addr_hdr = {
    act_hdr = {
      sizes = {
        inherit filename_size symbol_size;
      };

      inherit filename;

      symbol = ''"${symbol}"'';
    };

    inherit type;
  };

  value = if family == socket-address-families.AF_UNIX
    then {
      un_hdr = {
        inherit addr_hdr path_size;
      };

      path = ''"${addr.path}"'';
    } else {
      inherit addr_hdr;

      inherit (addr) port;
    };

in serialize-c-value {
  name = "socket-activation-args";

  header = ./socket.so.c;

  type = value-type;

  inherit value;

  flags = [ ''-DACTIVATION_HEADER="${activation-header}"'' ];
}
