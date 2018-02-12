#!/usr/bin/env bash
#
#  Ressources from the web
#
#  https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
#  https://connect2id.com/blog/importing-ca-root-cert-into-jvm-trust-store
#
#
#
#  
#########
#  Create CA and add the CA.pem (certificate) to the JVM Keystore
#  That Graylog will trust all certificates that are signed by that CA.
#
#  In addition the myCA.pem should be added to your browser if you want to use the created certifcates
#  for example in the Graylog Web Interface
#########

# Create Folder and Change into
[ -d /etc/myCA ] || mkdir -p /etc/myCA
cd /etc/myCA || exit 1


cat >> myCA.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = DE
ST = NRW
L = Herne
O = Graylog Inc.
OU = Support
CN = my own Graylog CA
emailAddress = hello@graylog.com
EOF

# generate private key
openssl genrsa -des3 -out myCA.key 2048

# generate root certificate
# this will be valid for 5 years
openssl req -x509 -new -nodes -key myCA.key -sha256 -days 1825 -config myCA.cnf -out myCA.pem

# create DER from ca.pem
openssl x509 -in myCA.pem -inform pem -out myCA.der -outform der

# test if .der is fine
keytool -v -printcert -file myCA.der

# copy cacert into Graylog Folder
[ -f /usr/lib/jvm/jre/lib/security/cacerts ] && cp /usr/lib/jvm/jre/lib/security/cacerts /etc/graylog/server/cacerts.jks
[ -f /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts ] && cp /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/cacerts /etc/graylog/server/cacerts.jks


# import CA der into keystore
# will only work if the default password&user is not changed.
keytool -importcert -alias myCA -keystore /etc/graylog/server/cacerts.jks -storepass changeit -file myCA.der

# verify that the certificate is present
keytool -keystore /etc/graylog/server/cacerts.jks -storepass changeit -list | grep my


echo "
Centos / RHEL
add to /etc/sysconfig/graylog-server / GRAYLOG_SERVER_JAVA_OPTS
   -Djavax.net.ssl.trustStore=/etc/graylog/server/cacerts.jks

Ubuntu / Debian
 add to /etc/default/graylog-server / GRAYLOG_SERVER_JAVA_OPTS
   -Djavax.net.ssl.trustStore=/etc/graylog/server/cacerts.jks

import
   /etc/myCA/myCA.pem into your browsers to be able to verify the certifcates
   - this myCA.pem is needed for all clients that should trust the certificates that are
     create with your CA.
"
