# Internal registry

Configure internal registry.

## Registry URL

Expose the registry out of the cluster, creating an Openshift `Route`.

```
REGISTRY_URL="registry.apps.ocp.sandbox693.opentlc.com"
oc patch configs.imageregistry cluster \
    --type=merge \
    --patch '{"spec":{"routes":[{"name":"public-access","hostname":"'$REGISTRY_URL'"}]}}'
```

## Node placement

Move the registry to `node-role.kubernetes.io/infra=` nodes.

```
oc patch configs.imageregistry cluster \
    --type=merge \
    --patch '{"spec":{"nodeSelector":{"node-role.kubernetes.io/infra":""}}}'
```

## References

- https://docs.openshift.com/container-platform/4.2/machine_management/creating-infrastructure-machinesets.html#infrastructure-moving-registry_creating-infrastructure-machinesets
- https://docs.openshift.com/container-platform/4.2/registry/configuring-registry-storage/configuring-registry-storage-baremetal.html
- https://docs.openshift.com/container-platform/4.2/registry/securing-exposing-registry.html
