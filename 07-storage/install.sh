#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
OCS_OPERATOR_STATUS="Installing"

# Tag CEPH cluster nodes
oc label nodes --overwrite=true -l node-role.kubernetes.io/ocs="" \
    cluster.ocs.openshift.io/openshift-storage=""

# Install OCS operator
oc apply -f ocs/operator -n openshift-storage

echo "Installing OCS operator..."
until [ "${OCS_OPERATOR_STATUS}" == "Succeeded" ]; do
  OCS_OPERATOR_STATUS="$(oc get csv ocs-operator.v4.2.2 -o jsonpath="{.status.phase}" -n openshift-storage)" || true
  sleep 1
done

echo "OCS operator has been installed"

oc patch sub ocs-operator --type=merge \
    --patch '{"spec":{"installPlanApproval":"Manual"}}' \
    --namespace openshift-storage

# Deploy CEPH cluster
oc apply -f ocs/ceph-cluster.yml