# Machine Config Operator (MCO)

Manage configuration changes and updates to essentially everything between the kernel and kubelet.

## Set a different timezone

1. Change timezone for masters.

```
oc apply -f machine-config/master/50-master-timezone.yml
```

2. Change timezone for workers.

```
oc apply -f machine-config/worker/50-worker-timezone.yml
```

## Infranstructure configuration

Create a new `mcp` for infrastructure nodes.

```
oc apply -f machine-config-pool/infra.yml
```

## References

- https://docs.openshift.com/container-platform/4.2/machine_management/creating-infrastructure-machinesets.html
- https://github.com/openshift/machine-config-operator
- https://access.redhat.com/solutions/4342791
