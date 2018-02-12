# Create CA and certificates

This are two scripts, the first *create_ca.sh* is only needed once to create the CA. The second script *create_crt.sh* can then be used to create certificates that are signed by the CA.

# create_ca.sh

The settings for the CA might be modified according to your needs. You will be asked for the CA Passphrase (that will be needed to sign all certificates) - which should be written down.

# create_crt.sh

The variable `CRTNAME` should be set before each run to the hostname that the certificate should be valid for. The certificate will be valid for localhost in addition (`alt_name` DNS.2) to the choosen `CRTNAME`. Some settings for the certificate might be adjusted for your needs.

