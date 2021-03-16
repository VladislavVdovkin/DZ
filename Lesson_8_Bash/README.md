

#скачиваем Vagrantfile и запускаем, и подключаемся

          vagrant up
	      vagrant ssh

#все дальнейшие действия будем выполнять из под root


           sudo -i



#далее заходим в директорию /var/log/nginx/ и создаем там 3 скрипта 0pochta.sh pochta.sh skripts.sh

          cd /var/log/nginx/


          touch 0pochta.sh


          #!/bin/bash

          LOCKFILE=/var/log/nginx/pochta.sh
          #LOCKFILE=/var/log/x
          if [ -f $LOCKFILE ]
          then
          echo "Lockfile active, no new runs."
          exit 1 
          else
          echo "PID: $$" > $LOCKFILE
          trap 'rm -f $LOCKFILE"; exit $?' INT TERM EXIT
          echo "Simulate some activity..."
          rm -f $LOCKFILE
          trap - INT TERM EXIT
          fi



          touch pochta.sh


          #!/bin/bash
         if
         find / -name skripts.sh -exec {} \; > otchet.txt &&
         mailx root@localhost < otchet.txt

         then
         exit 0
         else 
         echo "file not found"
         fi

      
       
          touch skripts.sh


          #!/bin/bash
          echo "Временной диапазон":
          cat /var/log/nginx/access.log | awk '{print $4}' | head -n 1 &&  date | awk '{print $2,$3,$4,$6}' &&

          #1
          echo "Топ-10 клиентских URL запрашиваемых с этого сервера"
          cat /var/log/nginx/access.log | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 10 > 1.1.txt && cat 1.1.txt &&
          echo "------------------------------------------------------" 
          #2
          echo "Топ-10 клиентских IP"
          cat /var/log/nginx/access.log | awk '{print $1}' | sort | uniq -c | sort -rn | head -n 10 > 2.2.txt && tail -n 10 2.2.txt &&
          echo "------------------------------------------------------"
          #3
          echo "Все коды состояния HTTP и их количество"
          cat /var/log/nginx/access.log | awk '{print $9}'| grep -v "-" | sort | uniq -c | sort -rn > 3.3.txt && cat 3.3.txt && 
          echo "------------------------------------------------------" 
          #4
          echo "Все коды состояния  4xx и 5xx"
          cat /var/log/nginx/access.log | awk '{print $9}' | grep ^4 > 4.4.txt && cat /var/log/nginx/access.log | awk '{print $9}'  | grep ^5 >> 4.4.txt && cat 4.4.txt | uniq -d -c | sort -rn > 4.5.txt && cat 4.5.txt &&
          echo "------------------------------------------------------"
          echo "all"
          rm -f 1.1.txt 2.2.txt 3.3.txt 4.4.txt 4.5.txt



#делаем скрипты исполняемыми 

          chmod +x /var/log/nginx/0pochta.sh

          chmod +x /var/log/nginx/pochta.sh

          chmod +x /var/log/nginx/skripts.sh


#даем выполнения каждые пять минут 0pochta.sh каждый час pochta.sh

          crontab -e

          */5 * * * * /var/log/nginx/0pochta.sh

          0 * * * * /var/log/nginx/pochta.sh

#проверка почты

          nano /var/spool/mail/root

















