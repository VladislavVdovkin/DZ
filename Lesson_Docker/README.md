## Docker

#### 1. Docker

##### 1.1 Создать кастомный образ nginx на базе alpine.

Создадим [Dockerfile](docker/nginx/Dockerfile) для nginx, запустим сборку образа:

```
docker build -t vdovkin/nginx --no-cache .
```

В файлах [nginx.conf](docker/nginx/nginx.conf) и [default.conf](docker/nginx/default.conf) находится минимально необходимый конфиг для старта nginx.

##### 1.2 После запуска nginx должен отдавать кастомную страницу.

Запускаем контейнер и проверяем:

```
docker run -d -p 8080:8080 --name nginx vdovkin/nginx
```

```
$ curl -I http://localhost:8080

HTTP/1.1 200 OK
Server: nginx/1.14.2
Date: Tue, 18 May 2021 09:48:39 GMT
Content-Type: text/html
Content-Length: 33
Last-Modified: Tue, 18 May 2021 09:48:39 GMT
Connection: keep-alive
ETag: "5c3dac77-21"
Accept-Ranges: bytes

$ curl http://localhost:8080

New NGINX instance inside Docker
```

#### 2. Docker-compose

##### 2.1 Создать кастомные образы nginx и php.

Кастомный образ nginx был создан в [п. 1.1](#) и выложен в Docker Hub.

Кастомный образ php будем создавать на основе php-fpm - менеджера процессов PHP Fast CGI. См. [Dockerfile](docker/php/Dockerfile).

Собираем образ 

```
$ docker build vdovkin/fpm --no-cache .

```

##### 2.2 Объединить nginx и php в docker-compose. 

Сам файл [Docker-compose.yml](docker-compose/docker-compose.yml), к нему необходимо дописать пару конфигурационных файлов:

- [defaul-php.conf](docker-compose/defaul-php.conf) конфигурация nginx для работы с php,
- [index.php](docker-compose/code/index.php) - файл с командой вывода php-info.

Стартуем контейнеры:

```
$ docker-compose up -d
```

После запуска nginx должен показывать php-info. 


