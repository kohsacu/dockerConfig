# ansible-playbook

## docker build

- edit .env file

[Overview of published packages](https://launchpad.net/~ansible/+archive/ubuntu/ansible-2.8?field.series_filter=bionic)
```bash
$ vim .env
~
REPOSITORY=infra/ansible
TAG=2.8.7-1
ANSIBLE_VERSION=2.8.7-1ppa~bionic
~
:wq
```

- build ansible container image

```bash
$ sudo docker-compose build
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
ansible 2.8.7
  config file = /var/tmp/ansible/ansible.cfg
  configured module search path = [u'/root/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.15+ (default, Oct  7 2019, 17:39:04) [GCC 7.4.0]
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

PLAY RECAP ******************************************************************************

192.168.10.123             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.11.123             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
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

TASK [apt-get : Upgrade "apt packages"] *************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

TASK [apt-get : shell "dpkg -l > .out"] *************************************************
changed: [192.168.10.123]
changed: [192.168.11.123]

PLAY RECAP ******************************************************************************
192.168.10.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
192.168.11.123             : ok=4    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

### kernel upgrade

- `$ dpkg --get-selections | grep linux-`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=check
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: [Return]
```

- `$ apt-get remove --purge linux-*-{{ PURGE_VERSION }} linux-*-{{ PURGE_VERSION }}-generic`

```bash
$ sudo docker-compose run --rm ansible-playbook -i ./inventories/hosts.ini ./kernel-purge.yaml --tags=purge
Please enter Purge version(ex: 4.4.0-123) [a.b.c-000]: <purge_version>
```

## OneShot

```bash
$ sudo docker-compose run --rm ansible -i ./inventories/hosts.ini linux_nodes -m shell -a "LC_ALL=C ls -al /root" --become
```
