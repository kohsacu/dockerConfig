# ansible-playbook

- env
```bash
$ cat .env
REPOSITORY=infra/ansible
TAG=2.8.3-1
ANSIBLE_VERSION=2.8.3-1ppa~bionic
```
- build ansible container image
```bash
$ sudo docker-compose build
```
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
ansible_sudo_pass="ansible!1234"
~
```
- version
```bash
$ sudo docker-compose run --rm ansible --version
ansible 2.8.3
  config file = /var/tmp/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.15+ (default, Nov 27 2018, 23:36:35) [GCC 7.3.0]
```
- Hello World
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./HelloWorld.yaml
```
- package upgrade
`$ apt-get update`
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./apt-get.yaml --tags=check
```
`$ apt-get upgrade`
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./apt-get.yaml --tags=upgrade
```
- kernel upgrade
`$ dpkg --get-selections | grep linux-`
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=check
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: [Return]
```
`$ apt-get remove --purge linux-*-{{ PURGE_VERSION }} linux-*-{{ PURGE_VERSION }}-generic`
```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=purge
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: 4.4.0-150
```
