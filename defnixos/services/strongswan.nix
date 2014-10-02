{ defnix, pkgs }:

let
  inherit (defnix.deflib) imap;
  inherit (pkgs) strongswan kmod;
  certs-activation = defnix.defnixos.activations.certs;

  secrets-file = service-name: builtins.toFile "ipsec.secrets"
    ": P12 /etc/x509/${service-name}.p12 \"fakepass\"";

  #!!! TODO: use strongswan user
  config-file = ca: outgoing-hosts: builtins.toFile "ipsec.conf" ''
    conn inbound
      leftid=it-services@zalora.com
      type=transport
      auto=add
    ${toString (imap (idx: host: ''
      conn outbound-${toString idx}
        leftid=it-services@zalora.com
        right=${host}
        rightid=it-services@zalora.com
        type=transport
        auto=route
    '') outgoing-hosts)}
    ca all
      cacert=${ca}
      auto=add
  '';

  strongswan-conf = ca: outgoing-hosts: service-name: builtins.toFile "strongswan.conf" ''
    charon {
      plugins {
        stroke {
          secrets_file = ${secrets-file service-name}
        }
      }
    }

    starter {
      config_file = ${config-file ca outgoing-hosts}
    }
  '';
in

# A service to allow incoming ipsec connections from any host with
# a cert signed by the right CA and outgoing ipsec connections to
# the hosts in outgoing-hosts

{ outgoing-hosts ? []         # Hosts to make outgoing connections to
, ca                          # The root CA certificate
, service-name ? "strongswan" # The name of this service in the global service namespace
}:

{
  description = "Strongswan ipsec keying daemon";

  start = [ "${strongswan}/libexec/ipsec/starter" "--nofork" ];

  activations = [ (certs-activation { inherit service-name; user = "root"; }) ];

  environment.STRONGSWAN_CONF = strongswan-conf ca outgoing-hosts service-name;

  environment.PATH = "${kmod}/bin:${kmod}/sbin:${strongswan}/bin:${strongswan}/sbin";
}
