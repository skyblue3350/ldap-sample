# LDAP動作確認用

LDAPサーバとクライアントの動作デモ

## アカウントとグループの構成

OUは以下の2つを用意

- users
  - ユーザを紐づけておくOU
- groups
  - グループを紐づけておくOU

ユーザは下記の2アカウント用意

- testuser1
  - pass: pass1
  - groups: members, admin
- testuser2
  - pass: pass2
  - groups: members

グループは下記の2グループ用意

- members
  - testuser1, testuser2
- admin
  - testuser1

## 使い方

コンテナを起動します

```bash
docker-compose up -d --build
```

コンテナの起動後、初期設定投入スクリプトを実行します

```bash
./ldap-init.sh
```

コンテナ内部からLDAPのアカウントが参照できることを確認します

```
docker-compose exec ldap-client getent group | tail -n 2
members:*:1000:testuser2,testuser1
admin:*:1001:testuser1
```

testuser1でコンテナ外部からsshして接続できることを確認します

```
ssh testuser1@localhost -p 22222
testuser1@localhost's password: pass1
Creating directory '/home/testuser1'.

testuser1@93ad765f591d:~$ pwd
/home/testuser1
testuser1@93ad765f591d:~$ id
uid=2001(testuser1) gid=1000(members) groups=1000(members),1001(admin)
```

同様にtestuser2でコンテナ外部からsshして接続できることを確認します

```
ssh testuser2@localhost -p 22222
testuser2@localhost's password: pass2
Creating directory '/home/testuser2'.
testuser2@93ad765f591d:~$ pwd
/home/testuser2
testuser2@93ad765f591d:~$ id
uid=2002(testuser2) gid=1000(members) groups=1000(members)
```
