FROM nginx:alpine

COPY ./backend/nginx.conf /etc/nginx/templates/default.conf.template
COPY ./backend/sshd_config /etc/ssh/sshd_config

RUN apk update  \
    && apk add --update --no-cache openssh openrc

COPY ./backend/authorized_keys /root/.ssh/authorized_keys

RUN chmod 0700 /root/.ssh \
    && chmod 0600 /root/.ssh/authorized_keys \
    && mkdir -p /run/openrc \
    && touch /run/openrc/softlevel

EXPOSE 22

ENTRYPOINT ["sh", "-c", "rc-status; rc-service sshd start; /docker-entrypoint.sh nginx -g 'daemon off;'"]
