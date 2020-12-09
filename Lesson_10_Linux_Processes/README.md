#Скачиваем Vagrantfile и подключаемся к нему
	vagrant up
	vagrant ssh

#В репозитории два скрипта: 
#taskone.sh - реализация ps ax через /proc
#taskfive.sh - запуск двух процессов с разными nice
#Вывод taskfive
	1048576+0 records in
	1048576+0 records out
	2097152000 bytes (2.1 GB) copied, 58.9125 s, 35.6 MB/s
	./nice.sh
	real    0m59.228s
	user    0m0.613s
	sys     0m31.924s
	1048576+0 records in
	1048576+0 records out
	2097152000 bytes (2.1 GB) copied, 15.4151 s, 136 MB/s

	real    0m19.661s
	user    0m0.793s
	sys     0m11.516s
	
	