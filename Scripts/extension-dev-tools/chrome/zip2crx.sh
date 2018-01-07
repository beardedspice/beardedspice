#!/bin/sh
set -e
zipfile="$1"
basename="${zipfile%%.zip}"
if [ "${basename}" == "$1" ] ; then
    echo "Usage: file.zip"
    echo "Prepends the CRX header before file.zip using file.pem, outputs to file.crx"
    echo "If file.pem does not exist, then it is automatically created"
    exit
fi

pemfile="${basename}.pem"
crxfile="${basename}.crx"
if [ ! -e "${pemfile}" ] ; then
    2>/dev/null openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out "${pemfile}"
fi

signature=$(2>/dev/null openssl sha1 -sha1 -binary -sign "${pemfile}" < "${zipfile}")
publickey=$(2>/dev/null openssl rsa -in "${pemfile}" -pubout -outform DER)

appendinteger() {
    bit1=$((($1      ) & 0xFF ))
    bit2=$((($1 >>  8) & 0xFF ))
    bit3=$((($1 >> 16) & 0xFF ))
    bit4=$((($1 >> 24) & 0xFF ))
    printf "$(printf '\\x%x\\x%x\\x%x\\x%x' ${bit1} ${bit2} ${bit3} ${bit4} )" >> "${crxfile}"
}

# CRX header
printf 'Cr24\x02\x00\x00\x00' > "${crxfile}"
appendinteger ${#publickey}
appendinteger ${#signature}
printf '%s' "${publickey}${signature}" >> "${crxfile}"
cat "${zipfile}" >> "${crxfile}"
