#Скачиваем Vagrantfile и подключаемся к виртуальной машине
	
	vagrant up
	vagrant ssh
	
#Все действия будем выполнять из-под root

	sudo -i
	
#Устанавливаем wget

	yum install -y wget.x86_64
	
#Устанавливаем дополнительные модули

	dnf install http://download.zfsonlinux.org/epel/zfs-release.el8_2.noarch.rpm
	gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
	
#Вывод
	
	pub   rsa2048 2013-03-21 [SC]
	uid           ZFS on Linux <zfs@zfsonlinux.org>
	sub   rsa2048 2013-03-21 [E]
	
#Установка DKMS
	
	dnf install epel-release
    dnf install kernel-devel zfs
	
#KABI-трекинг kmod

	dnf config-manager --disable zfs
    dnf config-manager --enable zfs-kmod
    dnf install zfs
	
#Создаем и настраиваем zfs.conf

	vi /etc/modules-load.d/zfs.conf
	sh -c "echo zfs >/etc/modules-load.d/zfs.conf"
	
#Тестирование репозиториев

	dnf config-manager --enable zfs-testing
	dnf install kernel-devel zfs
	yum update
	
#Вывод версий
	
	dkms status
	
	zfs, 0.8.5: added
	zfs, 2.0.0, 4.18.0-240.1.1.el8_3.x86_64, x86_64: installed
	
#Смотрим диски и создаем общее

	fdisk -l
	zpool create poolmirror mirror sdb sdc sdd
	
#Делим на 6 дисков и проверяем

	echo disk{1..6} | xargs -n 1 fallocate -l 100M
	ls -l disk*
	
#Вывод

	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk1
	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk2
	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk3
	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk4
	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk5
	-rw-r--r--. 1 root root 104857600 Dec 10 01:22 disk6
	
#Используемые для работы и помощи команды

	zpool list -просмотр
	zfs unmount myzfs/bob - отмонтирование файловой сиситемы
	zfs destroy myzfs/colin2  - ничтожить выбранную файловую систему.
	zpool destroy -f myzfs - удаление с директориями
	zpool destroy myzfs - удаление
	zpool status -v - статус
	
#Задание 1 ------------------------------

#Обьединяю три диска и проверяю
	
	zpool create raid raidz1 $PWD/disk[1-3] 
	zpool list
	
#Вывод	
	NAME   SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
	raid   256M   217K   256M        -         -     0%     0%  1.00x    ONLINE  -
	
#Создаем файловые системы и проверяем что создались
	
	zfs create raid/1
    zfs create raid/2
    zfs create raid/3
    zfs create raid/4
    zfs create raid/5
    zfs create raid/6
	
	ls -l /raid/

#Вывод
	
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 1
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 2
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 3
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 4
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 5
	drwxr-xr-x. 2 root root 2 Dec 10 01:35 6
	
#Сжатия которые поддерживаются

	lzjb | gzip | gzip- [1-9] | zle | lz4 | zstd | zstd- [1-19] | zstd-fast- [1-10,20,30,40,50,60,70,80,90,100,500,1000] 
	
#Для каждой ФС применяем своё сжатие

	zfs set compression=gzip raid/1
    zfs set compression=gzip-9 raid/2
    zfs set compression=zle raid/3
    zfs set compression=lzjb raid/4
    zfs set compression=lz4 raid/5
    zfs set compression=zstd raid/6
	
#Проверяем какие ФС с каким сжатием
	
	zfs get compression,compressratio
	
#Вывод

	NAME    PROPERTY       VALUE           SOURCE
	raid    compression    off             default
	raid    compressratio  1.00x           -
	raid/1  compression    gzip            local
	raid/1  compressratio  1.00x           -
	raid/2  compression    gzip-9          local
	raid/2  compressratio  1.00x           -
	raid/3  compression    zle             local
	raid/3  compressratio  1.00x           -
	raid/4  compression    lzjb            local
	raid/4  compressratio  1.00x           -
	raid/5  compression    lz4             local
	raid/5  compressratio  1.00x           -
	raid/6  compression    zstd            local
	raid/6  compressratio  1.00x           -
	
#Копируем один и тот же файл в ФС с разным сжатием

	cd /raid/1/
    wget -O War_and_Peace1.txt http://www.gutenberg.org/files/2600/2600-0.txt
    
	cd /raid/2/
    wget -O War_and_Peace2.txt http://www.gutenberg.org/files/2600/2600-0.txt
    
	cd /raid/3/
    wget -O War_and_Peace3.txt http://www.gutenberg.org/files/2600/2600-0.txt
    
	cd /raid/4/
    wget -O War_and_Peace4.txt http://www.gutenberg.org/files/2600/2600-0.txt
    
	cd /raid/5/
    wget -O War_and_Peace5.txt http://www.gutenberg.org/files/2600/2600-0.txt
    
	cd /raid/6/
    wget -O War_and_Peace6.txt http://www.gutenberg.org/files/2600/2600-0.txt
	
#Повторно проверяем какие ФС с каким сжатием и видим его степень

	zfs get compression,compressratio
	
#Вывод
	
	NAME    PROPERTY       VALUE           SOURCE
	raid    compression    off             default
	raid    compressratio  1.72x           -
	raid/1  compression    gzip            local
	raid/1  compressratio  2.67x           -
	raid/2  compression    gzip-9          local
	raid/2  compressratio  2.67x           -
	raid/3  compression    zle             local
	raid/3  compressratio  1.01x           -
	raid/4  compression    lzjb            local
	raid/4  compressratio  1.36x           -
	raid/5  compression    lz4             local
	raid/5  compressratio  1.62x           -
	raid/6  compression    zstd            local
	raid/6  compressratio  2.59x           -

	
#Задание 2 ------------------------------

#Скачиваем файл для задания по ссылке, переходим в каталог с архивом и распаковываем

	https://drive.google.com/open?id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
	cd /home/
	tar -xvf zfs_task1.tar.gz
	
#Восстанавливаем образ 

	zpool import -d zpoolexport/
	
#Вывод

	         pool: otus
           id: 6554193320433390805
        state: ONLINE
      status: Some supported features are not enabled on the pool.
       action: The pool can be imported using its name or numeric identifier, though
              some features will not be available without an explicit 'zpool upgrade'.
       config:

              otus                         ONLINE
                mirror-0                   ONLINE
                  /home/zpoolexport/filea  ONLINE
                  /home/zpoolexport/fileb  ONLINE
	
#Дописываем в конце имя pool

	zpool import -d ${PWD}/zpoolexport/ otus
	
#Проверяем статус

	zpool status
	
#Вывод

	   pool: otus
	 state: ONLINE
	status: Some supported features are not enabled on the pool. The pool can
			still be used, but some features are unavailable.
	action: Enable all features using 'zpool upgrade'. Once this is done,
			the pool may no longer be accessible by software that does not support
			the features. See zpool-features(5) for details.
	config:
	
			NAME                         STATE     READ WRITE CKSUM
			otus                         ONLINE       0     0     0
			  mirror-0                   ONLINE       0     0     0
				/home/zpoolexport/filea  ONLINE       0     0     0
				/home/zpoolexport/fileb  ONLINE       0     0     0

#Просмотр информации

	zfs get all
	
#Вывод	
	
	NAME            PROPERTY              VALUE                  SOURCE
	otus            type                  filesystem             -
	otus            creation              Fri May 15  4:00 2020  -
	otus            used                  2.04M                  -
	otus            available             350M                   -
	otus            referenced            24K                    -
	otus            compressratio         1.00x                  -
	otus            mounted               yes                    -
	otus            quota                 none                   default
	otus            reservation           none                   default
	otus            recordsize            128K                   local
	otus            mountpoint            /otus                  default
	otus            sharenfs              off                    default
	otus            checksum              sha256                 local
	otus            compression           zle                    local
	otus            atime                 on                     default
	otus            devices               on                     default
	otus            exec                  on                     default
	otus            setuid                on                     default
	otus            readonly              off                    default
	otus            zoned                 off                    default
	otus            snapdir               hidden                 default
	otus            aclmode               discard                default
	otus            aclinherit            restricted             default
	otus            createtxg             1                      -
	otus            canmount              on                     default
	otus            xattr                 on                     default
	otus            copies                1                      default
	otus            version               5                      -
	otus            utf8only              off                    -
	otus            normalization         none                   -
	otus            casesensitivity       sensitive              -
	otus            vscan                 off                    default
	otus            nbmand                off                    default
	otus            sharesmb              off                    default
	otus            refquota              none                   default
	otus            refreservation        none                   default
	otus            guid                  14592242904030363272   -
	otus            primarycache          all                    default
	otus            secondarycache        all                    default
	otus            usedbysnapshots       0B                     -
	otus            usedbydataset         24K                    -
	otus            usedbychildren        2.01M                  -
	otus            usedbyrefreservation  0B                     -
	otus            logbias               latency                default
	otus            objsetid              54                     -
	otus            dedup                 off                    default
	otus            mlslabel              none                   default
	otus            sync                  standard               default
	otus            dnodesize             legacy                 default
	otus            refcompressratio      1.00x                  -
	otus            written               24K                    -
	otus            logicalused           1020K                  -
	otus            logicalreferenced     12K                    -
	otus            volmode               default                default
	otus            filesystem_limit      none                   default
	otus            snapshot_limit        none                   default
	otus            filesystem_count      none                   default
	otus            snapshot_count        none                   default
	otus            snapdev               hidden                 default
	otus            acltype               off                    default
	otus            context               none                   default
	otus            fscontext             none                   default
	otus            defcontext            none                   default
	otus            rootcontext           none                   default
	otus            relatime              off                    default
	otus            redundant_metadata    all                    default
	otus            overlay               on                     default
	otus            encryption            off                    default
	otus            keylocation           none                   default
	otus            keyformat             none                   default
	otus            pbkdf2iters           0                      default
	otus            special_small_blocks  0                      default
	otus/hometask2  type                  filesystem             -
	otus/hometask2  creation              Fri May 15  4:18 2020  -
	otus/hometask2  used                  1.88M                  -
	otus/hometask2  available             350M                   -
	otus/hometask2  referenced            1.88M                  -
	otus/hometask2  compressratio         1.00x                  -
	otus/hometask2  mounted               yes                    -
	otus/hometask2  quota                 none                   default
	otus/hometask2  reservation           none                   default
	otus/hometask2  recordsize            128K                   inherited from otus
	otus/hometask2  mountpoint            /otus/hometask2        default
	otus/hometask2  sharenfs              off                    default
	otus/hometask2  checksum              sha256                 inherited from otus
	otus/hometask2  compression           zle                    inherited from otus
	otus/hometask2  atime                 on                     default
	otus/hometask2  devices               on                     default
	otus/hometask2  exec                  on                     default
	otus/hometask2  setuid                on                     default
	otus/hometask2  readonly              off                    default
	otus/hometask2  zoned                 off                    default
	otus/hometask2  snapdir               hidden                 default
	otus/hometask2  aclmode               discard                default
	otus/hometask2  aclinherit            restricted             default
	otus/hometask2  createtxg             216                    -
	otus/hometask2  canmount              on                     default
	otus/hometask2  xattr                 on                     default
	otus/hometask2  copies                1                      default
	otus/hometask2  version               5                      -
	otus/hometask2  utf8only              off                    -
	otus/hometask2  normalization         none                   -
	otus/hometask2  casesensitivity       sensitive              -
	otus/hometask2  vscan                 off                    default
	otus/hometask2  nbmand                off                    default
	otus/hometask2  sharesmb              off                    default
	otus/hometask2  refquota              none                   default
	otus/hometask2  refreservation        none                   default
	otus/hometask2  guid                  3809416093691379248    -
	otus/hometask2  primarycache          all                    default
	otus/hometask2  secondarycache        all                    default
	otus/hometask2  usedbysnapshots       0B                     -
	otus/hometask2  usedbydataset         1.88M                  -
	otus/hometask2  usedbychildren        0B                     -
	otus/hometask2  usedbyrefreservation  0B                     -
	otus/hometask2  logbias               latency                default
	otus/hometask2  objsetid              81                     -
	otus/hometask2  dedup                 off                    default
	otus/hometask2  mlslabel              none                   default
	otus/hometask2  sync                  standard               default
	otus/hometask2  dnodesize             legacy                 default
	otus/hometask2  refcompressratio      1.00x                  -
	otus/hometask2  written               1.88M                  -
	otus/hometask2  logicalused           963K                   -
	otus/hometask2  logicalreferenced     963K                   -
	otus/hometask2  volmode               default                default
	otus/hometask2  filesystem_limit      none                   default
	otus/hometask2  snapshot_limit        none                   default
	otus/hometask2  filesystem_count      none                   default
	otus/hometask2  snapshot_count        none                   default
	otus/hometask2  snapdev               hidden                 default
	otus/hometask2  acltype               off                    default
	otus/hometask2  context               none                   default
	otus/hometask2  fscontext             none                   default
	otus/hometask2  defcontext            none                   default
	otus/hometask2  rootcontext           none                   default
	otus/hometask2  relatime              off                    default
	otus/hometask2  redundant_metadata    all                    default
	otus/hometask2  overlay               on                     default
	otus/hometask2  encryption            off                    default
	otus/hometask2  keylocation           none                   default
	otus/hometask2  keyformat             none                   default
	otus/hometask2  pbkdf2iters           0                      default
	otus/hometask2  special_small_blocks  0                      default
	
#Задание 3 ------------------------------

#Скачиваем файл по ссылке
	
	https://drive.google.com/file/d/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG/view?usp=sharing 
	
	otus_task2.file
	
#Создаем ФС
	
	zfs create otus/1
	
#Восстанавливаем Snapshot 

	zfs receive -F otus/1 < otus_task2.file
	
#Зашифрованное сообщение в файле 
	
	vi /otus/1/task1/file_mess/secret_message
	
#Зашифрованное сообщение

	https://github.com/sindresorhus/awesome

	
	
	
	
	
	
	
	
	
	
	
