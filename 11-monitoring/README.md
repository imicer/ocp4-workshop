# Monitoring

Configure monitoring stack (Prometheus, Grafana and AlertManager).

## Deploy monitoring stack

Apply a custom ConfigMap in `openshift-monitoring` namespace for tuning the following options.

- Node placement.
- Persistent storage for Prometheus.
- Persistent storage for AlertManager.
- Retention time for Prometheus metrics data.

```bash
oc apply -f monitoring-stack
```

## Additional Grafana

Deploy a new Grafana using community operator for creating custom dashboards.

### Deploy Grafana operator

Create namespace for Grafana operator.

```bash
oc create ns grafana-operator
```

Create operator group.

```bash
oc apply -f grafana/operator-og.yml
```

Subscribe to Grafana operator.

```bash
oc apply -f grafana/operator-subscription.yml
```

Deploy Grafana instance.

```bash
oc apply -f grafana/grafana-instance.yml
```

### Retrieve Prometheus credentials

There are two different ways for authenticating against Prometheus OAuth, using same user and password than installed Grafana or using a dedicated service account (recommended).

#### Basic authentication

Get Prometheus user.

```bash
oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthUser'
```

Get Prometheus password.

```bash
oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthPassword'
```

#### Bearer token

Create a service account for Prometheus OAuth.

```bash
oc create sa prometheus-viewer
```

Allow read only access to the service account.

```bash
oc adm policy add-cluster-role-to-user cluster-monitoring-view \
  --rolebinding-name=prometheus-view \
  --serviceaccount=prometheus-viewer \
  --namespace=grafana-operator
```

Get service account token.

```bash
export PROMETHEUS_TOKEN=$(oc get secret $(oc get sa prometheus-viewer -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -o json |\
  jq -r '.data.token' | base64 -d)
```

### Set datasource

Generate custom datasource for prometheus.

```bash
envsubst < grafana/prometheus-ocp-datasource.json.tpl > grafana/prometheus-ocp-datasource.json
```

Import datasource in Grafana (create API key before).

```bash
GRAFANA_API_KEY="" # From GUI
GRAFANA_URL=$(oc get route grafana-route -o "custom-columns=URL:.spec.host" | grep -v URL)
curl -k -X POST \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer ${GRAFANA_API_KEY}" \
    --data @grafana/prometheus-ocp-datasource.json \
    "https://${GRAFANA_URL}/api/datasources"
```

### Custom dashboards

Import different dashboards.

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
