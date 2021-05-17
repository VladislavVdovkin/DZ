# openvpn

 
1) TUN (сетевой туннель) работает на сетевом уровне модели OSI, оперируя IP пакетами. TAP используется для создания сетевого моста, тогда как TUN для маршрутизации.

Чтобы поверить tun необходимо выполнить команду:
        
            vagrant up office1Router
            vagrant up office1Server
            
            
 Чтобы проверить tap необходимо выполнить команду:
   
            vagrant up office2Router
            vagrant up office2Server

2) Для RAS запустите скрипт на хостовой машине.




3)  ИЗМЕРЕНИЕ СКОРОСТИ ДЛЯ tap И tun

tap

------------------------------------------------------------
       Client connecting to 10.10.10.1, TCP port 5001
       TCP window size: 94.5 KByte (default)
------------------------------------------------------------
       [  5] local 10.10.10.2 port 51678 connected with 10.10.10.1 port 5001
       [  3] local 10.10.10.2 port 51674 connected with 10.10.10.1 port 5001
       [  4] local 10.10.10.2 port 51676 connected with 10.10.10.1 port 5001
       [ ID] Interval       Transfer     Bandwidth
       [  3]  0.0-34.3 sec  4.88 MBytes  1.19 Mbits/sec
       [  5]  0.0-36.3 sec  4.62 MBytes  1.07 Mbits/sec
       [  4]  0.0-40.5 sec  6.00 MBytes  1.24 Mbits/sec
       [SUM]  0.0-40.5 sec  15.5 MBytes  3.21 Mbits/sec
     


tun

------------------------------------------------------------
       Client connecting to 10.10.10.1, TCP port 5001
       TCP window size: 94.5 KByte (default)
------------------------------------------------------------
       [  5] local 10.10.10.2 port 51690 connected with 10.10.10.1 port 5001
       [  3] local 10.10.10.2 port 51686 connected with 10.10.10.1 port 5001
       [  4] local 10.10.10.2 port 51688 connected with 10.10.10.1 port 5001
       [ ID] Interval       Transfer     Bandwidth
       [  5]  0.0-35.0 sec  7.38 MBytes  1.77 Mbits/sec
       [  3]  0.0-37.0 sec  6.38 MBytes  1.45 Mbits/sec
       [  4]  0.0-41.1 sec  2.75 MBytes   561 Kbits/sec
       [SUM]  0.0-41.1 sec  16.5 MBytes  3.37 Mbits/sec

