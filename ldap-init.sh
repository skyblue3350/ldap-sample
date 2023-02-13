#!/bin/env bash

set -e

function log() {
  echo "[LOG] $@"
}

source ldap

base_dn="dc=$(echo $LDAP_DOMAIN | sed 's/\./,dc=/')"
log "base_dn: $base_dn"

log "OU作成"
docker-compose exec -T ldap-server \
  bash -c "cat << EOS | ldapadd -x -D 'cn=admin,$base_dn' -w $LDAP_ADMIN_PASSWORD
dn: ou=users,$base_dn
objectClass: top
objectClass: organizationalUnit
ou: users

dn: ou=groups,$base_dn
objectClass: top
objectClass: organizationalUnit
ou: groups
EOS" | :

log "テストグループを追加"

docker-compose exec -T ldap-server \
  bash -c "cat << EOS | ldapadd -x -D 'cn=admin,$base_dn' -w $LDAP_ADMIN_PASSWORD
dn: cn=members,ou=groups,$base_dn
objectClass: posixGroup
objectClass: top
cn: members
memberUid: testuser1
memberUid: testuser2
gidNumber: 1000

dn: cn=admin,ou=groups,$base_dn
objectClass: posixGroup
objectClass: top
cn: admin
memberUid: testuser1
gidNumber: 1001
EOS" | :

log "テストユーザーを追加"

docker-compose exec -T ldap-server \
  bash -c "cat << EOS | ldapadd -x -D 'cn=admin,$base_dn' -w $LDAP_ADMIN_PASSWORD
dn: uid=testuser1,ou=users,$base_dn
uid: testuser1
cn: User
sn: Test
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/testuser1
userPassword: pass1
mail: testuser1@$LDAP_DOMAIN
uidNumber: 2001
gidNumber: 1000

dn: uid=testuser2,ou=users,$base_dn
uid: testuser2
cn: User
sn: Test
objectClass: top
objectClass: posixAccount
objectClass: inetOrgPerson
loginShell: /bin/bash
homeDirectory: /home/testuser2
userPassword: pass2
mail: testuser2@$LDAP_DOMAIN
uidNumber: 2002
gidNumber: 1000
EOS" | :

log "LDAP サーバへの追加確認"

docker-compose exec ldap-server \
  ldapsearch -x -b $base_dn -D "cn=admin,$base_dn" -w $LDAP_ADMIN_PASSWORD
