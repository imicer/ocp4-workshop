# Logging

Use fluentd for collecting node logs and send to Elasticsearch.

## Elasticsearch operator

1. Create new project for the operator.

```
oc apply -f elastic/namespace.yml
```

2. Allow Prometheus to scrape metrics in the project.

```
oc apply -f elastic/operator-rbac.yml
```

3. Subscribe to operator.

```
oc apply -f elastic/operator-subscription.yml
```

4. Create the operator group.

```
oc apply -f elastic/operator-og.yml
```

## Cluster logging operator

1. Create new project for the operator.

```
oc apply -f logging/namespace.yml
```

2. Allow Prometheus to scrape metrics in the project.

```
oc apply -f logging/operator-rbac.yml
```

3. Subscribe to operator.

```
oc apply -f logging/operator-subscription.yml
```

4. Create the operator group.

```
oc apply -f logging/operator-og.yml
```

## Cluster logging stack

1. Deploy cluster-logging components (ES, Kibana, Curator and Fluentd).

```
oc apply -f logging/cluster-logging.yml
```

## References

-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-deploying.html
-   https://docs.openshift.com/container-platform/4.2/logging/config/cluster-logging-management.html
-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-eventrouter.html
