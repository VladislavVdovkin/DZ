

#��������� Vagrantfile � ������������

           vagrant up
		   vagrant ssh



#��� ���������� �������� ����� ��������� �� ��� root

           sudo -i

#������� 1
		   
#���������/������ ������������� ( first, second )

           useradd first
           useradd second

#����� �� ������

           passwd first
           passwd second

#c������ ������ admin 

            groupadd admin

#�������� ������������� � ������ - admin

            usermod -aG admin first
            usermod -aG admin second
            usermod -aG admin root


#� ������� ������� id - ��������� ������ � �������������. 1002(admin) - ������������ � ������� ������������

            id first

            uid=1002(first) gid=1003(first) groups=1003(first),1002(admin)

            id second

            uid=1003(second) gid=1004(second) groups=1004(second),1002(admin)

            id root

            uid=0(root) gid=0(root) groups=0(root),1002(admin)

#��������� ���� �������������, ����� ������ admin, ����� � ������� �� SSH � �������� ��� (������� � �����������) ��� ����� ����������.



#��������� PAM

            yum install -y pam*
            yum install -y libpam*


#�������� �������

            touch /etc/script

            nano /etc/script

#�����

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

#����������

            chmod +x /etc/script

#��������� ������ � ���� /etc/pam.d/sshd

            nano /etc/pam.d/sshd

#����������� ������

            account    required     /etc/script.so

#������� 2

#������������� docker

            yum install -y docker*

#��� ����������� ������������ ����� �������� � docker

            usermod -aG docker first

