FROM alpine:3.20.1

ENV SSH_HOST, SSH_KEY_FILE, REMOTE_PORT, SSH_USERNAME, SSH_KEY_PASSPHRASE_FILE
ENV SSH_PORT=22

RUN apk upgrade --update \
    && apk add --update --no-cache bash expect autossh

COPY ./config/sshd_config /etc/ssh/sshd_config

EXPOSE 6969

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
