generate-certs
===============

`generate-certs` creates a script that generates a private key and CSR,
waits for a signed cert to appear, generates a pkcs12 archive from the cert
and the key, and exits. If the cert or archive already exist, `generate-certs`
skips the relevant step. Files end up in /etc/x509/&lt;name>.{crt,pem,p12}.

Arguments
----------

* `name`: The name of the certificate to generate.
