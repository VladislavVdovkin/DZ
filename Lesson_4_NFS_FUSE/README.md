1.Необходимо скопировать данную дирректорию с Vagrantfile и scripts
2.Выполнить vagrant up
3.Vagrantfile разворачивает 2 виртуальные машины (nfs-server, nfs-client)
4.В секции provision scripts указан пусть до скриптов выполняемых каждой виртуальной машиной.
5.Для nfs-server добавлен 2-server.sh скрипт который устанавливает необходимые пакеты и разворачивает 
   nfs сервер(в скрипте оставлены коментарии по каждому шагу).
6.Для nfs-client добавлен 2-client.sh скрипт который устанавливает необходимые пакеты и выполняет действия для 
  клиентской части (в скрипте оставлены коментарии по каждому шагу).