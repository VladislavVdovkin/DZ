
## Сетевые пакеты. VLAN'ы. LACP.
-------------
Vagrantfile для задания: [Vagrantfile](./Vagrantfile)
### Развести вланами:

            testClient1 <-> testServer1

            testClient2 <-> testServer2

#В общую сеть были добавлены 4 хоста. Общая карта сети доступна [здесь](https://github.com/VladislavVdovkin/DZ/blob/master/Lesson_VLANs/full-map.png).

Схема для задания:
<a href="https://github.com/VladislavVdovkin/DZ/Lesson_VLANs/blob/master/vlan.png" rel="Click!">![map](./vlan.png)</a>

Доступ к хостам для проверки можно получить через:

            vagrant ssh testServer1
            vagrant ssh testClient1
            vagrant ssh testServer2
            vagrant ssh testClient2


#Между centralRouter и inetRouter "пробросить" 2 линка (2 internal сети) и объединить их в бонд актив-актив, 
#проверить работу если выборать интерфейсы в бонде по очереди.

#Настроить работу бонде получилось только при условии, что оба линка находились в одной internal сети (virtualbox).
#При разбиение на две сети и при тестировании бонда, связь теряется.
#Пробовал разные варианты бонда, но аналогичное поведение наблюдается на всех. 
#Остановился на 
 
            mode=1 (active-backup)

#Есть подозрение, что нужно копать глубже в сети virtualbox. 
#Если же это явная ошибка, то прошу подсказать, как можно было настроить бонд, что бы удовлетворить условию задания.

Схема для задания:

<a href="https://github.com/VladislavVdovkin/DZ/Lesson_VLANs/blob/master/bonding.png" rel="Click!">![map](./bonding.png)</a>

Доступ к хостам для проверки можно получить через:

            vagrant ssh inetRouter

            vagrant ssh centralRouter
