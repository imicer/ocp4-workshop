#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
METERING_OPERATOR_VERSION="metering-operator.4.3.5-202003020549"
METERING_OPERATOR_STATUS="Installing"

# Install Metering operator
yq write metering-stack/operator/subscription.yml \
  --inplace "spec.startingCSV" ${METERING_OPERATOR_VERSION}

oc apply -f metering-stack/operator

echo "Installing Metering operator..."
until [ "${METERING_OPERATOR_STATUS}" == "Succeeded" ]; do
    METERING_OPERATOR_STATUS="$(oc get csv ${METERING_OPERATOR_VERSION} \
        -o jsonpath="{.status.phase}" --namespace openshift-metering)" || true
    sleep 1
done

oc patch sub metering-operator --type=merge \
    --patch '{"spec":{"installPlanApproval":"Manual"}}' \
    --namespace openshift-metering

# Deploy Metering stack
oc apply -f metering-stack

# Create Metering reports
oc apply -f reports
