#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Input variables
OCP_ENVIRONMENT="$1"

# Load environment configuration
source environment/${OCP_ENVIRONMENT}.env

# Generate a new certificate for the API server using letsencrypt
OCP_API_CERTS="$(pwd)/certificates/${OCP_ENVIRONMENT}"

if [ ! -f "${OCP_API_CERTS}/tls.key" ]; then
  letsencrypt certonly --manual --preferred-challenges dns \
      --register-unsafely-without-email --agree-tos --manual-public-ip-logging-ok \
      --cert-name="tls" --config-dir="${OCP_API_CERTS}" \
      --domains ${OCP_API_SERVER},${OCP_API_SERVER}

  cp ${OCP_API_CERTS}/archive/tls/fullchain1.pem ${OCP_API_CERTS}/tls.crt
  cp ${OCP_API_CERTS}/archive/tls/privkey1.pem ${OCP_API_CERTS}/tls.key
fi

oc create secret tls api-server-public-cert \
  --cert="${OCP_API_CERTS}/tls.crt" --key="${OCP_API_CERTS}/tls.key" \
  --namespace openshift-config || true

# Replace certificate
envsubst < api-server/cluster.yml.tpl | oc apply -f -