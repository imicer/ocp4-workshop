#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Openshift configuration
OCP_PROJECT="quarkus-example"
OCP_REGISTRY_URL=${OCP_REGISTRY_URL} # Get command from README.md
OCP_REGISTRY_TOKEN=${OCP_REGISTRY_TOKEN} # Get command from README.md

# OCI image configuration
OCI_IMAGE_NAME="quarkus-example"
OCI_IMAGE_TAG="v1.0.0-native"

# Build image
podman build -t ${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} -f oci/native/Dockerfile .

# Promote image to registry
podman login "https://${OCP_REGISTRY_URL}" \
  --username="builder" \
  --password="${OCP_REGISTRY_TOKEN}" \
  --tls-verify=false

podman push ${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} \
  ${OCP_REGISTRY_URL}/${OCP_PROJECT}/${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} \
  --tls-verify=false
