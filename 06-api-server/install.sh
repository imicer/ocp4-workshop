#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Generate a new certificate for the API server using letsencrypt
export OCP_API_SERVER="$(oc whoami --show-server |\
    sed -e "s/[^/]*\/\/\([^@]*@\)\?\([^:/]*\).*/\2/")"
export OCP_API_CERTS="$(pwd)/certificates"

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

# Get OAuth certificate (https://access.redhat.com/solutions/4505101)
OAUTH_POD="$(oc get pods -l app=oauth-openshift -o jsonpath="{.items[0].metadata.name}" -n openshift-authentication)"
oc rsh -n openshift-authentication ${OAUTH_POD} \
    cat /run/secrets/kubernetes.io/serviceaccount/ca.crt > ~/.kube/${OCP_API_SERVER}.crt

# Replace certificate
envsubst < api-server/cluster.yml.tpl | oc apply -f -