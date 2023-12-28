#!/bin/bash

declare -A ssh_command_arguments

echo_error() { echo "$@" 1>&2; }

eval $(ssh-agent -s)

while getopts u:h:i:l:p:k: flag; do
  case $flag in
    u)
      ssh_username=$OPTARG
    ;;
    h)
      ssh_host=$OPTARG
    ;;
    i)
      ssh_key_file=$OPTARG
      chmod 0600 $ssh_key_file
    ;;
    l)
      ssh_command_arguments["ssh_tunnel"]="-NL $OPTARG"
    ;;
    p)
      ssh_command_arguments["ssh_port"]="-p $OPTARG"
    ;;
    k)
      ssh_key_passphrase_file=$(cat $OPTARG)
    ;;
    *) # invalid options
    ;;
  esac
done

if [ -z ${ssh_username+x} ]; then
  echo_error "The variable 'SSH_USERNAME' is not set!"
  exit 1
fi
if [ -z ${ssh_host+x} ]; then
  echo_error "The variable 'SSH_HOST' is not set!"
  exit 1
fi
if [ -z ${ssh_key_file+x} ]; then
  echo_error "The variable 'SSH_KEY_FILE' is not set!"
  exit 1
else
  if [ -z ${ssh_key_passphrase_file+x} ]; then
    cat $ssh_key_file | ssh-add -
  else
expect << EOF
  spawn ssh-add $ssh_key_file
  expect "Enter passphrase"
  send "$ssh_key_passphrase_file\r"
  expect off
EOF
  fi
fi

echo "DONE!"

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${ssh_command_arguments["ssh_tunnel"]} $ssh_username@$ssh_host ${ssh_command_arguments["ssh_port"]}
