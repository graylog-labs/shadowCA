# shadowCA
Create a CA and Certificates to use in your Infrastructure


## Idea
It becomes more and more important to have your infrastructure communication secured with certificates.
Not every environment provide a [CA](https://en.wikipedia.org/wiki/Certificate_authority) that can easily be used for that infrastructure. 

Taking [shadow it](https://en.wikipedia.org/wiki/Shadow_IT) and implement that might not be best practice but it is supposted to 'just works' and theirfore is used in production.

<aside class="notice">
The scripts in this repository should give you the option of POC usage and might be used in production - but was never build for that.
</aside>

After reading [Brad Touesnard](https://github.com/bradt) posting about [become your own CA](https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/) (for development) it kicks me that I would need todo this in every Customer Environment where this might be needed. So the idea of shadowCA was born.

## Installation

Clone this repository on a host that should hold your CA:

     git clone https://github.com/graylog-labs/shadowCA.git

### Create your CA
Some settings can be changed in the `shadowCA.cfg` file to fit your environment. After that run `create_ca_certificate.sh` to create your certificate authority

    bash bin/create_ca_certificate.sh

The script will try to detect if a CA is already present (and abort if). If run successfull you will get a similar output like the following:

```bash
Config file is unclean, cleaning it...

Generate Private Key ...
 choose a strong CA Password if requested!!

Generating RSA private key, 2048 bit long modulus
........+++
..............................+++
e is 65537 (0x10001)
Enter pass phrase for /Users/jd/bench/shadowCA/cert/CA/shadowCA.key:
Verifying - Enter pass phrase for /Users/jd/bench/shadowCA/cert/CA/shadowCA.key:

Sign ROOT Certificate with your previous entered CA Password ...

Enter pass phrase for /Users/jd/bench/shadowCA/cert/CA/shadowCA.key:

Create DER from /Users/jd/bench/shadowCA/cert/CA/shadowCA.pem
Success
now you can Import
 /Users/jd/bench/shadowCA/cert/CA/shadowCA.pem or
 /Users/jd/bench/shadowCA/cert/CA/shadowCA.der
into your Systems Truststore

This is needed on all System that should trust this CA.
``` 

The pass phrase for the CA is used to sign your CA and all certificates you create with the included scripts. Keep that in mind, as we do not include any script to reset this key. 

### Create certificates
With just the single command `create_certificate.sh` you are able to create now host certificates to be used for all kind server and services. Without any argument it will just gives you a small hint that something is missing and how to get help `-?` will provide you the following:

```bash

  This script will generate certificates, sign them with your shadowCA and write them to

  Options available:
      -h  to set Hostnames (can be used multiple times)
      -i  to set IP Adresses (can be used multiple times)
      -d  (optional) Number of Days the certificate is valid (default=365)
``` 

The first provided hostname will be used as _common name_ and all additional will be used as _alternative names_. By default `127.0.0.1` is added as IP _alternative name_ and additional IPs can be added too.

## WARNING
<aside class="warning">
This scripts are not written to be a solid production CA for your environment, more to kickstart your POC. Use this on your own risk.
</aside>

