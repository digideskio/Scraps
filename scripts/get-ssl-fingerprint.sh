#!/bin/bash
##
## A simple way to the current fingerprint of an SSL certificate

echo -n | openssl s_client -connect $1:$2 -CAfile /usr/share/ca-certificates/mozilla/DigiCert_Assured_ID_Root_CA.crt | sed -ne
'/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ./$1
