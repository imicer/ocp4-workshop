#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Create cluster role bindings
oc apply -f cluster-bindings

# Bind cluster-admin role to recovery user
oc adm policy add-cluster-role-to-user cluster-admin recovery \
  --rolebinding-name=recovery-cluster-admin

# Disable project self-provisioning
oc patch clusterrolebinding self-provisioners -p '{"subjects": null}'

oc annotate clusterrolebinding self-provisioners \
    "rbac.authorization.kubernetes.io/autoupdate=false" \
    --overwrite