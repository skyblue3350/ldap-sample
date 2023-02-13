#!/bin/env bash

set -e

base_dn="dc=$(echo ${LDAP_DOMAIN} | sed 's/\./,dc=/')"

cat << EOS > /etc/nslcd.conf
uid nslcd
gid nslcd

uri ldap://${LDAP_SERVER_ADDR}:${LDAP_SERVER_PORT}/

base ${base_dn}
ldap_version 3
binddn cn=admin,${base_dn}
bindpw ${LDAP_ADMIN_PASSWORD}

tls_cacertfile /etc/ssl/certs/ca-certificates.crt
EOS

/usr/sbin/sshd
/usr/sbin/nslcd -d
