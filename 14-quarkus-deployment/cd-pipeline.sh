#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Openshift configuration
OCP_PROJECT="quarkus-example"
OCP_API_URL="https://api.ocp.sandbox693.opentlc.com:6443"
OCP_API_TOKEN="${OCP_API_TOKEN}"

## Authenticate against Openshift API
oc login --server=${OCP_API_URL} --token=${OCP_API_TOKEN}

## Deploy application
oc apply -f deployment -n ${OCP_PROJECT}

# Application configuration
APP_URL="quarkus-example.apps.opentlc.internal"

# Bastion configuration
BASTION_SSH_USER="maintuser"
BASTION_SSH_KEY="../02-installation/ssh/id_rsa"
BASTION_PUBLIC_IP="3.120.192.119"

## Expose SSH proxy
echo "Listening in https://quarkus-example.apps.opentlc.internal:8443..."
ssh -N -L 8443:${APP_URL}:443 -i ${BASTION_SSH_KEY} ${BASTION_SSH_USER}@${BASTION_PUBLIC_IP}
