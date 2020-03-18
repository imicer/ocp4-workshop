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
OCP_API_CERTS="$(pwd)/certificates/${OCP_ENVIRONMENT}"

if [ ! -f "${OCP_API_CERTS}/tls.key" ]; then
    letsencrypt certonly --manual --preferred-challenges dns
      --cert-name="tls" --cert-path="${OCP_API_CERTS}" --key-path="${OCP_API_CERTS}" \
      DOMAINS ${OCP_API_SERVER},${OCP_API_SERVER}
fi
