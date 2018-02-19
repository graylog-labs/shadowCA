# Create CA and certificates

This are two scripts, the first *create_ca_certificate.sh* is only needed once to create the CA. The second script *create_certificate.sh* can then be used to create certificates that are signed by the CA.

# create_ca_certificate.sh

The settings for the CA might be modified according to your needs. You will be asked for the CA Passphrase (that will be needed to sign all certificates) - which should be written down. The settings are in the `../shadowCA.cfg`.

# create_certificate.sh

The settings are in the `../shadowCA.cfg` and all other settings can be set using parameters.

```
This script will generate certificates, sign them with your shadowCA and write them to

  Options available:
      -h  to set Hostnames (can be used multiple times)
      -i  to set IP Adresses (can be used multiple times)
      -d  (optional) Number of Days the certificate is valid (default=365)
 ```
