# SSH-Tunnel example

[![Try in PWD](https://github.com/play-with-docker/stacks/raw/cff22438cb4195ace27f9b15784bbb497047afa7/assets/images/button.png)](http://play-with-docker.com?stack=http://play-with-docker.com/?stack=https://raw.githubusercontent.com/pgmystery/ssh-tunnel/main/example/play-with-docker-stack.yml)

Just run the [docker-compose.yml](docker-compose.yml) file with docker.
```shell
docker compose up -d
```

Open this url: [http://localhost:8080](http://localhost:8080) and check if it says `SUCCESSFUL!`.

## Test the example docker-compose backend with a manually started ssh-tunnel container with "docker run":

### !IMPORTANT: Use the following command in the "example" directory.

Run this command from your host, after your started the example docker-compose file

```shell
docker run \
  --restart always \
  -v ./secrets/id_ed25519:/run/secrets/ssh_key_file \
  -v ./secrets/passphrase:/run/secrets/ssh_key_passphrase_file \
  -p 8083:6969 \
  -p 8084:6968 \
  --net ssh-tunnel-example_ssh-tunnel-backend \
  --env SSH_HOST=backend \
  --env SSH_KEY_FILE=/run/secrets/ssh_key_file \
  --env SSH_KEY_PASSPHRASE_FILE=/run/secrets/ssh_key_passphrase_file \
  --env SSH_PORT=22 \
  --env SSH_USERNAME=root \
  --env REMOTE_PORT=80 \
  pgmystery/ssh-tunnel:latest \
  "-NL *:6968:0.0.0.0:81"
```

Test the ports from your host:

The follow command should return "gangnam style!"
```shell
curl http://localhost:8083
```

The follow command should return "foobar!"
```shell
curl http://localhost:8084
```
