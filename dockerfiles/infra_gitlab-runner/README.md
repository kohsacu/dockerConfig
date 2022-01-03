# gitlab-runner on docker

## env_file
- Create env file
  ```bash
  $ cp -ip ./.env{.template,}
  $ vim ./.env
  ```

## volume
- Create directories
  ```bash
  $ source ./.env
  $ echo "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"
  /var/opt/docker.volume/gitlab-runner-shared
  $ sudo mkdir -p "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"/config/certs
  $ sudo chmod 700 "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"/config/certs
  ```
- Copy config.toml file
  ```bash
  $ sudo cp -ip ./config/config.toml.example "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"/config/config.toml
  $ sudo chown root. "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"/config/config.toml
  ```
- IF use self-signed CA
  ```bash
  $ sudo cp -ip /path/2/dir/self-CA.crt "${PATH_DOCKER_VOLUME}/${SHARED_CONTAINER}"/config/certs
  ```

## run gitlab-runner container
- Create and start container
  ```bash
  $ sudo docker-compose up -d gitlab-runner-shared
  ```

## register
- Example
  ```bash
  $ CI_SERVER_URL='https://gitlab.example.com/'
  $ REGISTRATION_TOKEN='abcd1234ABCD5678-zZ0'
  $ sudo docker container exec gitlab-runner-shared gitlab-runner register \
  --non-interactive --description "shell-runner(shared) on $(hostname)" \
  --executor shell \
  --tag-list "shared,shell,$(hostname)" \
  --url ${CI_SERVER_URL} \
  --registration-token ${REGISTRATION_TOKEN} \
  
  ```
  ```bash
  $ CI_SERVER_URL='https://gitlab.example.com/'
  $ REGISTRATION_TOKEN='abcd1234ABCD5678-zZ0'
  $ sudo docker container exec gitlab-runner-docker gitlab-runner register \
  --non-interactive --description "dind-runner(groups) on $(hostname)" \
  --executor docker \
  --docker-image "docker:18.09.7" \
  --docker-privileged \
  --docker-volumes "/cache" \
  --tag-list "groups,dind,$(hostname)" \
  --url ${CI_SERVER_URL} \
  --registration-token ${REGISTRATION_TOKEN} \
  
  ```
- IF use self-signed CA  
  Add Option.
  ```bash
  --tls-ca-file /etc/gitlab-runner/certs/self-CA.crt
  ```

