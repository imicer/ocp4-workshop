#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Input variables
OCP_ENVIRONMENT="$1"
OCP_VERSION="4.4.3"

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
        https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OCP_VERSION}/openshift-install-linux-${OCP_VERSION}.tar.gz

    tar -xvf openshift-install-linux.tar.gz openshift-install
fi

# Generate installer configuration
if [ ! -f "installation/${OCP_ENVIRONMENT}/install-config.yaml.bkp" ]; then
    mkdir -p installation/${OCP_ENVIRONMENT}

    envsubst < installation/install-config.yaml.tpl > installation/${OCP_ENVIRONMENT}/install-config.yaml

    cp installation/${OCP_ENVIRONMENT}/install-config.yaml \
        installation/${OCP_ENVIRONMENT}/install-config.yaml.bkp

    # Install Openshift 4
    ./openshift-install create cluster --dir=installation/${OCP_ENVIRONMENT} --log-level=debug
fi

# Check if Openshift 4 is up and running
./openshift-install wait-for install-complete --dir=installation/${OCP_ENVIRONMENT} --log-level=debug