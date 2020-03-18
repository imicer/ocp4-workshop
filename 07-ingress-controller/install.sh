#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Input variables
OCP_ENVIRONMENT="$1"

# Load environment configuration
source environment/${OCP_ENVIRONMENT}.env

# Configure default ingress controller
oc apply -f ingress-controllers/default.yml

# Deploy new ingress controller for internal applications
INTERNAL_APPS_CERTS="certificates/${OCP_ENVIRONMENT}/internal-apps"

if [ ! -f "${INTERNAL_APPS_CERTS}/tls.key" ]; then
    openssl genrsa 4096 > ${INTERNAL_APPS_CERTS}/tls.key

    openssl req -new -x509 -nodes -sha1 -days 31 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=Red Hat/CN=*.${INTERNAL_APPS_DNS_DOMAIN}" \
        -key ${INTERNAL_APPS_CERTS}/tls.key > ${INTERNAL_APPS_CERTS}/tls.crt
fi

oc create secret tls internal-apps-cert \
  --cert="${INTERNAL_APPS_CERTS}/tls.crt" --key="${INTERNAL_APPS_CERTS}/tls.key" \
  --namespace openshift-ingress || true

envsubst < ingress-controllers/internal-apps.yml.tpl | oc apply -f -
