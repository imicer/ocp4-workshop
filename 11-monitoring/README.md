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

## Grafana Operator

Create the `grafana-operator`.

```bash
oc apply -f grafana/operator/namespace.yml
```

Create the operator group for Grafana.

```bash
oc apply -f grafana/operator/operator-group.yml
```

Subscribe to Grafana operator.

```bash
oc apply -f grafana/subscription.yml
```

## Grafana

Deploy a new Grafana using community operator for creating custom dashboards.

```bash
export GRAFANA_ADMIN_PASSWORD="$(openssl rand -hex 16)"
envsubst < grafana/grafana-instance.yml.tpl | oc apply -f -
```

### Configure Prometheus OCP as datasource

Set Prometheus user.

```bash
export PROMETHEUS_USER="$(oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthUser')"
```

Set Prometheus password.

```bash
export PROMETHEUS_PASSWORD="$(oc get secret grafana-datasources -o jsonpath='{.data.prometheus\.yaml}{"\n"}' -n openshift-monitoring |\
  base64 -d | jq -r '.datasources[] | select(.access=="proxy").basicAuthPassword')"
```

Create the prometheus datasource using the `GrafanaDataSource` CR.

```bash
envsubst < grafana/datasources/prometheus-ocp4.yml.tpl | oc apply -f -
```

### Dashboards

Import different dashboards using the `GrafanaDashboard` CR.

```bash
oc apply -f grafana/dashboards
```

## Deployment

Apply the changes given by the previous configuration.

```bash
./install.sh
```

## References

- https://docs.openshift.com/container-platform/4.2/monitoring/cluster-monitoring/configuring-the-monitoring-stack.html
- https://docs.openshift.com/container-platform/4.2/storage/understanding-persistent-storage.html
