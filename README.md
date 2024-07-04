# SSH-Tunnel

## Bind ports
Bind the port you want to use locally to the port of the container `6969`.

## Environment Variables

| Environment-Variable    | required | default | description                                                               |
|-------------------------|----------|---------|---------------------------------------------------------------------------|
| REMOTE_PORT             | X        |         | The port on the remote-host side                                          |
| SSH_HOST                | X        |         | The remote-host address                                                   |
| SSH_PORT                |          | 22      | The ssh-port to connect to the remote host                                |
| SSH_USERNAME            | X        |         | The username for the ssh-connection                                       |
| SSH_KEY_FILE            | X        |         | The ssh-private-key file                                                  |
| SSH_KEY_PASSPHRASE_FILE |          |         | The optional file which has the passphrase for the ssh-key as the content |


## Directly run command
```shell
docker run \
  --restart always \
  -p <expose port locally>:6969 \
  --env SSH_HOST=<IP-address or Hostname of the remote server> \
  --env SSH_KEY_FILE=<path of the ssh-key-file which is mounted (use secrets if you can)> \
#  --env SSH_KEY_PASSPHRASE_FILE=<OPTIONAL ssh-key passphrase file path which is mounted (use secrets if you can)> \
  --env SSH_PORT=<SSH port of the other host to connect (example: 22)> \
  --env SSH_USERNAME=<SSH username (example: root)> \
  --env REMOTE_PORT=<remote port you want to access (example: 80 for http)> \
  pgmystery/ssh-tunnel:latest
```

## ... via [`docker-compose`](https://github.com/docker/compose) or [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/)

**In the [example](example) directory, there is an actual working test case**

In this example, you will see a frontend service use a backend-api which is only reachable over the ssh-tunnel

```yaml
version: '3.9'

services:
  frontend:
    image: nginx:latest
    restart: always
    networks:
      - ssh-tunnel
    environment:
      API_HOSTNAME: ssh-tunnel
      API_PORT: 6969

  ssh-tunnel:
    image: pgmystery/ssh-tunnel:latest
    restart: always
    secrets:
      - ssh_key_file
      - ssh_key_passphrase_file
    environment:
      REMOTE_PORT: 8080  # The port of the service you want to connect
      SSH_HOST: backend  # The remote-host name/ip
      SSH_KEY_FILE: /run/secrets/ssh_key_file  # The location of the private ssh-key file in the container
      SSH_KEY_PASSPHRASE_FILE: /run/secrets/ssh_key_passphrase_file  # The location in the container of the secret-file
      SSH_PORT: 2222  # The ssh-port of the remote server [DEFAULT: 22]
      SSH_USERNAME: root  # The ssh-username of the remote server
    networks:
      - ssh-tunnel
# OPTIONAL PORTS, IF YOU RLY WANT TO EXPOSE IT ON THE HOST
#    ports:
#      - "8080:6969"

secrets:
  ssh_key_file:
    file: "./secrets/id_ed25519"
  ssh_key_passphrase_file:
    file: "./secrets/passphrase"

networks:
  ssh-tunnel:
```

[![Try in PWD](https://github.com/play-with-docker/stacks/raw/cff22438cb4195ace27f9b15784bbb497047afa7/assets/images/button.png)](http://play-with-docker.com?stack=http://play-with-docker.com/?stack=https://raw.githubusercontent.com/pgmystery/ssh-tunnel/main/example/play-with-docker-stack.yml)
