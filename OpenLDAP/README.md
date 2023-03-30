## OpenLDAP


#### Установка и первоначальная настройка LDAP Server

1. Обновим пакеты и ОС

```
sudo apt-get -y update

sudo apt-get -y upgrade
```

2. Установим OpenLDAP server и LDAP утилиты

```
apt-get -y install slapd ldap-utils
```

3. В ходе установки нужно будет задать пароль администратора LDAP сервера, имя домена, указать, какой тип базы и какую версию LDAP протокола использовать.

4. После окончания установки необходимо переконфигурировать OpenLDAP server

```
dpkg-reconfigure slapd
```
<img width="778" alt="dpkg ldap 1" src="https://user-images.githubusercontent.com/66735783/228458864-d2d26fe5-285e-476f-81c3-ed3c927a24d1.png">
<img width="785" alt="dpkg ldap 2" src="https://user-images.githubusercontent.com/66735783/228458879-8413e9d8-3851-428e-8494-bed948fbdb1c.png">
<img width="775" alt="dpkg ldap 3" src="https://user-images.githubusercontent.com/66735783/228458893-e8905886-20a0-47da-9630-9b567fa499d9.png">
<img width="723" alt="dpkg ldap 4" src="https://user-images.githubusercontent.com/66735783/228458905-ffd4e8a1-ed03-4765-b3ad-dafc58083786.png">
<img width="622" alt="dpkg ldap 5" src="https://user-images.githubusercontent.com/66735783/228459000-65669890-64d6-454e-8896-6a36b7c0ea22.png">
<img width="798" alt="dpkg ldap 6" src="https://user-images.githubusercontent.com/66735783/228459014-eb669920-34b4-4529-9609-26ac8c436a60.png">

5. Проверяем конфигурацию

```
sudo slapcat
```

6. Перезагружаем сервис

```
sudo systemctl restart slapd
sudo systemctl status slapd
```

### Вариант 1

#### Создание OrganizationalUnits, Групп и Пользователей LDAP Server

 Для создания все перечисленного выше мы будем применять .ldif файлы

##### Создание OU

1. Создайте файл /etc/ldap/ou.ldif (в репозитории этот же файл под названием organizational_units.ldif) со следующим содержимым
```
dn: ou=competitors,dc=msk,dc=skills
objectClass: organizationalUnit
ou: competitors

dn: ou=experts,dc=msk,dc=skills
objectClass: top
objectClass: organizationalUnit
ou: experts

dn: ou=managers,dc=msk,dc=skills
objectClass: top
objectClass: organizationalUnit
ou: managers
```
2. С помощью команды ldapadd добавьте OU

```
sudo ldapadd -D "cn=admin,dc=msk,dc=skills" -W -H ldapi:/// -f /etc/ldap/ou.ldif
```

3. С помощью команды ldapsearch проверьте наличие созданных ou
```
sudo ldapsearch -x -b "dc=msk,dc=skills" ou
```

##### Создание Групп

1. Создайте файл /etc/ldap/groups.ldif (в репозитории этот же файл под названием groups.ldif) со следующим содержимым
```
dn: cn=competitors,ou=competitors,dc=msk,dc=skills
objectClass: top
objectClass: posixGroup
gidNumber: 10010

dn: cn=experts,ou=experts,dc=msk,dc=skills
objectClass: top
objectClass: posixGroup
gidNumber: 10011

dn: cn=managers,ou=managers,dc=msk,dc=skills
objectClass: top
objectClass: posixGroup
gidNumber: 10012
```
2. С помощью команды ldapadd добавьте группы

```
sudo ldapadd -D "cn=admin,dc=msk,dc=skills" -W -H ldapi:/// -f /etc/ldap/groups.ldif
```

3. С помощью команды ldapsearch проверьте наличие созданных групп
```
sudo ldapsearch -x -b "dc=msk,dc=skills" groups
```

##### Создание Пользоватлей

1. Создайте файл /etc/ldap/users.ldif (в репозитории этот же файл под названием users.ldif) со следующим содержимым
```
dn: cn=competitor1,ou=competitors,dc=msk,dc=skills
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: competitor1
uid: competitor1
uidNumber: 10001
gidNumber: 10001
homeDirectory: /home/competitor1
userPassword: P@ssw0rd
loginShell: /bin/bash

dn: cn=expert1,ou=experts,dc=msk,dc=skills
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: expert1
uid: expert1
uidNumber: 10002
gidNumber: 10002
homeDirectory: /home/expert1
userPassword: P@ssw0rd
loginShell: /bin/bash

dn: cn=manager1,ou=managers,dc=msk,dc=skills
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: manager1
uid: manager1
uidNumber: 10003
gidNumber: 10003
homeDirectory: /home/manager1
userPassword: P@ssw0rd
loginShell: /bin/bash
```
2. С помощью команды ldapadd добавьте пользователей

```
sudo ldapadd -D "cn=admin,dc=msk,dc=skills" -W -H ldapi:/// -f /etc/ldap/users.ldif
```

3. С помощью команды ldapsearch проверьте наличие созданных пользователей
```
sudo ldapsearch -x -b "dc=msk,dc=skills" users
```

##### Добавление Пользователей в Группы
1. Создайте файл /etc/ldap/add_members.ldif (в репозитории этот же файл под названием add_members.ldif) со следующим содержимым

```
dn: cn=competitors,ou=competitors,dc=msk,dc=skills
changetype: modify
add: memberuid
memberuid: competitor1

dn: cn=experts,ou=experts,dc=msk,dc=skills
changetype: modify
add: memberuid
memberuid: expert1

dn: cn=managers,ou=managers,dc=msk,dc=skills
changetype: modify
add: memberuid
memberuid: manager1
```
2. С помощью команды ldapmodify добавьте пользователей в группы

```
ldapmodify -x -W -D "cn=admin,dc=msk,dc=skills" -f /etc/ldap/add_members.ldif
```



#### Добавление клиентов в домен LDAP и настройка PAM

Подготовьте клиентский ПК для ввода в домен:

1. Установите имя хоста
```
sudo hostnamectl set-hostname compX-srv3.msk.skills
```
2. Убедитесь, что сервер lDAP доступен по DNS-имени, а так же отредактируйте файл hosts
```
<ldap-server-ip> compX-srv2.msk.skills compX-srv2
<compX-srv3 ip> compX-srv3.msk.skills compX-srv3
```
3. Проверьте доступность по DNS-имени с помощью команды ping
```
ping -c3 compX-srv2.msk.skills
```
4. Установите наобходимые пакеты
```
sudo apt install libnss-ldapd libpam-ldapd ldap-utils
```
5. Во время установки завершите вход в домен
<img width="798" alt="ldap-cli 1" src="https://user-images.githubusercontent.com/66735783/228467504-f89a4d68-6e30-467e-b127-8507cc18219d.png">
<img width="812" alt="ldap-cli 2" src="https://user-images.githubusercontent.com/66735783/228467523-c7db748d-acdb-48fb-8745-5ff6e98914b1.png">
<img width="770" alt="ldap-cli 2" src="https://user-images.githubusercontent.com/66735783/228467583-736d3db1-74b4-40c9-b348-230e345f32a5.png">

6. Настройте PAM аутентификацию
```
sudo pam-auth-update
```
7. Активируйте профиль Create a home directory on login
<img width="787" alt="ldap-cli-pam 1" src="https://user-images.githubusercontent.com/66735783/228467745-1243d7a1-627e-4511-9c2c-fe364422b067.png">

8. перезагрузите машину и проверьте вход доменным пользователем




Вспомагательные материалы:

https://pro-ldap.ru/tr/admin24/intro.html
