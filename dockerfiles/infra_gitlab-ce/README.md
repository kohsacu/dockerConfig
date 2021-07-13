# gitlab-ce on docker

## volumes
```bash
$ source .env
$ sudo docker volume create --driver local ${container_name}_config
$ sudo docker volume create --driver local ${container_name}_cert
$ sudo docker volume create --driver local ${container_name}_data
$ sudo docker volume create --driver local ${container_name}_logs
$ sudo docker volume create --driver local ${container_name}_registry
```
- example for volume on nfs
```bash
$ sudo docker volume create --driver local \
> --opt type=nfs --opt o=nolock,soft,rw,nfsvers=4,addr=<nfs_server> \
> --opt device=:<nfs_path> ${container_name}_config
```

## cert files
```bash
$ source .env
$ cd /path/to/dir
$ ls -l
-rw-rw-r-- 1 root  root  4984 Jul 10 01:02 server.crt
-rw------- 1 root  root  1675 Jul 10 01:01 server.key
$ sudo cp -ip ./{server,"${hostname}.${domainname}"}.crt
$ sudo cp -ip ./{server,"${hostname}.${domainname}"}.key
$ sudo ln -s ./{"${hostname}","${registry_hostname}"}".${domainname}.crt"
$ sudo ln -s ./{"${hostname}","${registry_hostname}"}".${domainname}.key"
$ sudo mv -i {"${hostname}","${registry_hostname}"}".${domainname}".{crt,key} \
> $(sudo docker inspect ${container_name}_cert | jq -r .[].Mountpoint)/
$ sudo ls -l $(sudo docker inspect ${container_name}_cert | jq -r .[].Mountpoint)/
total 12
-rw-rw-r-- 1 root root 4984 Jul 10 01:02 gitlab.example.com.crt
-rw------- 1 root root 1675 Jul 10 01:01 gitlab.example.com.key
lrwxrwxrwx 1 root root   31 Jul 16 01:23 registry.example.com.crt -> ./gitlab.example.com.crt
lrwxrwxrwx 1 root root   31 Jul 16 01:23 registry.example.com.key -> ./gitlab.example.com.key
$ cd ${OLDPWD}
```
