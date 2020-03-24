# Logging

Use fluentd for collecting node logs and send to Elasticsearch.

## Elasticsearch operator

Create the `openshift-elastic-operator` namespace.

```bash
oc apply -f elastic/operator/namespace.yml
```

Allow Prometheus to scrape metrics in this namespace.

```bash
oc apply -f elastic/operator/rbac.yml
```

Create the operator group for elasticsearch operator.

```bash
oc apply -f elastic/operator/operator-group.yml
```

Subscribe to elasticsearch operator.

```bash
oc apply -f elastic/operator/subscription.yml
```

## Cluster logging operator

Create the `openshift-logging` namespace.

```bash
oc apply -f cluster-logging/operator/namespace.yml
```

Allow Prometheus to scrape metrics in this namespace.

```bash
oc apply -f cluster-logging/operator/rbac.yml
```

Create the operator group for the cluster-logging operator.

```bash
oc apply -f cluster-logging/operator/operator-group.yml
```

Subscribe to cluster-logging operator.

```bash
oc apply -f cluster-logging/operator/subscription.yml
```

## Cluster logging stack

Deploy cluster-logging components (ES, Kibana, Curator and Fluentd).

```bash
oc apply -f cluster-logging
```

## Curator configuration

Modify Curator configuration in `cluster-logging/curator` folder and replace the configmap that stores the current configuration.

```bash
oc create cm curator --dry-run -o yaml \
    --from-file=curator5.yaml=cluster-logging/curator/curator5.yaml \
    --from-file=config.yaml=cluster-logging/curator/config.yaml \
    --namespace openshift-logging |\
        oc replace cm --filename=- --namespace openshift-logging
```

Force Curator to run the new configuration.

```bash
oc create job --from=cronjob/curator curator-manual-"$(date +%s)"
```

## References

-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-deploying.html
-   https://docs.openshift.com/container-platform/4.2/logging/config/cluster-logging-management.html
-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-eventrouter.html
