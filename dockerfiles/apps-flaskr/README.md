# Tutorial apps Flaskr

## tl;dr

- [https://flask.palletsprojects.com/en/1.1.x/[Tutorial]](https://flask.palletsprojects.com/en/1.1.x/tutorial/)

## 手順

### image の作成

```bash
$ sudo docker-compose build --no-cache
Building apps-flask
Step 1/9 : FROM cr.local/prj-id/base/apps-flask:1.1.2-1
 ---> b6ec39ead30f
 (..snip..)
Removing intermediate container e3f02e930210
 ---> 80dfd95b635b

[Warning] One or more build-args [CONTAINER FLASK_PUBLIC] were not consumed
Successfully built 80dfd95b635b
Successfully tagged cr.local/prj-id/apps/apps-flaskr:0.0.1
```

### コンテナの起動

```bash
$ sudo docker-compose up -d
(..snip..)
Creating apps-flaskr ... done

$ sudo docker-compose ps
   Name          Command      State            Ports         
-------------------------------------------------------------
apps-flaskr   entrypoint.sh   Up      0.0.0.0:49181->5000/tcp

$ sudo docker-compose exec apps-flaskr ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
flask        1  0.5  0.0   4624   860 pts/0    Ss+  02:07   0:00 sh /opt/local/sbin/entrypoint.sh
flask        9  0.9  0.1 159604 29960 pts/0    S+   02:07   0:00 /var/opt/vEnv/flask/bin/python3 /var/opt/vEnv/flask/bin/flask run
flask       12  1.6  0.1 167904 30084 pts/0    Sl+  02:07   0:01 /var/opt/vEnv/flask/bin/python3 /var/opt/vEnv/flask/bin/flask run
flask       26  0.0  0.0  36072  3112 pts/1    Rs+  02:08   0:00 ps aux
```

### venv

```bash
$ sudo docker-compose exec apps-flaskr /var/opt/vEnv/flask/bin/pip freeze
click==7.1.1
Flask==1.1.2
itsdangerous==1.1.0
Jinja2==2.11.2
MarkupSafe==1.1.1
pkg-resources==0.0.0
SQLAlchemy==1.3.16
Werkzeug==1.0.1
```

### Hello World!

```bash
$ sudo docker-compose exec apps-flaskr curl http://localhost:5000/hello
Hello, World!
```

### Connect to the Database

```bash
$ LC_ALL=C ls -lnd ../apps-flaskr
drwxrwxr-x 5 1000 1000 4096 Apr 28 02:14 ../apps-flaskr
$ sudo chgrp $(grep LOGIN_GID .env | awk -F= '{print $2}') ../apps-flaskr
$ LC_ALL=C ls -lnd ../apps-flaskr
drwxrwxr-x 5 1000 49180 4096 Apr 28 02:14 ../apps-flaskr
```
```bash
$ sudo docker-compose exec apps-flaskr bash
flask@apps-flaskr:/var/opt/apps$ . /var/opt/vEnv/flask/bin/activate
(flask) flask@apps-flaskr:/var/opt/apps$ export FLASK_APP=flaskr
(flask) flask@apps-flaskr:/var/opt/apps$ export FLASK_ENV=development
(flask) flask@apps-flaskr:/var/opt/apps$ flask init-db
 * Tip: There are .env or .flaskenv files present. Do "pip install python-dotenv" to use them.
Initialized the database.

$ ls -ld ./instance
drwxr-xr-x 2 flask flask 4096 Apr 29 01:58 ./instance
$ ls -l ./instance/
total 20
-rw-r--r-- 1 flask flask 20480 Apr 29 01:58 flaskr.sqlite
$ grep instance .gitignore 
instance/

(flask) flask@apps-flaskr:/var/opt/apps$ deactivate 
flask@apps-flaskr:/var/opt/apps$ exit
exit
$ 
```
```bash

```

### コンテナの停止

```bash
$ sudo docker-compose down
```

