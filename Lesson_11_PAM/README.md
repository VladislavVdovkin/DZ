#Cкачиваем Vagrantfile, запускаем и подключаемся

	vagrant up
	vagrant ssh

#Установка всех пакетов и зависисмостей произойдет при поднятии Vagrantfile с помощью provision shell	
#Последующие действия будем выполнять из под root

	sudo -i
	

#Создаем файл конфигурации для сервиса 

	touch /etc/sysconfig/watchlog
	
#Приводим в соответствие с помощью nano

	# Configuration file for my watchdog service
	# Place it to /etc/sysconfig
	# File and word in that file that we will be monit
	WORD="ALERT"
	LOG=/var/log/watchlog.log
	

#Создаем наш log файл с ключевым словом ALERT

	nano /var/log/watchlog.log

#Создаем скрипт nano /opt/watchlog.sh

	nano /opt/watchlog.sh

#Вывод 
	
	#!/bin/bash
	WORD=$1
	LOG=$2
	DATE=`date`
	if grep $WORD $LOG &> /dev/null
	then
	logger "$DATE: I found word, Master!"
	else
	exit 0
	fi

#Делаем его исполняемым

	chmod +x /opt/watchlog.sh
	
	
#Создаем Unit файл сервиса 

	nano /etc/systemd/system/watchlog.service
		

#Вывод 
		
	[Unit]
	Description=My watchlog service
	[Service]
	Type=oneshot
	EnvironmentFile=/etc/sysconfig/watchlog
	ExecStart=/opt/watchlog.sh $WORD $LOG


#Создаем Unit файл таймера

	nano /etc/systemd/system/watchlog.timer
	
#Вывод

	[Unit]
	Description=Run watchlog script every 30 second
	[Timer]
	# Run every 30 second
	OnActiveSec=30sec
	Unit=watchlog.service
	[Install]
	WantedBy=multi-user.target
	
#Запускаем таймер 

	systemctl enable watchlog.timer
	systemctl start watchlog.timer
	
#Проверяем работу 

	tail -f /var/log/messages
	 
#Вывод

	Feb  2 04:47:59 localhost systemd: Stopping Run watchlog script every 30 second.
	Feb  2 04:48:07 localhost systemd: Started Run watchlog script every 30 second.
	Feb  2 04:48:07 localhost systemd: Starting Run watchlog script every 30 second.
	Feb  2 04:48:52 localhost systemd: Starting My watchlog service...
	Feb  2 04:48:52 localhost root: Tue Feb  2 04:48:52 UTC 2021: I found word, Master!
	Feb  2 04:48:52 localhost systemd: Started My watchlog service.
	Feb  2 04:48:55 localhost systemd: Stopped Run watchlog script every 30 second.
	Feb  2 04:48:55 localhost systemd: Stopping Run watchlog script every 30 second.
	Feb  2 04:48:57 localhost systemd: Started Run watchlog script every 30 second.
	Feb  2 04:48:57 localhost systemd: Starting Run watchlog script every 30 second.


	
	
#Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно так же называться
#Правим файл /etc/sysconfig/spawn-fcgi
	
	nano /etc/sysconfig/spawn-fcgi
	
#Вывод
	
	# You must set some working options before the "spawn-fcgi" service will work.
	# If SOCKET points to a file, then this file is cleaned up by the init script.
	#
	# See spawn-fcgi(1) for all possible options.
	#
	# Example :
	SOCKET=/var/run/php-fcgi.sock
	OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -- /usr/bin/php-cgi"


#Создаем Unit файл сервиса

	nano /etc/systemd/system/spawn-fcgi.service
	
	
#Вывод

	[Unit]
	Description=Spawn-fcgi startup service by Otus
	After=network.target
	[Service]
	Type=simple
	PIDFile=/var/run/spawn-fcgi.pid
	EnvironmentFile=/etc/sysconfig/spawn-fcgi
	ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
	KillMode=process
	[Install]
	WantedBy=multi-user.target

#Запускаем сервис и проверяем статус

	systemctl start spawn-fcgi
	systemctl status spawn-fcgi
	
	
#Вывод

		● spawn-fcgi.service - Spawn-fcgi startup service by Otus
	Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
	Active: active (running) since Tue 2021-02-02 04:53:33 UTC; 5s ago
	Main PID: 3902 (php-cgi)
	CGroup: /system.slice/spawn-fcgi.service
			├─3902 /usr/bin/php-cgi
			├─3903 /usr/bin/php-cgi
			├─3904 /usr/bin/php-cgi
			├─3905 /usr/bin/php-cgi
			├─3906 /usr/bin/php-cgi
			├─3907 /usr/bin/php-cgi
			├─3908 /usr/bin/php-cgi
			├─3909 /usr/bin/php-cgi
			├─3910 /usr/bin/php-cgi
			├─3911 /usr/bin/php-cgi
			├─3912 /usr/bin/php-cgi
			├─3913 /usr/bin/php-cgi
			├─3914 /usr/bin/php-cgi
			├─3915 /usr/bin/php-cgi
			├─3916 /usr/bin/php-cgi
			├─3917 /usr/bin/php-cgi
			├─3918 /usr/bin/php-cgi
			├─3919 /usr/bin/php-cgi
			├─3920 /usr/bin/php-cgi
			├─3921 /usr/bin/php-cgi
			├─3922 /usr/bin/php-cgi
			├─3923 /usr/bin/php-cgi
			├─3924 /usr/bin/php-cgi
			├─3925 /usr/bin/php-cgi
			├─3926 /usr/bin/php-cgi
			├─3927 /usr/bin/php-cgi
			├─3928 /usr/bin/php-cgi
			├─3929 /usr/bin/php-cgi
			├─3930 /usr/bin/php-cgi
			├─3931 /usr/bin/php-cgi
			├─3932 /usr/bin/php-cgi
			├─3933 /usr/bin/php-cgi
			└─3934 /usr/bin/php-cgi
	
#Дополнить юнит-файл apache httpd возможностьб запустить несколько инстансов сервера с разными конфигами
#Копируем Unit файл в Systemd
	
	cp /usr/lib/systemd/system/httpd.service /etc/systemd/system

	
#Переименовываем 

	mv /etc/systemd/system/httpd.service /etc/systemd/system/httpd@.service

#Редактируем и приводим к соответствующему виду

	nano /etc/systemd/system/httpd@.service
	
#Вывод

	[Unit]
	Description=The Apache HTTP Server
	After=network.target remote-fs.target nss-lookup.target
	Documentation=man:httpd(8)
	Documentation=man:apachectl(8)
	[Service]

	Type=notify
	EnvironmentFile=/etc/sysconfig/httpd-%I
	ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
	ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
	ExecStop=/bin/kill -WINCH ${MAINPID}
	KillSignal=SIGCONT
	PrivateTmp=true

	[Install]
	WantedBy=multi-user.target


#Переходим в каталог с конфиругационными файлами
	
	cd /etc/httpd/conf
	
#Путем копирования создаем два конфигурационных файла

	scp httpd.conf first.conf
	scp httpd.conf second.conf


#Файл first.conf оставляем без изменений, во втором правим порт,а так же указываем путь до pid файла процесса

	nano second.conf

#Вывод

	ServerRoot "/etc/httpd"
	PidFile /var/run/httpd-second.pid
	#
	# Listen: Allows you to bind Apache to specific IP addresses and/or
	# ports, instead of the default. See also the <VirtualHost>
	# directive.
	#
	# Change this to Listen on specific IP addresses as shown below to
	# prevent Apache from glomming onto all bound IP addresses.
	#
	#Listen 12.34.56.78:80
	Listen 8080
	
	
#Переходим в sysconfig
	
	cd /etc/sysconfig/
	
#Так же путем копирования создаем два файла 

	scp httpd httpd-first
	scp httpd httpd-second
	
#Правим файл httpd-first

	nano httpd-first
	
#Вывод

	#
	# To pass additional options (for instance, -D definitions) to the
	# httpd binary at startup, set OPTIONS here.
	#
	OPTIONS=-f conf/first.conf

#Правим файл httpd-second 

	nano httpd-second

#Вывод
	
	#
	# To pass additional options (for instance, -D definitions) to the
	# httpd binary at startup, set OPTIONS here.
	#
	OPTIONS=-f conf/second.conf
	
#Запускаем сервис с первым конфигурационным файлом и проверяем статус

	systemctl start httpd@first.service
	systemctl status httpd@first.service
	
#Вывод

	● httpd@first.service - The Apache HTTP Server
	Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
	Active: active (running) since Tue 2021-02-02 05:15:59 UTC; 12s ago
		Docs: man:httpd(8)
			man:apachectl(8)
	Main PID: 4334 (httpd)
	Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
	CGroup: /system.slice/system-httpd.slice/httpd@first.service
			├─4334 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			├─4335 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			├─4336 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			├─4337 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			├─4338 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			├─4339 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND
			└─4340 /usr/sbin/httpd -f conf/first.conf -DFOREGROUND

	
	
#Запускаем сервис со вторым конфигурационным файлом и проверяем статус

	systemctl start httpd@second.service
	systemctl status httpd@second.service
	
#Вывод

	● httpd@second.service - The Apache HTTP Server
	Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
	Active: active (running) since Tue 2021-02-02 05:16:37 UTC; 13s ago
		Docs: man:httpd(8)
			man:apachectl(8)
	Main PID: 4350 (httpd)
	Status: "Total requests: 0; Current requests/sec: 0; Current traffic:   0 B/sec"
	CGroup: /system.slice/system-httpd.slice/httpd@second.service
			├─4350 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			├─4351 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			├─4352 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			├─4353 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			├─4354 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			├─4355 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
			└─4356 /usr/sbin/httpd -f conf/second.conf -DFOREGROUND
	
	

#Так же проверяем порты на которых работают сервисы

	ss -tnlp
	
#Вывод
	
	State       Recv-Q Send-Q                                                           Local Address:Port                                                                          Peer Address:Port
	LISTEN      0      128                                                                          *:111                                                                                      *:*
	users:(("rpcbind",pid=576,fd=8))
	LISTEN      0      128                                                                          *:22                                                                                       *:*
	users:(("sshd",pid=865,fd=3))
	LISTEN      0      100                                                                  127.0.0.1:25                                                                                       *:*
	users:(("master",pid=1099,fd=13))
	LISTEN      0      128                                                                         :::111                                                                                     :::*
	users:(("rpcbind",pid=576,fd=11))
	LISTEN      0      128                                                                         :::8080                                                                                    :::*
	users:(("httpd",pid=4356,fd=4),("httpd",pid=4355,fd=4),("httpd",pid=4354,fd=4),("httpd",pid=4353,fd=4),("httpd",pid=4352,fd=4),("httpd",pid=4351,fd=4),("httpd",pid=4350,fd=4))
	LISTEN      0      128                                                                         :::80                                                                                      :::*
	users:(("httpd",pid=4340,fd=4),("httpd",pid=4339,fd=4),("httpd",pid=4338,fd=4),("httpd",pid=4337,fd=4),("httpd",pid=4336,fd=4),("httpd",pid=4335,fd=4),("httpd",pid=4334,fd=4))
	LISTEN      0      128                                                                         :::22                                                                                      :::*
	users:(("sshd",pid=865,fd=4))
	LISTEN      0      100                                                                        ::1:25                                                                                      :::*
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	


































