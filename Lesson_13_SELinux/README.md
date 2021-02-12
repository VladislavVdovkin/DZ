#Cкачиваем Vagrantfile, запускаем и подключаемся

	vagrant up
	vagrant ssh

#Последующие действия будем выполнять из под root

	sudo -i
	

#1) Запустить nginx на нестандарном порту 3-мя разными способами

#Устанавливаем nginx

	yum install -y nginx

	
#Устанавливаем semanage

	yum -y install policycoreutils-python

	
#А) Запускаем с помощью переключятелей setsebool;
#В конфигурационном файле nginx правим стандартный порт на 12345

	nano /etc/nginx/nginx.conf

#Вывод

	server {
    listen       12345 default_server;
    listen       [::]:12345 default_server;
    server_name  _;
    root         /usr/share/nginx/html;


#После попытки запустить проверим статус и увидим ошибку

	systemctl status nginx.service

#Вывод
	
	Feb 11 05:29:01 SELinux systemd[1]: Starting The nginx HTTP and reverse proxy server...
	Feb 11 05:29:01 SELinux nginx[3858]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
	Feb 11 05:29:01 SELinux nginx[3858]: nginx: [emerg] bind() to 0.0.0.0:12345 failed (13: Permiss...ied)
	Feb 11 05:29:01 SELinux nginx[3858]: nginx: configuration file /etc/nginx/nginx.conf test failed

#Выполняем команду что бы понять какой логический тип включать

	audit2why < /var/log/audit/audit.log
	

#Утилита audit2why рекомендует выполнить команду 

	setsebool -P nis_enabled 1

#Рекомендуется выполнить команду без аргумента -P который сохраняет правило после перезагрузки

	setsebool nis_enabled 1
	
#После выполнения команды успешно запускаем nginx на необходимом нам порту и проверяем статус

	systemctl start nginx.service
	systemctl status nginx.service
	
#Вывод

	● nginx.service - The nginx HTTP and reverse proxy server
	Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	Active: active (running) since Thu 2021-02-11 05:31:53 UTC; 4s ago
	Process: 4042 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	Process: 4040 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	Process: 4039 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	Main PID: 4044 (nginx)
	CGroup: /system.slice/nginx.service
			└─4045 nginx: worker process
	
	
#Б) Добавляем порт в имеющийся тип 
#Проверяем какие порты могут работать по http и видим что нашего порта там нет

	semanage port -l | grep http
	

#Вывод

	http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
	http_cache_port_t              udp      3130
	http_port_t                    tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
	pegasus_https_port_t           tcp      5989

		

#Добавляем наш нестандартный порт в правило политики
		
	semanage port -a -t http_port_t -p tcp 12345
	

#Снова проверяем порты доступные для http

	semanage port -l | grep http


#Вывод

	http_cache_port_t              tcp      8080, 8118, 8123, 10001-10010
	http_cache_port_t              udp      3130
	http_port_t                    tcp      12345, 80, 81, 443, 488, 8008, 8009, 8443, 9000
	pegasus_http_port_t            tcp      5988
	pegasus_https_port_t           tcp      5989
	
#Запускаем nginx и проверяем статус

	systemctl start nginx.service
	systemctl status nginx.service
	

#Вывод

	● nginx.service - The nginx HTTP and reverse proxy server
	Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	Active: active (running) since Thu 2021-02-11 05:52:51 UTC; 1s ago
	Process: 3975 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	Process: 3973 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	Process: 3972 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	Main PID: 3977 (nginx)
	CGroup: /system.slice/nginx.service
			├─3977 nginx: master process /usr/sbin/nginx
			└─3978 nginx: worker process
	
	
#В) Формирование и установка модуля SELinux
#Компилируем модуль на основе лог файла аудита

	audit2allow -M httpd_add --debug < /var/log/audit/audit.log
	 
#Вывод

	[root@SELinux ~]# audit2allow -M httpd_add --debug < /var/log/audit/audit.log
	******************** IMPORTANT ***********************
	To make this policy package active, execute:
	
	semodule -i httpd_add.pp
	
	[root@SELinux ~]# ls -l
	total 24
	-rw-------. 1 root root 5763 May 12  2018 anaconda-ks.cfg
	-rw-r--r--. 1 root root  964 Feb 11 06:04 httpd_add.pp
	-rw-r--r--. 1 root root  261 Feb 11 06:04 httpd_add.te
	-rw-------. 1 root root 5432 May 12  2018 original-ks.cfg


	
	
#Инсталируем наш модуль и проверяем загрузился ли он

	semodule -i httpd_add.pp
	semodule -l | grep http
	
#Вывод
	
	[root@SELinux ~]# semodule -l | grep http
	httpd_add       1.0


#Запускаем nginx и проверяем 

	systemctl start nginx.service
	systemctl status nginx.service
	
	
#Вывод

	● nginx.service - The nginx HTTP and reverse proxy server
	Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
	Active: active (running) since Thu 2021-02-11 06:09:14 UTC; 4s ago
	Process: 4059 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
	Process: 4057 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
	Process: 4056 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
	Main PID: 4061 (nginx)
	CGroup: /system.slice/nginx.service
			├─4061 nginx: master process /usr/sbin/nginx
			└─4062 nginx: worker process


			
	
	
#2) Обеспечить работоспособность приложения при включенном selinux
#Разворачиваем указанный в задании стенд
#Подключаемся к клиентской машине vagrant ssh client и пробуем выполнить команды:

	nsupdate -k /etc/named.zonetransfer.key
	server 192.168.50.10
	zone ddns.lab 
	update add www.ddns.lab. 60 A 192.168.50.15
	send

	
#Получаем ошибку update failed: SERVFAIL
#Для того чтобы решить эту задачу необходимо создать некоторое количество модулей по конкретным ошибкам (потому как решаем одну ошибку SELINUX то появляется другая) на DNS сервере,
#которые описываются в файлах /var/log/audit/audit.log и /var/log/messages, а также для отлавнивания ошибок я использовал systemctl status named, 
#после перезапуска процесса BIND сервера, там также отображаются ошибки.

#Какой алгоритм решил проблему:

#Нам нужно убрать все исключения и ошибки по линии SELINUX, чтобы система безопасности перестала ругаться
#выполняем команду 

	audit2why < /var/log/audit/audit.log и видим:

#Вывод
	
	root@ns01 vagrant]# audit2why < /var/log/audit/audit.log
	type=AVC msg=audit(1587231618.482:1955): avc:  denied  { search } for  pid=7268 comm="isc-worker0000" name="net" dev="proc" ino=33134 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:sysctl_net_t:s0 tclass=dir permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

	type=AVC msg=audit(1587231618.482:1956): avc:  denied  { search } for  pid=7268 comm="isc-worker0000" name="net" dev="proc" ino=33134 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:sysctl_net_t:s0 tclass=dir permissive=0

	Was caused by:
		Missing type enforcement (TE) allow rule.

		You can use audit2allow to generate a loadable module to allow this access.

#Далее выполняем следующие команды

	audit2allow -M named-selinux --debug < /var/log/audit/audit.log 
	semodule -i named-selinux.pp

#Проблема не решена, видим новые ошибки:

	[root@ns01 vagrant]# cat /var/log/messages | grep ausearch
	Feb 11 17:40:20 localhost python: SELinux is preventing /usr/sbin/named from search access on the directory net.#012#012*****  Plugin catchall (100. confidence) suggests   **************************#012#012If you believe that named should be allowed search access on the net directory by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012

#Здесь нужно выполнить команду

	ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000 | semodule -i my-iscworker0000.pp

	
#Проблема так же не решена смотрим дальше что пишет лог /var/log/messages:

	Feb 11 17:45:18 localhost python: SELinux is preventing /usr/sbin/named from read access on the file ip_local_port_range.#012#012*****  Plugin catchall (100. confidence) suggests   **************************#012#012If you believe that named should be allowed read access on the ip_local_port_range file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012


#Здесь у файла DNS сервера нет доступа прочитать файл ip_local_port_range Здесь нужно выполнить команду 

	ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0001 | semodule -i my-iscworker0001.pp


#Это не помогает идем дальше:

	Feb 11 17:46:51 localhost python: SELinux is preventing /usr/sbin/named from open access on the file /proc/sys/net/ipv4/ip_local_port_range.#012#012*****  Plugin catchall (100. confidence) suggests   **************************#012#012If you believe that named should be allowed open access on the ip_local_port_range file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012


#Здесь нужно выполнить команду

	ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0002 | semodule -i my-iscworker0002.pp


#Это нам не помогает идем дальше:

	Feb 11 17:49:29 localhost python: SELinux is preventing /usr/sbin/named from getattr access on the file /proc/sys/net/ipv4/ip_local_port_range.#012#012*****  Plugin catchall (100. confidence) suggests   **************************#012#012If you believe that named should be allowed getattr access on the ip_local_port_range file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012

	
#Здесь нужно выполнить команду
	
	ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0003 | semodule -i my-iscworker0003.pp

#Это нам не помогает, идем дальше:

	Feb 11 17:54:02 localhost python: SELinux is preventing isc-worker0000 from create access on the file named.ddns.lab.view1.jnl.#012#012*****  Plugin catchall_labels (83.8 confidence) suggests   *******************#012#012If you want to allow isc-worker0000 to have create access on the named.ddns.lab.view1.jnl file#012Then you need to change the label on named.ddns.lab.view1.jnl#012Do#012# semanage fcontext -a -t FILE_TYPE 'named.ddns.lab.view1.jnl'#012where FILE_TYPE is one of the following: dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t, named_cache_t, named_log_t, named_tmp_t, named_var_run_t, named_zone_t.#012Then execute:#012restorecon -v 'named.ddns.lab.view1.jnl'#012#012#012*****  Plugin catchall (17.1 confidence) suggests   **************************#012#012If you believe that isc-worker0000 should be allowed create access on the named.ddns.lab.view1.jnl file by default.#012Then you should report this as a bug.#012You can generate a local policy module to allow this access.#012Do#012allow this access for now by executing:#012# ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0000#012# semodule -i my-iscworker0000.pp#012


#Здесь нужно выполнить команду

	ausearch -c 'isc-worker0000' --raw | audit2allow -M my-iscworker0004 | semodule -i my-iscworker0004.pp

#После чего в файле /var/log/messages перестают появляться, но ошибки есть в выводе команды systemctl status named:

	[root@ns01 vagrant]# systemctl status named
	● named.service - Berkeley Internet Name Domain (DNS)
	Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
	Active: active (running) since Sat 2021-02-11 18:02:46 UTC; 4s ago
	Process: 8015 ExecStop=/bin/sh -c /usr/sbin/rndc stop > /dev/null 2>&1 || /bin/kill -TERM $MAINPID (code=exited, status=0/SUCCESS)
	Process: 8028 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} $OPTIONS (code=exited, status=0/SUCCESS)
	Process: 8026 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=0/SUCCESS)
	Main PID: 8031 (named)
	CGroup: /system.slice/named.service
			└─8031 /usr/sbin/named -u named -c /etc/named.conf

	Feb 11 18:02:46 ns01 named[8031]: automatic empty zone: view default: HOME.ARPA
	Feb 11 18:02:46 ns01 named[8031]: none:104: 'max-cache-size 90%' - setting to 211MB (out of 235MB)
	Feb 11 18:02:46 ns01 named[8031]: command channel listening on 192.168.50.10#953
	Feb 11 18:02:46 ns01 named[8031]: managed-keys-zone/view1: journal file is out of date: removing journal file
	Feb 11 18:02:46 ns01 named[8031]: managed-keys-zone/view1: loaded serial 10
	Feb 11 18:02:46 ns01 named[8031]: managed-keys-zone/default: journal file is out of date: removing journal file
	Feb 11 18:02:46 ns01 named[8031]: managed-keys-zone/default: loaded serial 10
	Feb 11 18:02:46 ns01 named[8031]: zone 0.in-addr.arpa/IN/view1: loaded serial 0
	Feb 11 18:02:46 ns01 named[8031]: zone ddns.lab/IN/view1: journal rollforward failed: no more
	Feb 11 18:02:46 ns01 named[8031]: zone ddns.lab/IN/view1: not loaded due to errors.

#Удаляем файл /etc/named/dynamic/named.ddns.lab.view1.jnl, перезапускаем сервис DNS сервера systemctl restart named и больше не видим ошибок, теперь динамическое обновление выполняется успешно.

	[root@ns01 vagrant]# systemctl status named
	● named.service - Berkeley Internet Name Domain (DNS)
	Loaded: loaded (/usr/lib/systemd/system/named.service; enabled; vendor preset: disabled)
	Active: active (running) since Sat 2021-02-11 18:03:44 UTC; 3min 38s ago
	Process: 8057 ExecStop=/bin/sh -c /usr/sbin/rndc stop > /dev/null 2>&1 || /bin/kill -TERM $MAINPID (code=exited, status=0/SUCCESS)
	Process: 8070 ExecStart=/usr/sbin/named -u named -c ${NAMEDCONF} $OPTIONS (code=exited, status=0/SUCCESS)
	Process: 8068 ExecStartPre=/bin/bash -c if [ ! "$DISABLE_ZONE_CHECKING" == "yes" ]; then /usr/sbin/named-checkconf -z "$NAMEDCONF"; else echo "Checking of zone files is disabled"; fi (code=exited, status=0/SUCCESS)
	Main PID: 8072 (named)
	CGroup: /system.slice/named.service
			└─8072 /usr/sbin/named -u named -c /etc/named.conf

	Feb 11 18:03:44 ns01 named[8072]: automatic empty zone: view default: 8.B.D.0.1.0.0.2.IP6.ARPA
	Feb 11 18:03:44 ns01 named[8072]: automatic empty zone: view default: EMPTY.AS112.ARPA
	Feb 11 18:03:44 ns01 named[8072]: automatic empty zone: view default: HOME.ARPA
	Feb 11 18:03:44 ns01 named[8072]: none:104: 'max-cache-size 90%' - setting to 211MB (out of 235MB)
	Feb 11 18:03:44 ns01 named[8072]: command channel listening on 192.168.50.10#953
	Feb 11 18:03:44 ns01 named[8072]: managed-keys-zone/view1: journal file is out of date: removing journal file
	Feb 11 18:03:44 ns01 named[8072]: managed-keys-zone/view1: loaded serial 11
	Feb 11 18:04:30 ns01 named[8072]: client @0x7f61fc09df00 192.168.50.15#26071/key zonetransfer.key: view view1: signer "zonetransfer.key" approved
	Feb 11 18:04:30 ns01 named[8072]: client @0x7f61fc09df00 192.168.50.15#26071/key zonetransfer.key: view view1: updating zone 'ddns.lab/IN': adding an RR at 'www.ddns.lab' A 192.168.50.15
	Feb 11 18:04:36 ns01 named[8072]: client @0x7f61fc09df00 192.168.50.15#26071/key zonetransfer.key: view view1: signer "zonetransfer.key" approved

#Итого по второй части задания:

	Причина неработоспособности механизма обновления заключается в том что Selinux блокировал доступ к обновлению файлов динамического обновления для DNS сервера, 
	а также к некоторым файлам ОС, к которым DNS сервер (/usr/sbin/named) обращается во время своей работы (указаны выше, взяты из логов сервера). 
	Кроме того рекомендуется удалить файл с расширением .jnl (или прописать контекст безопасности), куда записываются динамические обновления зоны. 
	Так как прежде чем данные попадают в .jnl файл, они сначала записываются во временный файл tmp, для которого может срабатывать блокировка (как в моем случае), поэтому tmp файлы также рекомендуется или удалить или прописать им контекст безопасности. 
	Временные файлы можно найти:

	[root@ns01 vagrant]# ls -l /etc/named/dynamic/
	total 32
	-rw-rw-rw-. 1 named named 509 Apr 18 17:40 named.ddns.lab
	-rw-rw-rw-. 1 named named 509 Apr 18 17:40 named.ddns.lab.view1
	-rw-r--r--. 1 named named 700 Apr 18 18:04 named.ddns.lab.view1.jnl
	-rw-r--r--. 1 named named 348 Apr 18 18:30 tmp-6OGP6YASy1
	-rw-r--r--. 1 named named 348 Apr 18 18:44 tmp-HUsH1RRHBF
	-rw-r--r--. 1 named named 348 Apr 18 18:17 tmp-OEmMkfw6J6
	-rw-r--r--. 1 named named 348 Apr 18 19:09 tmp-R8cPmFCasl
	-rw-r--r--. 1 named named 348 Apr 18 18:57 tmp-csgM4QDJR7

	Считаю что можно использовать или компиляцию модулей SELINUX или изменения контекста безопасности для файлов SELINUX (просмотр контекста на файлах и директорияхls -lZ), к которым обращается BIND, оба эти способа специально предназначены разработчиками Selinux для того чтобы решать подобные проблемы.

#Кроме данных способов существуют также способы:

	1)Выключить Selinux совсем (не рекомендуется)
	2)Изменить контекст тех файлов, к которым DNS серверу затруднен доступ командам semanage fcontext -a -t FILE_TYPE named.ddns.lab.view1.jnl, 
	где назначить файлам один из следующих типов контекста безопасности dnssec_trigger_var_run_t, ipa_var_lib_t, krb5_host_rcache_t, krb5_keytab_t, named_cache_t, named_log_t, named_tmp_t, named_var_run_t, named_zone_t, 
	и затем выполнить запись контекста в ядро restorecon -v named.ddns.lab.view1.jnl. 
	В данном случае приведены примеры для файла named.ddns.lab.view1.jnl, в данный файл DNS сервер записывает динамические обновления от DNS клиентов.
	


	






























