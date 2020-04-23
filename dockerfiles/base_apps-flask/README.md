# Hello flask World!

## tl;dr

- `Hello World!` を表示させる

## 手順

### image の作成

```bash
$ sudo docker-compose build --no-cache
Building apps-flask
Step 1/32 : FROM ubuntu:18.04
 ---> 2ca708c1c9cc
 (..snip..)
Removing intermediate container c55deaa29b44
 ---> b6ec39ead30f

 [Warning] One or more build-args [FLASK_PUBLIC CONTAINER] were not consumed
 Successfully built b6ec39ead30f
 Successfully tagged cr.local/prj-id/base/apps-flask:1.1.2-1
```

### コンテナの起動

```bash
$ sudo docker-compose up -d
(..snip..)
Creating base-apps-flask ... done

$ sudo docker-compose ps
     Name            Command      State            Ports         
-----------------------------------------------------------------
base-apps-flask   entrypoint.sh   Up      0.0.0.0:49180->5000/tcp

$ sudo docker-compose exec apps-flask ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
flask        1  0.0  0.0   4624   876 pts/0    Ss+  03:44   0:00 sh /opt/local/sbin/entrypoint.sh
flask        7  0.0  0.1  80344 25940 pts/0    S+   03:44   0:00 /var/opt/vEnv/flask/bin/python3 /var/opt/apps/hello_world.py
flask        9  0.8  0.1 238476 27084 pts/0    Sl+  03:44   0:15 /var/opt/vEnv/flask/bin/python3 /var/opt/apps/hello_world.py
flask       55  0.0  0.0  36072  3192 pts/1    Rs+  04:13   0:00 ps aux
```

### Hello World!

```bash
$ curl http://<my_docker0_bridge_ip_address>:49180/
Hello World!
```

### コンテナの停止

```bash
$ sudo docker-compose down
```

