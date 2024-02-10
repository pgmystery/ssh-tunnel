FROM alpine:3.19.0

ENV SSH_HOST, SSH_KEY_FILE, REMOTE_PORT, SSH_USERNAME, SSH_KEY_PASSPHRASE_FILE
ENV SSH_PORT=22

RUN apk add --update --no-cache bash expect openssh

COPY ./config/sshd_config /etc/ssh/sshd_config

EXPOSE 6969

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT /entrypoint.sh -u "$SSH_USERNAME" -h "$SSH_HOST" -i "$SSH_KEY_FILE" -l "*:6969:0.0.0.0:$REMOTE_PORT" -p "$SSH_PORT" -k "$SSH_KEY_PASSPHRASE_FILE"
