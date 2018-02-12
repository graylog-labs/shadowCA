#!/usr/bin/env bash
#
# create certificates and sign them with the CA
# that is created with the create_ca.sh script
#
# The variable CRTNAME should be set with the needed/wanted certificate name.
# If needed additional alt_names should be set and the settings might be adjusted.
# 


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

# CA must be first!
if [ ! -d "${CACERTDIR}" ]; then
	echo "Please create your CA first!"
	exit 1;
fi

while getopts "d:h:i:" opt; do
  case ${opt} in
    h) HNAME+=("${OPTARG}");;
    i) HIP+=("${OPTARG}");;
    d) VALIDDAYS=${OPTARG};;
    s) KEYSECRET=${OPTARG};;
    ?) HELPME=yes;;
    *) HELPME=yes;;
  esac
done

if [ -n "${HELPME}" ]; then
  echo "
  This script will generate certificates, sign them with your ${CANAME} and write them to

  Options available:
      -h  to set Hostnames (can be used multiple times)
      -i  to set IP Adresses (can be used multiple times)
      -d  (optional) Number of Days the certificate is valid (default=365)
      -s  (optional) The secret that is used for the crypted key (default=secret)
  "
  exit 0

fi

if [ -z "${HNAME}" ]; then
  echo "please provide hostname (-h) at least once. Try -? for help.";
  exit 1;
fi

# set localhost IP if no other set
if [ -z "${HIP}" ]; then
  HIP+=(127.0.0.1)
fi

# if no VALIDDAYS are set, default 365
if [ -z "${VALIDDAYS}" ]; then
  VALIDDAYS=365
fi

# if no Key provided, set default secret
if [ -z "${KEYSECRET}" ]; then
  KEYSECRET=secret
fi

# sort array entries and make them uniq
NAMES=($(printf "DNS:%q\n" "${HNAME[@]}" | sort -u))
IPADD=($(printf "IP:%q\n" "${HIP[@]}" | sort -u))

# print each elemet of both arrays with comma seperator
# and create a string from the array content
SUBALT=$(IFS=','; echo "${NAMES[*]},${IPADD[*]}")


echo "${SUBALT}"
echo "${NAMES}"
echo "${HNAME}"
echo "${IPADD}"

######
# WORK STARTS
######

# The first provided Hostname will be used
# as reference as this must be the identifier

# abort if cert dir is present 
# or create dir
if [ -d "${CERTDIR}/${HNAME}" ];then 
	echo -e "Looks like ${HNAME} has already a certificate\n ${CERTDIR}/${HNAME} present \n ABORT now"
	exit 1;
else
	mkdir -p "${CERTDIR}/${HNAME}" || { echo "error creating cert dir"; exit 1;}
	echo "Created ${CERTDIR}/${HNAME} ..."
	WDIR=${CERTDIR}/${HNAME}
	# the first name will taken as the name
	CRTNAME=${HNAME}
fi

if [ -z "${WDIR}" ]; then
  echo "WorkDir not set - something went terrible wrong";
  exit 1;
fi

if [ -z "${CRTNAME}" ]; then
  echo "Certificate Name not set - Maybe the first Hostname contains space?";
  exit 1;
fi

echo "... create private Key for ${CRTNAME}"
# create private key for server
${SSLBIN} genrsa -out ${WDIR}/${CRTNAME}.key ${CRTBIT}


echo "... write configuration for ${CRTNAME} ..." 
# The following settings might be adjusted to your needs
cat >> ${WDIR}/${CRTNAME}.cnf <<EOF
[ req ]
prompt = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C = ${CACOUNTRY}
ST = ${CASTATE}
L = ${CACITY}
O = ${CANAME}
OU = Support ${CANAME}
CN = ${CRTNAME}
emailAddress = ${CAMAIL}
EOF


echo "... create Certificate Request for ${CRTNAME} ..."
# create csr
openssl req -new -config ${WDIR}/${CRTNAME}.cnf -key ${WDIR}/${CRTNAME}.key -out ${WDIR}/${CRTNAME}.csr


echo "... prepare sign of ${CRTNAME} request ..."
# create .ext file
#
# if additinonal alt_names are needed, just add them
# with the following number in sequence

cat << EOF > ${WDIR}/${CRTNAME}.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = ${SUBALT}
EOF

echo "... sign of ${CRTNAME} request ..."
# create the certificate
openssl x509 -req -in ${WDIR}/${CRTNAME}.csr -CA "${CACERTDIR}"/"${CANAME}".pem -CAkey "${CACERTDIR}"/"${CANAME}".key -CAcreateserial -out ${WDIR}/${CRTNAME}.crt -days "${CAVDAYS}" -sha256 -extfile ${WDIR}/${CRTNAME}.ext
# create certificate pem
# or fullchain certificate
cat ${WDIR}/${CRTNAME}.crt ${WDIR}/${CRTNAME}.key > ${WDIR}/${CRTNAME}.pem

echo "created ${WDIR}/${CRTNAME} that contains all needed files"
echo ""
ls -la ${WDIR}/