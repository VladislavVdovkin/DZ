
#cтруктура файлов и папок роли:

           
           ├── ansible.cfg
           ├── hosts
           ├── playbook
           │   └── web.yml
           ├── Readme.md
           ├── roles
           │   └── nginx
           │       ├── defaults
           │       │   └── main.yml
           │       ├── files
           │       ├── handlers
           │       │   └── main.yml
           │       ├── meta
           │       │   └── main.yml
           │       ├── README.md
           │       ├── tasks
           │       │   ├── main.yml
           │       │   └── redhat.yml
           │       ├── templates
           │       │   ├── index.html.j2
           │       │   └── nginx.conf.j2
           │       ├── tests
           │       │   ├── inventory
           │       │   └── test.yml
           │       └── vars
           │           └── main.yml
           └── vagrantfile


#создаем роль c помощью команды, эта команда создаст нам структуру папок и файлов для работы.

           ansible-galaxy init roles/nginx


#Запуск производиться следующим образом:

           ansible-playbook playbook/web.yml


#После запуска этого файла, вызывается файл:

           /roles/nginx/tasks/main.yml


#Файл ansible.cfg должен лежать с vagrantfile в одной директории.


#Также можно удалять установленную программу nginx:

           ansible -m yum -a "name=nginx state=absent" -b



#Для запуска выполнить:

            vagrant up



