#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Apply custom machine config pools
oc apply -f mcp

# Change default scheduler configuration
# oc patch scheduler cluster --type='json' \
#     -p='[{"op":"replace","path":"/spec/defaultNodeSelector","value":"node-role.kubernetes.io/worker="}]'

# Apply custom configuration for workers
oc apply -f machine-config/worker

# Apply custom configuration for masters
oc apply -f machine-config/master