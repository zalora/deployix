defnix:

let
  inherit (defnix.pkgs) strongswan kmod execve generate-certs;

  secrets-file = service-name: cert-archive: let
    archive = if cert-archive == null
      then "/etc/x509/${service-name}.p12"
      else cert-archive;
  in builtins.toFile "ipsec.secrets"
    ": P12 ${cert-archive} \"fakepass\"";

  #!!! TODO: use strongswan user
  config-file = ca: outgoing-hosts: builtins.toFile "ipsec.conf" ''
    conn inbound
      leftid=it-services@zalora.com
      type=transport
      auto=add
    ${toString (defnix.lib.imap (idx: host: ''
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

  strongswan-conf = ca: outgoing-hosts: service-name: cert-archive: builtins.toFile "strongswan.conf" ''
    charon {
      plugins {
        stroke {
          secrets_file = ${secrets-file service-name cert-archive}
        }
      }
    }

    starter {
      config_file = ${config-file ca outgoing-hosts}
    }
  '';
in

{ outgoing-hosts ? []         # Hosts to make outgoing connections to
, ca                          # The root CA certificate
, service-name ? "strongswan" # The name of this service in the global service namespace
, cert-archive ? null         # The pkcs12 archive containing the cert and private key
}:

{
  start = execve "start-strongswan" {
    filename = "${strongswan}/libexec/ipsec/starter";

    argv = [ "starter" "--nofork" ];

    envp = {
      STRONGSWAN_CONF = strongswan-conf ca outgoing-hosts service-name cert-archive;

      PATH = "${kmod}/bin:${kmod}/sbin:${strongswan}/bin:${strongswan}/sbin";
    };
  };

} // (if cert-archive == null then {
  initializer = generate-certs service-name;
} else {})
