#!/usr/bin/env bash

#
# This script can be used to store encrypted data in salt
# pillars. Please don't store them in salt states.
#

SCRIPT_DIR="$( cd -P -- "$( dirname -- "$0" )" && pwd -P )"

ENVS='production staging'

if ! [[ " $ENVS " =~ .*\ $1\ .* ]]; then
    echo "Usage: $0 <$ENVS>";
    exit 1;
fi

ENV=$1

encrypt() {
  gpg --encrypt --armor --recipient-file "${SCRIPT_DIR}/gpg/pubkey-${ENV}.gpg"
}

if [ -t 0 ] ; then # stdin is closed
  read -p "Enter Secret: " -r -s secret
  # Echo back stars:
  if [ -z "${secret}" ]; then
    echo
    echo No input received. Aborted.
    exit 1
  fi
  printf "%${#secret}s\n" ' ' | tr ' ' '*'
  # And encrypt
  printf '%s' "${secret}" | encrypt
else
  cat | encrypt
fi
