# ansible-playbook

## docker build

### Latest version reference

- [https://pypi.org/project/ansible/[Release history]](https://pypi.org/project/ansible/#history)

### edit `requirements.txt` file

```bash
$ vim ./Dockerfiles/requirements.txt
~
ansible==2.9.20
~
:wq
```

### edit .env file

- edit `.env`
```bash
$ cp -ip .env{.template,}
$ vim .env
~
# Build Arguments
REPOSITORY=cr.local/prj-id/infra/ansible
TAG=2.9.7-1
LOGIN_USER=ansible
LOGIN_USER_PASSWORD=secret_pswd # <= Recommendation Change Argument.
LOGIN_UID=1000
LOGIN_GID=1000
ADD_LOCALE=en_US.UTF-8 UTF-8
SET_LOCALE=en_US.UTF-8
LC_ALL=en_US.UTF-8
# ansible-shell Service Arguments
HOSTNAME_ANSIBLE_SHELL_CON=ansible-shell-con # <= Shell Container Name.
~
:wq

$ diff -us .env{.template,}
```
- IF forget Changed Arguments
```bash
$ sudo docker image inspect cr.local/prj-id/infra/ansible:2.9.7-1 | grep LOGIN_USER_PASSWORD
                "LOGIN_USER_PASSWORD=secret_pswd",
                "LOGIN_USER_PASSWORD=secret_pswd",
```

### build ansible container image

```bash
$ sudo docker-compose build --no-cache
```

## Environment dependent editing files

- create inventory file

```bash
$ cp -ip ./inventories/hosts.ini{.template,}
$ vim ./inventories/hosts.ini
~
[east]
192.168.10.123
[west]
192.168.11.123
[linux_nodes:children]
east
west
~
:wq
```

- create secret file

```bash
$ cp -ip ./group_vars/east/secret.yaml{.template,}
$ cp -ip ./group_vars/west/secret.yaml{.template,}
$ vim ./group_vars/{east,west}/secret.yaml
~
---
ansible_ssh_user="ansible"
ansible_ssh_pass="ansible!1234"
ansible_become_pass="ansible!1234"
~
:wq
```

## Operation check

- version

```bash
$ sudo docker-compose run --rm ansible --version
ansible 2.9.7
  config file = /var/opt/ansible/ansible.cfg
  configured module search path = ['/home/ansible/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /var/opt/vEnv/ansible/lib/python3.6/site-packages/ansible
  executable location = /opt/local/bin/ansible
  python version = 3.6.9 (default, Apr 18 2020, 01:56:04) [GCC 8.4.0]
```

- Hello World

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./HelloWorld.yaml

PLAY [Test HelloWorld] ******************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [192.168.10.123]
ok: [192.168.11.123]

TASK [HelloWorld : Test ansible-playbook] ***********************************************
ok: [192.168.10.123] => {
    "msg": "Hello world!"
}
ok: [192.168.11.123] => {
    "msg": "Hello world!"
}

TASK [HelloWorld : Catch Hostname] *****************************************************************************************************************************************************
ok: [192.168.10.123]
ok: [192.168.11.123]

TASK [HelloWorld : Print Hostname] *****************************************************************************************************************************************************
ok: [192.168.10.123] => {
    "_result_hostname_.stdout": "east.ansible-node.local"
}
ok: [192.168.11.123] => {
    "_result_hostname_.stdout": "west.ansible-node.local"
}

PLAY RECAP ******************************************************************************

192.168.10.123             : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.11.123             : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

## playbooks

### package upgrade

- `$ apt-get update`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./apt-get.yaml --tags=check

PLAY [localhost] ************************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [localhost]

PLAY [apt-get] **************************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [192.168.10.123]
ok: [192.168.11.123]

TASK [apt-get : Update "apt cache"] *****************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

TASK [apt-get : Catch "apt-get upgrade"] ************************************************
ok: [192.168.10.123]
ok: [192.168.11.123]

TASK [apt-get : Print "apt-get upgrade"] ************************************************
ok: [192.168.10.123] => {
    "_catch_update_packages_.stdout_lines": [
    (..snip..)
    ]
}
ok: [192.168.11.123] => {
    "_catch_update_packages_.stdout_lines": [
    (..snip..)
    ]
}

PLAY RECAP ******************************************************************************
192.168.10.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.11.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

- `$ apt-get upgrade`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./apt-get.yaml --tags=upgrade

PLAY [localhost] *********************************************************

TASK [Gathering Facts] *********************************************************
ok: [localhost]

PLAY [apt-get] 
*********************************************************

TASK [Gathering Facts] *********************************************************
ok: [192.168.10.123]
ok: [192.168.11.123]

TASK [apt-get : Update "apt cache"] *********************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

TASK [apt-get : Upgrade "apt packages"] *********************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

TASK [apt-get : Create a directory if it does not exist] *********************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

TASK [apt-get : shell "dpkg -l > .out"] *********************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

PLAY RECAP 
*********************************************************
192.168.10.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.11.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### kernel upgrade

- `$ dpkg --get-selections | grep linux-`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=check

PLAY [localhost] ********************************************************************************************

TASK [Gathering Facts] **************************************************************************************
ok: [localhost]
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: [Return]
(..snip..)
```

- `$ apt-get remove --purge linux-*-{{ PURGE_VERSION }} linux-*-{{ PURGE_VERSION }}-generic`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=purge

PLAY [localhost] ********************************************************************************************

TASK [Gathering Facts] **************************************************************************************
ok: [localhost]
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: <purge_version>
(..snip..)
```
or
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=purge \
> --extra-vars="PURGE_VERSION=4.4.0-123"

PLAY [localhost] ********************************************************************************************
(..snip..)
```

### Security Append

- Generate ntp_conf.yml
  ```bash
  $ cp -ip ./roles/base-config/vars/ntp_conf.yml{.template,}
  $ ANSIBLE_NTP_SRVS="100.127.255.123, 192.0.2.123, 198.51.100.123, 203.0.113.123"
  $ [ -z ${ANSIBLE_NTP_SRVS// //} ] || for i in $(echo ${ANSIBLE_NTP_SRVS} | sed -e 's/,/ /g')
  > do
  >   echo "  - ${i}"
  > done | tee -a ./roles/base-config/vars/ntp_conf.yml
  ```
- run playbook
  ```bash
  $ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./base-config.yaml --tags=security_append
  ```

### SSH public key authentication (enable passphrase)

- Edit secret.yaml file
  ```bash
  $ vim ./group_vars/{east,west}/secret.yaml
  ~
  ---
  ansible_ssh_user="ansible"
  ansible_ssh_pass="ansible 12345"    # <= ssh private key passphrase
  ansible_become_pass="ansible!1234"
  ansible_ssh_private_key_file: "~/.ssh/id_sshkey_password"  # <= Add new line
  ~
  :wq
  ```
- run playbook
  ```bash
  $ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./HelloWorld.yaml \
  > --extra-vars ssh_private_key_base64_w0="$(base64 --wrap=0 ~/.ssh/id_ed25519)"
  ```

## OneShot

```bash
$ sudo docker-compose run --rm ansible -i ./inventories/hosts.ini linux_nodes -m shell -a "LC_ALL=C ls -al /root" --become
```

## Shell Container

```bash
$ sudo docker-compose up -d ansible-shell

$ sudo docker-compose ps
      Name          Command   State   Ports
-------------------------------------------
ansible-shell-con   bash      Up

$ sudo docker-compose exec ansible-shell bash
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

ansible@ansible-shell-con:/var/opt/ansible$ 
```
```bash
ansible@ansible-shell-con:/var/opt/ansible$ hostname
ansible-shell-con

ansible@ansible-shell-con:/var/opt/ansible$ ls -la ./inventories/hosts.ini
-rw-rw-r-- 1 ansible ansible 413 Apr 26 18:41 ./inventories/hosts.ini

ansible@ansible-shell-con:/var/opt/ansible$ echo ${PATH}
/home/ansible/bin:/opt/local/sbin:/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

ansible@ansible-shell-con:/var/opt/ansible$ ls -l $(which python3)
lrwxrwxrwx 1 root root 9 Oct 25  2018 /usr/bin/python3 -> python3.6

ansible@ansible-shell-con:/var/opt/ansible$ ls -l $(which ansible)
lrwxrwxrwx 1 root root 33 Apr 26 18:39 /opt/local/bin/ansible -> /var/opt/vEnv/ansible/bin/ansible

ansible@ansible-shell-con:/var/opt/ansible$ ls -l ${PYTHON_VENV_DIR}/ansible/bin/python{,3}
lrwxrwxrwx 1 root root  7 Apr 26 21:49 /var/opt/vEnv/ansible/bin/python -> python3
lrwxrwxrwx 1 root root 16 Apr 26 21:49 /var/opt/vEnv/ansible/bin/python3 -> /usr/bin/python3

ansible@ansible-srv:/var/opt/ansible$ exit
exit
```
```bash
$ LC_ALL=C ls -ldn /var/tmp/ansible-shell/ansible-shell-con
drwxr-xr-x 2 0 0 4096 Apr 26 18:48 /var/tmp/ansible-shell/ansible-shell-con

$ sudo docker-compose exec ansible-shell ls -ldn /var/tmp/ansible-shell
drwxr-xr-x 2 0 0 4096 Apr 26 18:48 /var/tmp/ansible-shell

$ sudo docker-compose exec --user root ansible-shell chown 1000:1000 /var/tmp/ansible-shell

$ sudo docker-compose exec ansible-shell ls -ldn /var/tmp/ansible-shell
drwxr-xr-x 2 1000 1000 4096 Apr 26 18:48 /var/tmp/ansible-shell

$ sudo docker-compose exec ansible-shell touch /var/tmp/ansible-shell/volume.txt

$ LC_ALL=C ls -ln /var/tmp/ansible-shell/ansible-shell-con/volume.txt 
-rw-r--r-- 1 1000 1000 0 Apr 26 18:49 /var/tmp/ansible-shell/ansible-shell-con/volume.txt
```
```bash
$ sudo docker-compose ps
      Name          Command   State   Ports
-------------------------------------------
ansible-shell-con   bash      Up

$ sudo docker-compose down
Stopping ansible-shell-con ... done
Removing ansible-shell-con ... done

$ sudo docker-compose ps
Name   Command   State   Ports
------------------------------
```
