#!/usr/bin/env bash

set -o errexit  # exit when a command fails
set -o nounset  # exit when use undeclared variables
set -o pipefail # return the exit code of the last command that threw a non-zero

# Get input variables
GRAFANA_OPERATOR_VERSION="grafana-operator.v3.0.2"

# Configure monitoring stack
oc apply -f monitoring-stack

# Install Grafana operator
export GRAFANA_OPERATOR_STATUS="Installing"
export GRAFANA_ADMIN_PASSWORD="$(openssl rand -hex 16)"

oc apply -f grafana/operator

echo "Installing Grafana operator..."
until [ "${GRAFANA_OPERATOR_STATUS}" == "Succeeded" ]; do
    GRAFANA_OPERATOR_STATUS="$(oc get csv ${GRAFANA_OPERATOR_VERSION} \
        -o jsonpath="{.status.phase}" -n grafana-operator)" || true
    sleep 1
done

oc patch sub grafana-operator --type=merge \
    --patch '{"spec":{"installPlanApproval":"Manual"}}' \
    --namespace grafana-operator

# Configure Prometheus as datasource
export PROMETHEUS_USER="$(oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthUser')"
export PROMETHEUS_PASSWORD="$(oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthPassword')"

envsubst < grafana/datasources/prometheus-ocp4.yml.tpl | oc apply -f -

# Create Grafana dashboards
oc apply -f grafana/dashboards

# Deploy additional Grafana instance
envsubst < grafana/grafana-instance.yml.tpl | oc apply -f -

sleep 2

echo "Grafana URL is https://$(oc get route grafana-route -o jsonpath="{.spec.host}" -n grafana-operator)"
echo "Password for Grafana admin user is ${GRAFANA_ADMIN_PASSWORD}">> auth.log
