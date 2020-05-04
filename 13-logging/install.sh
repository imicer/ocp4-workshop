#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
ELASTIC_OPERATOR_VERSION="elasticsearch-operator.4.4.0-202004261927"
ELASTIC_OPERATOR_STATUS="Installing"

CLOGGING_OPERATOR_VERSION="clusterlogging.4.4.0-202004261927"
CLOGGING_OPERATOR_STATUS="Installing"

# Install Elasticsearch operator
yq write elastic/operator/subscription.yml \
  --inplace "spec.startingCSV" ${ELASTIC_OPERATOR_VERSION}

oc apply -f elastic/operator

echo "Installing Elastic operator..."
until [ "${ELASTIC_OPERATOR_STATUS}" == "Succeeded" ]; do
    ELASTIC_OPERATOR_STATUS="$(oc get csv ${ELASTIC_OPERATOR_VERSION} \
        -o jsonpath="{.status.phase}" --namespace openshift-elastic-operator)" || true
    sleep 1
done

oc patch sub elastic-operator --type=merge \
    --patch '{"spec":{"installPlanApproval":"Manual"}}' \
    --namespace openshift-elastic-operator

# Install Cluster-logging operator
yq write cluster-logging/operator/subscription.yml \
  --inplace "spec.startingCSV" ${CLOGGING_OPERATOR_VERSION}

oc apply -f cluster-logging/operator

echo "Installing Cluster logging operator..."
until [ "${CLOGGING_OPERATOR_STATUS}" == "Succeeded" ]; do
    CLOGGING_OPERATOR_STATUS="$(oc get csv ${CLOGGING_OPERATOR_VERSION} \
        -o jsonpath="{.status.phase}" --namespace openshift-logging)" || true
    sleep 1
done

oc patch sub cluster-logging-operator --type=merge \
    --patch '{"spec":{"installPlanApproval":"Manual"}}' \
    --namespace openshift-logging

# Deploy EFK stack
oc apply -f cluster-logging && sleep 5

echo "Kibana URL is https://$(oc get route kibana -o jsonpath="{.spec.host}" -n openshift-logging)"

# Configure Curator
oc create cm curator --dry-run -o yaml \
    --from-file=curator5.yaml=cluster-logging/curator/curator5.yaml \
    --from-file=config.yaml=cluster-logging/curator/config.yaml \
    --namespace openshift-logging |\
        oc replace cm --filename=- --namespace openshift-logging