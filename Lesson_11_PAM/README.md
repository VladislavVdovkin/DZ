

#скачиваем Vagrantfile и подключаемся

           vagrant up
		   vagrant ssh



#Все дальнейшие действия будем выполнять из под root

           sudo -i

#Задание 1
		   
#добавляем/создаём пользователей ( first, second )

           useradd first
           useradd second

#задаём им пароли

           passwd first
           passwd second

#cоздать группу admin 

            groupadd admin

#включаем пользователей в группу - admin

            usermod -aG admin first
            usermod -aG admin second
            usermod -aG admin root


#с помощью команды id - проверяем группы у пользователей. 1002(admin) - отображается у каждого пользователя

            id first

            uid=1002(first) gid=1003(first) groups=1003(first),1002(admin)

            id second

            uid=1003(second) gid=1004(second) groups=1004(second),1002(admin)

            id root

            uid=0(root) gid=0(root) groups=0(root),1002(admin)

#запретить всем пользователям, кроме группы admin, логин в систему по SSH в выходные дни (суббота и воскресенье) без учета праздников.



#установим PAM

            yum install -y pam*
            yum install -y libpam*


#создание скрипта

            touch /etc/script

            nano /etc/script

#вывод

            #!/bin/bash
            script="$1"
            shift

            if groups $PAM_USER | grep admin > /dev/null
            then
                    exit 0
            else
                    if [[ $(date +%u) -lt 6 ]]
                    then
                            exit 0
                    else
                            exit 1
                    fi
            fi
            
            if [ ! -e "$script" ]
            then
                    exit 0
            fi

#исполнение

            chmod +x /etc/script

#добавляем запись в файл /etc/pam.d/sshd

            nano /etc/pam.d/sshd

#добовляемая строка

            account    required     /etc/script.so

#Задание 2

#установливаем docker

            yum install -y docker*

#даём конкретному пользователю право работать с docker

            usermod -aG docker first

