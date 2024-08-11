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
  $ echo "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}"
  /var/opt/docker.volume/gitlab-runner-docker
  ```
- Copy config.toml file
  ```bash
  $ sudo mkdir -p "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}/config"
  $ sudo cp -ip ./config/config.toml.example "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}"/config/config.toml
  $ sudo chown root. "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}/config/config.toml"
  ```
- IF use self-signed CA
  ```bash
  $ sudo mkdir -p "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}"/config/certs
  $ sudo chmod 700 "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}"/config/certs
  $ sudo cp -ip /path/2/dir/self-CA.crt "${PATH_DOCKER_VOLUME}/${DOCKER_CONTAINER}"/config/certs
  ```

## run gitlab-runner container
- Create and start container
  ```bash
  $ sudo docker compose up -d gitlab-runner-docker
  ```

## register
- Example
  ```bash
  $ CI_SERVER_URL='https://gitlab.example.com'
  $ CI_SERVER_PAT='glpat-abcd1234ABCD5678-zZ0' (Scopes: create_runner)
  $ TAG_TYPE='shared'
  $ TAG_EXECUTOR='shell'
  $ RUNNER_TOKEN=$(curl --silent --show-error --request POST "${CI_SERVER_URL}/api/v4/user/runners" \
      --header "private-token: ${CI_SERVER_PAT}" \
      --data 'runner_type=instance_type' \
      --data "description=${TAG_EXECUTOR}-runner (${TAG_TYPE}) on $(hostname -s)" \
      --data "tag_list=${TAG_TYPE},${TAG_EXECUTOR},$(hostname)" \
      | jq -r '.token')
  $ sudo docker compose exec gitlab-runner-docker gitlab-runner register \
      --non-interactive \
      --name "${TAG_EXECUTOR}-runner (${TAG_TYPE}) on $(hostname -s)" \
      --executor ${TAG_EXECUTOR} \
      --url "${CI_SERVER_URL}" \
      --token "${RUNNER_TOKEN}"
  ```
  ```bash
  $ TAG_TYPE='group'
  $ TAG_GROUP='project-name'
  $ TAG_EXECUTOR='docker'
  $ RUNNER_TOKEN=$(curl --silent --show-error --request POST "${CI_SERVER_URL}/api/v4/user/runners" \
      --header "private-token: ${CI_SERVER_PAT}" \
      --data 'runner_type=group_type' \
      --data "description=${TAG_EXECUTOR}-runner (${TAG_TYPE}) on $(hostname -s)" \
      --data "tag_list=${TAG_TYPE},${TAG_GROUP},${TAG_EXECUTOR},$(hostname)" \
      | jq -r '.token')
  $ sudo docker compose exec gitlab-runner-docker gitlab-runner register \
      --non-interactive \
      --name "${TAG_EXECUTOR}-runner (${TAG_TYPE}) on $(hostname -s)" \
      --executor docker \
      --docker-image "docker:27.0.3-dind" \
      --docker-privileged \
      --docker-volumes "/cache" \
      --url "${CI_SERVER_URL}" \
      --token "${RUNNER_TOKEN}"
  ```
- IF use self-signed CA  
  Add Option.
  ```bash
  --tls-ca-file /etc/gitlab-runner/certs/self-CA.crt
  ```
