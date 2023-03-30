## Пользователи и группы
В качестве примера будем рассматривать пользователя localadmin и группу localadmins

##### Создание пользователя в ОС Debian

```
adduser localadmin
```

В процессе создания вас попросят ввести пароль пользователя (обязательный параметр) и множетсво дополнительных параметров, которые можно пропустить нажимая Enter

Так же будет автоматически создана одноименная группа localadmin в которую будет добавлен этот пользователь

##### Создание группы в ОС Debian

```
addgroup localadmins
```
Будет создана только группа

##### Добавление пользователя в группу в ОС Debian

Для добавления пользователя в существующую группу воспользуемся командой usermod

```
usermod -aG localadmins localadmin
```
Параметр -a добавляет в новую группу не исключая из других, параметр -G делает эту группу не основной для пользователя

##### Добавление пользователю прав на исполнение команды с правами пользователя root с помощью sudo

В данном примере рассмотрим назначение пользователю прав на выполнение ВСЕХ команд без ввода пароля

Нам необходимо отредактировать файл /etc/sudoers  и добавить в него следующее содержимое:

```
localadmin  ALL=(root)NOPASSWD:ALL

```

Для того, чтобы ограничить список команд, необходимо изменить конфигурацию:

```
localadmin  ALL=(root)NOPASSWD:/usr/bin/id,/usr/bin/find,/bin/cat
```

Чтобы определить расположение определенной команды необходимо в терминале ввести:
```
which <команда>
```