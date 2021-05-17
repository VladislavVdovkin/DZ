# ospf

vagrant up

При запуске Vagrant файла, поднимаются 3 роутера.

Таблица маршрутизации на R1:

    K>* 0.0.0.0/0 via 10.0.2.2, eth0
    C>* 10.0.2.0/24 is directly connected, eth0
    O   10.100.1.0/24 [110/10] is directly connected, eth1, 00:06:14
    C>* 10.100.1.0/24 is directly connected, eth1
    O   10.100.2.0/24 [110/30] via 10.100.1.2, eth1, 00:06:07
    C>* 10.100.2.0/24 is directly connected, eth2
    O>* 10.100.3.0/24 [110/20] via 10.100.1.2, eth1, 00:06:07
    C>* 127.0.0.0/8 is directly connected, lo
Таблица маршрутизации на R2:

    K>* 0.0.0.0/0 via 10.0.2.2, eth0
    C>* 10.0.2.0/24 is directly connected, eth0
    O   10.100.1.0/24 [110/20] is directly connected, eth1, 00:02:10
    C>* 10.100.1.0/24 is directly connected, eth1
    O   10.100.2.0/24 [110/20] via 10.100.3.1, eth2, 00:01:55
    S>* 10.100.2.0/24 [1/0] via 10.100.1.1, eth1
    O   10.100.3.0/24 [110/10] is directly connected, eth2, 00:02:10
    C>* 10.100.3.0/24 is directly connected, eth2
    C>* 127.0.0.0/8 is directly connected, lo
Таблица маршрутизации на R3:

    K>* 0.0.0.0/0 via 10.0.2.2, eth0
    C>* 10.0.2.0/24 is directly connected, eth0
    O>* 10.100.1.0/24 [110/20] via 10.100.2.1, eth1, 00:06:20
    O   10.100.2.0/24 [110/10] is directly connected, eth1, 00:06:50
    C>* 10.100.2.0/24 is directly connected, eth1
    O   10.100.3.0/24 [110/30] via 10.100.2.1, eth1, 00:06:20
    C>* 10.100.3.0/24 is directly connected, eth2
    C>* 127.0.0.0/8 is directly connected, lo

На маршрутизаторах office1Router & office2Route роутером по умолчанию является centralRouter, остальные маршруты прописывать нет необходимости т.к. о них знает centralRouter

Трафик от R1 до R3 (192.168.3.1) идет через R2 и возвращается напрямую от R3:

                [root@R1 quagga]# ping 10.100.3.1

                [root@R1 quagga]# ping 10.100.3.1
                PING 10.100.3.1 (10.100.3.1) 56(84) bytes of data.
                64 bytes from 10.100.3.1: icmp_seq=1 ttl=64 time=1.00 ms
                64 bytes from 10.100.3.1: icmp_seq=2 ttl=64 time=0.392 ms
                64 bytes from 10.100.3.1: icmp_seq=3 ttl=64 time=0.759 ms

                [root@R3 quagga]# tcpdump -ieth1
                listening on eth1, link-type EN10MB (Ethernet), capture size 262144 bytes
                11:40:01.682738 IP R3 > 10.100.1.1: ICMP echo reply, id 4269, seq 11, length 64
                11:40:02.682516 IP R3 > 10.100.1.1: ICMP echo reply, id 4269, seq 12, length 64
                11:40:03.682439 IP R3 > 10.100.1.1: ICMP echo reply, id 4269, seq 13, length 64

                [root@R3 quagga]# tcpdump -ieth2
                listening on eth2, link-type EN10MB (Ethernet), capture size 262144 bytes
                11:40:06.685272 IP 10.100.1.1 > R3: ICMP echo request, id 4269, seq 16, length 64
                11:40:07.685659 IP 10.100.1.1 > R3: ICMP echo request, id 4269, seq 17, length 64
                11:40:08.685416 IP 10.100.1.1 > R3: ICMP echo request, id 4269, seq 18, length 64
Трафик от R2 до сети 10.100.2.0 ходит через R1 несмотря на более дорогой маршрут

                [root@R2 etc]# tracepath -n 10.100.2.2
                1?: [LOCALHOST]                                         pmtu 1500
                1:  10.100.1.1                                            3.534ms
                1:  10.100.1.1                                            0.815ms
                2:  10.100.2.2                                            0.679ms reached
                    Resume: pmtu 1500 hops 2 back 2
                hostname R2
                !
                log file /var/log/ospfd.log
                !
                !
                interface eth1
                ! net 10.100.1.0
                ip ospf mtu-ignore
                ip ospf cost 20
                ip ospf network point-to-point
                ip ospf hello-interval 5
                ip ospf dead-interval 10
                !
                interface eth2
                ! net 10.100.3.0
                ip ospf mtu-ignore
                ip ospf network point-to-point
                ip ospf hello-interval 5
                ip ospf dead-interval 10
                !
                router ospf
                ospf router-id 10.100.1.2
                network 10.100.1.0/24 area 0
                network 10.100.3.0/24 area 0
                !
                line vty

