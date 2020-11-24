	# Скачиваем Vagrantfile и запускаем
			vagrant up

1.Попасть в систему без пароля несколькими способами
	---------------------------------------------------------------------------------------------------------
	# Заходим в GUI VBox
	# В момент загрузки системы нажимаем кнопку "е"(edit) для изменения парамента загрузки
	# Находим строчку начинающуюся с linux16, убираем параметры: console=tty0 console=ttyS0,115200n8
	# В этой же строке добавляем в конце init=/bin/sh
	# Нажимаем Ctrl+X для загрузки системы

	# Перемонтируем коррень в режиме Read-Write
			mount -o remount,rw /

	# Создал тестовый файл в дирректории /home
			touch /home/test.txt

	# Записал в созданый файл данные и проверил 
			echo "otus test" >> /home/test.txt
			cat /home/test.txt

	# Задаем новый пароль 
			passwd

	# Правим selinux, в файле /etc/selinux/config правим SELINUX=enforcing на SELINUX=disabled
			vi /etc/selinux/config 
			:wq

			#Перезагружаем систему и входим под новым паролем

	-------------------------------------------------------------------------------------------------------
	# Заходим в GUI VBox
	# В момент загрузки системы нажимаем кнопку "е"(edit) для изменения парамента загрузки
	# Находим строчку начинающуюся с linux16, убираем параметры: console=tty0 console=ttyS0,115200n8
	# В этой же строке добавляем в конце rd.break
	# Нажимаем Ctrl+X для загрузки системы
	# Система загрузилась в аварийном режиме

	# Перемонтируем коррень в режиме Read-Write
			mount -o remount,rw /sysroot
			chroot /sysroot

	# Правим selinux, в файле /etc/selinux/config правим SELINUX=enforcing на SELINUX=disabled
			vi /etc/selinux/config 
			i
			:wq

	# Задаем новый пароль
			passwd root

	# Создаем скрытый файл
			touch /.autorelabel

	#Перезагружаем систему и входим под новым паролем
	------------------------------------------------------------------------------------------------------

2.Установить систему с LVM, после чего переименовать VG

	#Все действия будем выполнять из под root
			sudo -i

	# Посмотрим текущее состояние системы
			vgs

	# Переименуем Volume Group
			vgrename VolGroup00 OtusRoot

	# Правим /etc/fstab, наименования VolGroup00 меняем на OtusRoot
			vi /etc/fstab
			i
			:wq

	# Правим /etc/default/grub 
	# В Строке GRUB_CMDLINE_LINUX так же правим VolGroup00 на OtusRoot
			vi /etc/default/grub
			i
			:wq

	# Правим  /boot/grub2/grub.cfg
	# В Строке linux16 правим VolGroup00 на OtusRoot
			vi /boot/grub2/grub.cfg
			i
			:wq

	# Пересоздаем initrd image, чтобы он знал новое название Volume Group
			mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)

	# Перезагружаем систему
			reboot

	# Проверим наименование, должны увидеть OtusRoot
			vgs

	----------------------------------------------------------------------------------------------------

3. Добавить модуль в initrd

	#Все действия будем выполнять из под root
			sudo -i

	# Скрипты модулей находятся в каталоге /usr/lib/dracut/modules.d/
	# Для добавления своего модуля создаем папку 01test
			mkdir /usr/lib/dracut/modules.d/01test

	# В созданой папке создаем скрипт vi /usr/lib/dracut/modules.d/01test/module-setup.sh
			#!/bin/bash

			check() {
				return 0
			}

			depends() {
				return 0
			}
			
			install() {
				inst_hook cleanup 00 "${moddir}/test.sh"
			}


	# В созданой папке создаем скрипт vi /usr/lib/dracut/modules.d/01test/test.sh

			#!/bin/bash
			
			exec 0<>/dev/console 1<>/dev/console 2<>/dev/console
			cat <<'msgend'
			Hello! You are in dracut module!
			___________________
			< I'm dracut module >
			-------------------
               \
                \
                    .--.
                   |o_o |
                   |:_/ |
                  //   \ \
                 (|     | )
                /'\_   _/`\
                \___)=(___/
             msgend
             sleep 10
             echo " continuing...."

	# Делаем созданые скрипты исполняемыми
			chmod +x /usr/lib/dracut/modules.d/01test/module-setup.sh
			chmod +x /usr/lib/dracut/modules.d/01test/test.sh

	# Пересобираем образ initrd
			dracut -f -v

	# Редактируем grub.cfg
			vi /boot/grub2/grub.cfg

	# С строке linux16 убираем параметры rghb и quiet

	# Перезагружаем 
			reboot






