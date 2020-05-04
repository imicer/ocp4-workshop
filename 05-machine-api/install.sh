#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
export OCP_CLOUD_PROVIDER="${1}"
export OCP_CLUSTER_ID="${2}"
export OCP_CLUSTER_DATACENTER="${3}"

# Cloud providers configuration
declare -a AWS_ZONES=("a" "b" "c")

# Create infra nodes
oc get secret worker-user-data --template={{.data.userData}} -n openshift-machine-api \
    | base64 -d > ignition/infra.json

oc create secret generic infra-user-data \
    --from-literal="disableTemplating=true" \
    --from-file="userData=ignition/infra.json" \
    --namespace openshift-machine-api || true

if [ "${OCP_CLOUD_PROVIDER}" == "aws" ]; then
    for CLUSTER_AZ in "${AWS_ZONES[@]}"; do
        export OCP_NODE_AZ="${OCP_CLUSTER_DATACENTER}${CLUSTER_AZ}"
        envsubst < machineset/aws/infra.yml.tpl | oc apply -f -
    done
else
  echo "${OCP_CLOUD_PROVIDER} provider is not supported yet"
fi

OCP_INFRA_NODES="$(oc get machine -l "machine.openshift.io/cluster-api-machine-role=infra" \
  -o jsonpath="{.items[?(@.status.nodeRef)].status.nodeRef.name}" -n openshift-machine-api)"

for OCP_INFRA_NODE in ${OCP_INFRA_NODES}; do
    oc label node ${OCP_INFRA_NODE} --overwrite=true \
        node-role.kubernetes.io/worker- \
        node-role.kubernetes.io/infra=
done

# Create OCS nodes
# oc get secret worker-user-data --template={{.data.userData}} -n openshift-machine-api \
#     | base64 -d > ignition/ocs.json

# oc create secret generic ocs-user-data \
#     --from-literal="disableTemplating=true" \
#     --from-file="userData=ignition/ocs.json" \
#     --namespace openshift-machine-api || true

# if [ "${OCP_CLOUD_PROVIDER}" == "aws" ]; then
#     for CLUSTER_AZ in "${AWS_ZONES[@]}"; do
#         export OCP_NODE_AZ="${OCP_CLUSTER_DATACENTER}${CLUSTER_AZ}"
#         envsubst < machineset/aws/ocs.yml.tpl | oc apply -f -
#     done
# else
#   echo "${OCP_CLOUD_PROVIDER} provider is not supported yet"
# fi

# OCP_OCS_NODES="$(oc get machine -l "machine.openshift.io/cluster-api-machine-role=ocs" \
#   -o jsonpath="{.items[?(@.status.nodeRef)].status.nodeRef.name}" -n openshift-machine-api)"

# for OCP_OCS_NODE in ${OCP_OCS_NODES}; do
#     oc label node ${OCP_OCS_NODE} --overwrite=true \
#         node-role.kubernetes.io/worker- \
#         node-role.kubernetes.io/ocs=
# done
