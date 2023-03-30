## Установка и настройка сайта с помощью NGINX


### Установка NGINX
1. Установка пакета
```
apt update -y && apt upgrade -y
apt install nginx -y
```
2. Удалим дефолтный сайт
```
rm /etc/nginx/sites-enabled/default
```
3. Создадим новый файл с конфигурацией нашего сайта /etc/nginx/sites-enabled/msk_skills
```
server {
        listen 80 ;
        root  /var/www/ ;
        index index.html ;
        server_name web1.msk.skills ;
        location /     {
            try_files $uri $uri/ =404;
        }

        if ($host != “web.office.wsr”) {
            return 404;
        }
}
```
4. Создадим файл index.html с содержимым нашего сайта в корневой директории
```
Hello from compx-srv1 !
```
5. Создадим файл Task.html с содержимым нашего сайта в корневой директории
```
Welcome to our cute championship!
```
6. Добавим наш сервис в автозагрузку и включим его
```
systemctl enable nginx --now
```

### Настройка синхронизации директорий каждую минуту с помощью rsync

1. Проверим, что команда синхронизирует только новые/измененные файлы
```
rsync -au /var/www/task.html user@10.0.0.3:/var/www/task.html
```
2. Добавить ssh ключ
```
ssh-copy-id user@10.0.0.3
```
3. В случае успеха пункта 1 добавим на выполнение планировщиком crontab каждую минуту:
```
*/1 * * * * rsync -au /var/www/task.html user@10.0.0.3:/var/www/task.html
```
