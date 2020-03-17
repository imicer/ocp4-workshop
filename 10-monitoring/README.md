# Monitoring

Deploy prometheus, grafana, alertmanager, kubeStateMetrics and openshiftStateMetrics using the monitoring operator.

## Deploy monitoring stack

Apply a custom ConfigMap in `openshift-monitoring` namespace for tuning the following options.

- Node placement.
- Persistent storage for Prometheus.
- Persistent storage for AlertManager.
- Retention time for Prometheus metrics data.

```
oc apply -f configuration/cluster-monitoring-config.yml
```

## Additional Grafana

Deploy a new Grafana using community operator for creating custom dashboards.

### Deploy Grafana operator

1. Create namespace for Grafana operator.

```
oc new-project grafana-operator
```

2. Subscribe to Grafana operator.

```
oc apply -f grafana/operator-subscription.yml
```

3. Create operator group.

```
oc apply -f grafana/operator-og.yml
```

4. Deploy Grafana instance.

```
oc apply -f grafana/grafana-instance.yml
```

### Retrieve Prometheus credentials

There are two different ways for authenticating against Prometheus OAuth, using same user and password than installed Grafana or using a dedicated service account (recommended).

#### Basic authentication

1. Get Prometheus user.

```
oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthUser'
```

2. Get Prometheus password.

```
oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthPassword'
```

#### Bearer token

1. Create a service account for Prometheus OAuth.

```
oc create sa prometheus-viewer
```

2. Allow read only access to the service account.

```
oc adm policy add-cluster-role-to-user cluster-monitoring-view \
  --rolebinding-name=prometheus-view \
  --serviceaccount=prometheus-viewer \
  --namespace=grafana-operator
```

3. Get service account token.

```
export PROMETHEUS_TOKEN=$(oc get secret $(oc get sa prometheus-viewer -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -o json |\
  jq -r '.data.token' | base64 -d)
```

### Set datasource

1. Generate custom datasource for prometheus.

```
envsubst < grafana/prometheus-ocp-datasource.json.tpl > grafana/prometheus-ocp-datasource.json
```

2. Import datasource in Grafana (create API key before).

```
GRAFANA_API_KEY="" # From GUI
GRAFANA_URL=$(oc get route grafana-route -o "custom-columns=URL:.spec.host" | grep -v URL)
curl -k -X POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${GRAFANA_API_KEY}" \
    --data @grafana/prometheus-ocp-datasource.json \
    "https://${GRAFANA_URL}/api/datasources"
```

### Custom dashboards

1. Import different dashboards.

- **Node exporter**: 11173
- **HAProxy**: 2428

## Namespace metrics

If you want to get prometheus metrics and alerts, add the `cluster-monitoring` label to the namespace.

```
oc label namespace <namespace> "openshift.io/cluster-monitoring=true"
```

## References

-   https://docs.openshift.com/container-platform/4.2/monitoring/cluster-monitoring/configuring-the-monitoring-stack.html
-   https://docs.openshift.com/container-platform/4.2/storage/understanding-persistent-storage.html
