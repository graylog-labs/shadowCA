# Add the CA certificate to truststore

To actually use your CA and get rid of the warnings and needs of use some kind of _trust unsecure connections_ settings in your tools you need to add the CA certificate you have created to all Systems truststore.


With the used shadowCA scripts the name of the needed certificate is by default `shadowCA.pem` and is located on `./cert/CA/` of your ca repository.




| OS | add certificate | remove certificate
| --- | --- | --- |
| Mac OS X | `sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain shadowCA.pem` | `sudo security delete-certificate -c "<name of existing certificate>" ` |
| Windows | `certutil -addstore -f "ROOT" shadowCA.pem` | `certutil -delstore "ROOT" serial-number-hex` | 
| Debian / Ubuntu | `sudo cp shadowCA.pem /usr/local/share/ca-certificates/shadowCA.pem && sudo update-ca-certificates` | `sudo rm /usr/local/share/ca-certificates/shadowCA.pem && sudo update-ca-certificates --fresh` | 
| CentOS / RedHat |`sudo cp shadowCA.pem /etc/pki/ca-trust/source/anchors/ && sudo update-ca-trust extract` | `sudo rm /etc/pki/ca-trust/source/anchors/shadowCA.pem && sudo update-ca-trust extract` |

The above might not be complete, but can be a first starter. Contributions are welcome.

