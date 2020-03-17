## Install OCS 4.2

Ceph uniquely delivers object, block, and file storage in one unified system. Ceph is highly reliable, easy to manage, and free.

## OCS Operator

Create the `openshift-storage` namespace.

```
oc apply -f ocs/operator/namespace.yml
```

Create the operator group for OCS.

```
oc apply -f ocs/operator/operator-group.yml
```

Subscribe to OCS operator.

```
oc apply -f ocs/operator/subscription.yml
```

Disable automatic updates.

```
oc patch sub ocs-operator --type=merge --patch '{"spec":{"installPlanApproval":"Manual"}}'
```

## CEPH cluster

Deploy CEPH cluster.

```
oc apply -f ocs/ceph-cluster.yml
```

## Automation

Apply the changes given by the previous configuration.

```bash
./install.sh
```

## References

- https://access.redhat.com/documentation/en-us/red_hat_openshift_container_storage/4.2/html/deploying_openshift_container_storage/deploying-openshift-container-storage