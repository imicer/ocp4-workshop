# Metering

Metering focuses primarily on in-cluster metric data using Prometheus as a default data source, enabling users of metering to do reporting on pods, namespaces, and most other Kubernetes resources.

## Installation

Create `openshift-metering` namespace.

```
oc apply -f stack/operator/namespace.yml
```

Create the operator group for metering stack.

```
oc apply -f stack/operator/operator-og.yml
```

Subscripbe to metering operator.

```
oc apply -f stack/operator/operator-sub.yml
```

Deploy metering stack.

```
oc apply -f stack
```

## Reporting

1. Schedule cluster reports.

```
oc apply -f reports
```

2. Download report.

```
METERING_API_URL="$(oc get routes metering -o jsonpath='{.spec.host}')"
METERING_API_TOKEN="$(oc get secret $(oc get sa reports-viewer -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -o json | jq -r '.data.token' | base64 -d)"
METERING_REPORT_NAME="namespace-cpu-request"
METERING_REPORT_FORMAT="json"

curl --silent --insecure -H "Authorization: Bearer ${METERING_API_TOKEN}" "https://${METERING_API_URL}/api/v1/reports/get?name=${METERING_REPORT_NAME}&namespace=openshift-metering&format=$METERING_REPORT_FORMAT" | jq '.'
```

## References

- https://docs.openshift.com/container-platform/4.2/metering/metering-installing-metering.html