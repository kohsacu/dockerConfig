# Install docker-compose(pip)

## tl;dr

* [install-using-pip](https://docs.docker.com/compose/install/#install-using-pip)

## Alternative install options

### dependency packages

```bash
$ sudo aptitude install python3-venv python3-dev
$ sudo aptitude install libffi-dev libssl-dev
```

### Virtualenv

```bash
$ sudo mkdir /opt/vEnv
$ cd /opt/vEnv
$ sudo python3 -m venv docker-compose
$ source ./docker-compose/bin/activate
(docker-compose) $
```

### Python pip

```bash
(docker-compose) $ sudo -H ./docker-compose/bin/pip freeze
pkg-resources==0.0.0
You are using pip version 8.1.1, however version 19.1.1 is available.
You should consider upgrading via the 'pip install --upgrade pip' command.
(docker-compose) $ sudo -H ./docker-compose/bin/pip install --upgrade pip
$ sudo -H ./docker-compose/bin/pip --version
pip 19.1.1 from /opt/vEnv/docker-compose/lib/python3.5/site-packages/pip (python 3.5)
(docker-compose) $ sudo -H ./docker-compose/bin/pip install docker-compose
(docker-compose) $ which docker-compose
/opt/vEnv/docker-compose/bin/docker-compose
(docker-compose) $ deactivate
```

### Test the installation

```bash
$ cd /usr/local/bin
$ sudo ln -s /opt/vEnv/docker-compose/bin/docker-compose .
```
```bash
$ cd
$ sudo docker-compose version
docker-compose version 1.24.1, build 4667896
docker-py version: 3.7.3
CPython version: 3.5.2
OpenSSL version: OpenSSL 1.0.2g  1 Mar 2016
```
