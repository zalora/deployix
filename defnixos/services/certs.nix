{ openssl
, wait-for-file
, writeScript
, bash
, service-types
}:

let
  # Should this be a param?
  x509-directory = "/etc/x509";

  subject =
    "/C=SG/ST=Singapore/O=Zalora/OU=DevOps/CN=$name-$id/emailAddress=it-services@zalora.com";

  conf = builtins.toFile "openssl-req.conf" ''
    [ req ]
    req_extensions = v3_ca
    distinguished_name = req_distinguished_name

    [ req_distinguished_name ]

    [ v3_ca ]
    subjectAltName = email:copy
  '';

  script = writeScript "generate-x509" ''
    #!${bash}/bin/bash -e
    name=$1
    user=$2
    if [ ! -f ${x509-directory}/$name.crt ]; then
      mkdir -p ${x509-directory}

      oldmask=`umask`
      umask 0077
      ${openssl}/bin/openssl genrsa -out ${x509-directory}/$name.pem 2048
      chown $user ${x509-directory}/$name.pem
      umask $oldmask

      id=`cat /etc/machine-id`
      ${openssl}/bin/openssl req -out ${x509-directory}/$name.csr -new -subj ${subject} \
        -key ${x509-directory}/$name.pem -config ${conf}

      ${wait-for-file} ${x509-directory}/$name.crt
    fi
  '';
in

# A service to create a cert/keypair for another service

{ service-name        # The name of the service using the cert
, user ? service-name # The user who needs access to the cert
}:

{
  description = "Generate x509 cert/key pair for ${service-name}";

  start = [ script service-name user ];

  type = service-types.oneshot;
}
