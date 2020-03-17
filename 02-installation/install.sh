#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Input variables
OCP_ENVIRONMENT="$1"

# Generate SSH key
if [ ! -f "ssh/id_rsa" ]; then
    ssh-keygen -q -t rsa -b 4096 -C "auto-generated@redhat.com" \
        -f "$(pwd)/ssh/id_rsa" 2>/dev/null <<< y >/dev/null
fi

# Load environment configuration
source environment/${OCP_ENVIRONMENT}.env

# Download and extract the installer
if [ ! -f "openshift-install" ]; then
    wget -O openshift-install-linux.tar.gz \
        https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest-4.2/openshift-install-linux.tar.gz

    tar -xvf openshift-install-linux.tar.gz openshift-install
fi

# Generate installer configuration
envsubst < installation/install-config.yaml.tpl > installation/install-config.yaml

# Install Openshift 4
./openshift-install create cluster --dir=installation --log-level=debug
