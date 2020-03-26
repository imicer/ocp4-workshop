#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
export REGISTRY_HTTP_SECRET="$(openssl rand -hex 16 | base64 )"

# Create PVC for image registry
oc apply -f image-registry/pvc.yml

# Render and apply image registry configuration
envsubst < image-registry/config.yml.tpl | oc apply -f -

oc patch config cluster --type=json \
    --patch '[{ "op": "remove", "path": "/spec/storage/s3" }]' \
    --namespace openshift-image-registry || true