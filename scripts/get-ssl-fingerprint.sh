#!/bin/bash
##
## A simple way to the current fingerprint of an SSL certificate
#
# $1 = mail.server.org:993

echo | openssl s_client -connect $1 |& openssl x509 -sha256 -fingerprint -noout
