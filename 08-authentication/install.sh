#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Input variables
OCP_LOCAL_USERS=("recovery" "platform-admin" "architect" "developer")

# Create passwd database
if [ ! -f "users/htpasswd" ]; then
    touch users/htpasswd

    for OCP_LOCAL_USER in "${OCP_LOCAL_USERS[@]}"; do
        RANDOM_PASSWORD="$(openssl rand -hex 16)"
        htpasswd -B -b users/htpasswd ${OCP_LOCAL_USER} ${RANDOM_PASSWORD}
        echo "Password for user ${OCP_LOCAL_USER} is ${RANDOM_PASSWORD}">> auth.log
    done
fi

oc create secret generic htpasswd-users \
    --from-file=htpasswd=users/htpasswd -n openshift-config || true

# Create groups
oc apply -f groups

# Configure OAuth providers
oc apply -f oauth/cluster.yml
