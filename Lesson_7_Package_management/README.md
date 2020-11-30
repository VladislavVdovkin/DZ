#Cкачиваем Vagrantfile, запускаем и подключаемся
	vagrant up
	vagrant ssh

#Установка всех пакетов и зависисмостей произойдет про поднятии Vagrantfile с помощью provision shell	
#Последующие действия будем выполнять из под root
	sudo -i
	

#Загрузим SRPM пакет NGINX для дальнейшей работы над ним
	wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.14.1-1.el7_4.ngx.src.rpm
	
#В домашней директории создается древо каталогов для сборки	
	rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm
	
#Скачиваем последние исходники openssl
	wget https://www.openssl.org/source/latest.tar.gz

#Разархивируем
	tar -xvf latest.tar.gz

#Редактируем spec файл
		vi rpmbuild/SPECS/nginx.spec
		
#Вывод секции build
		
	%build
./configure %{BASE_CONFIGURE_ARGS} \
    --with-cc-opt="%{WITH_CC_OPT}" \
    --with-ld-opt="%{WITH_LD_OPT}" \
    --with-openssl=/root/openssl-1.1.1h
make %{?_smp_mflags}

#Сборка RPM пакета
	rpmbuild -bb rpmbuild/SPECS/nginx.spec
	
#Убедимся что пакеты создались	
	ll rpmbuild/RPMS/x86_64/
	
#Установим наш пакет и убедимся что nginx работает
	yum localinstall -y \ 
	rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
	systemctl start nginx
	systemctl status nginx
	
#Создадим каталог для своего репозитория 
	 mkdir /usr/share/nginx/html/repo
	 
#Копируем туда наш созданый RPM для установки Percona-server
	 cp rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
	 wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-9/redhat/percona-release-1.0-9.noarch.rpm -O /usr/share/nginx/html/repo/percona-release-1.0-9.noarch.rpm

#Инициализируем репозиторий
	createrepo /usr/share/nginx/html/repo/
	
#Правим файл  /etc/nginx/conf.d/default.conf
#В секцию location прописываем  autoindex on
    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        autoindex on;
    }

#Проверяем синтаксис и перезапускаем nginx
	nginx -t
	nginx -s reload
	
#curl-анем репозиторий
	curl -a http://localhost/repo/

#Вывод curl
	<html>
<head><title>Index of /repo/</title></head>
<body bgcolor="white">
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          30-Nov-2020 05:14                   -
<a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>                30-Nov-2020 05:11             2003316
<a href="percona-release-1.0-9.noarch.rpm">percona-release-1.0-9.noarch.rpm</a>                   11-Nov-2020 21:49               16664
</pre><hr></body>
</html>

#Добавим его в /etc/yum.repos.d
	cat >> /etc/yum.repos.d/otus.repo << EOF
	[otus]
	name=otus-linux
	baseurl=http://localhost/repo
	gpgcheck=0
	enabled=1
	EOF
	
#Убедимся что репозиторий подключен и посмотрим что в нем есть
	yum repolist enabled | grep otus
	yum list | grep otus
	
#Установим репозиторий percona-release-1
	yum install percona-release -y	