#!/bin/bash

echo_error() { echo "$@" 1>&2; }

eval "$(ssh-agent -s)"

if [[ -z "${SSH_USERNAME}" ]]; then
  echo_error "The variable 'SSH_USERNAME' is not set!"
  exit 1
fi
if [[ -z ${SSH_HOST} ]]; then
  echo_error "The variable 'SSH_HOST' is not set!"
  exit 1
fi
if [[ -z ${REMOTE_PORT} ]]; then
  echo_error "The variable 'REMOTE_PORT' is not set!"
  exit 1
fi
if [[ -z ${SSH_KEY_FILE} ]]; then
  echo_error "The variable 'SSH_KEY_FILE' is not set!"
  exit 1
else
  chmod 0600 "$SSH_KEY_FILE"

  if [[ $(stat -c "%a" "$SSH_KEY_FILE") != 600 ]]; then
    SSH_KEY_FILE_NAME=$(basename "${SSH_KEY_FILE}")
    mkdir /root/.ssh
    chmod 0700 /root/.ssh
    cp "$SSH_KEY_FILE" "/root/.ssh/$SSH_KEY_FILE_NAME"
    chmod 0600 "/root/.ssh/$SSH_KEY_FILE_NAME"
    SSH_KEY_FILE="/root/.ssh/$SSH_KEY_FILE_NAME"
  fi

  if [[ -z ${SSH_KEY_PASSPHRASE_FILE} ]]; then
    cat "$SSH_KEY_FILE" | ssh-add -
  else
ssh_key_passphrase=$(cat $SSH_KEY_PASSPHRASE_FILE)
expect << EOF
  spawn ssh-add $SSH_KEY_FILE
  expect "Enter passphrase"
  send "$ssh_key_passphrase\r"
  expect off
EOF
  fi
fi

echo "DONE!"

autossh -M 0 -N -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -L "*:6969:0.0.0.0:${REMOTE_PORT}" -p ${SSH_PORT} ${SSH_USERNAME}@${SSH_HOST} $*
