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

## Modify Curator configuration

1. Delete old Curator configuration.

```
oc delete configmap curator -n openshift-logging
```

2. Apply new configuration.

```
oc create configmap curator \
    --from-file=curator5.yaml=curator/curator5.yaml \
    --from-file=config.yaml=curator/config.yaml \
    --namespace openshift-logging
```

3. Change log leveg debug for Curator traces.

```
oc set env cronjob/curator CURATOR_LOG_LEVEL=DEBUG CURATOR_SCRIPT_LOG_LEVEL=DEBUG
```

4. Force Curator to run new configuration.

```
oc create job --from=cronjob/curator curator-manual-"$(date +%s)"
```

5. Check if everything is working fine and set log level to normal again.

```
oc set env cronjob/curator CURATOR_LOG_LEVEL=ERROR CURATOR_SCRIPT_LOG_LEVEL=ERROR
```


## References

-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-deploying.html
-   https://docs.openshift.com/container-platform/4.2/logging/config/cluster-logging-management.html
-   https://docs.openshift.com/container-platform/4.2/logging/cluster-logging-eventrouter.html
