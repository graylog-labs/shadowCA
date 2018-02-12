#!/usr/bin/env bash
#
#  Ressources from the web
#
#  https://deliciousbrains.com/ssl-certificate-authority-for-local-https-development/
#
#  In addition the shadowCA.pem should be added to your browser if you want to use the created certifcates
#  for Web services
#########

WPATH=$( pwd )
# Check if we find the configuration in the current path
[ -f "${WPATH}"/shadowCA.cfg ]  && CFGPATH="${WPATH}"

# Subtitute bin$ dir from present pwd 
# after that retry to find configuration
WPATH=$( echo "${WPATH}" | sed -e 's#/bin$##g' )
[ -f "${WPATH}"/shadowCA.cfg ] && CFGPATH="${WPATH}"

# if no config is found 
# we have no base dir and exit 
[ -d "${CFGPATH}" ] || exit 1

# remove unwanted from cfg file
# that might harm and is not wanted
configfile="${CFGPATH}/shadowCA.cfg"
configfile_secured="${CFGPATH}/.shadowCA.cfg"

# check if the file contains something we don't want
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
  echo "Config file is unclean, cleaning it..." >&2
  # filter the original to a new file
  egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
  configfile="$configfile_secured"
fi

# now source it, either the original or the filtered variant
source "$configfile"

if [ -z "${SSLBIN}" ]; then
  echo "no openssl detected aborting"
  exit 1;
fi

# Check if CA Key is already present
[ -f "${CACERTDIR}/${CANAME}.key" ] && echo -e "Error \n shadowCA Key already present \n Will stop creating a new key" && exit 1; 

# create CA Folder if not present
[ -d "${CACERTDIR}" ] || mkdir -p ${CACERTDIR}

# write the configuration for your CA
# that will be used to create
# In addition later it is possible to check
# what settings are used.
cat >> "${CACERTDIR}"/"${CANAME}".cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = ${CACOUNTRY}
ST = ${CASTATE}
L = ${CACITY}
O = ${CANAME}
OU = Support ${CANAME}
CN = ${CANAME} (by jalogisch)
emailAddress = ${CAMAIL}
EOF


# generate private key
echo -e "\nGenerate Private Key ... \n choose a strong CA Password if requested!! \n"
"${SSLBIN}" genrsa -des3 -out "${CACERTDIR}"/"${CANAME}".key 2048

# generate root certificate
echo -e  "\nSign ROOT Certificate with your previous entered CA Password ... \n "
"${SSLBIN}" req -x509 -new -nodes -key "${CACERTDIR}"/"${CANAME}".key -sha256 -days "${CAVDAYS}" -config "${CACERTDIR}"/"${CANAME}".cnf -out "${CACERTDIR}"/"${CANAME}".pem

# create DER from ca.pem
echo -e "\nCreate DER from ${CACERTDIR}/${CANAME}.pem "
"${SSLBIN}" x509 -in "${CACERTDIR}"/"${CANAME}".pem -inform pem -out "${CACERTDIR}"/"${CANAME}".der -outform der

echo "Success"
echo -e "now you can Import\n ${CACERTDIR}/${CANAME}.pem or\n ${CACERTDIR}/${CANAME}.der\ninto your Systems Truststore\n"
echo "This is needed on all System that should trust this CA."
