# Machine API

Ensure presence of expected number of replicas and a given provider config for a set of machines.

## Infrastructure nodes

1. Load environment configuration.

```
source environment/<env>
```

2. Create secret from ignition file.

```
oc create secret generic infra-user-data \
    --from-literal="disableTemplating=true" \
    --from-file="userData=ignition/infra.json" \
    --namespace openshift-machine-api
```

3. Create MachineSet for different AZ.

```
for CLUSTER_AZ in "eu-central-1a" "eu-central-1b" "eu-central-1c"; do
  export CLUSTER_AZ=${CLUSTER_AZ}
  envsubst < machineset/infra.yml | oc apply -f -
done
```

4. Label new nodes with `infra` role and wait until MCO applies update.

```
oc get machine -l "machine.openshift.io/cluster-api-machine-role=infra" -o wide |\
grep -v NODE |\
awk '{system("oc label node "$7" node-role.kubernetes.io/infra= node-role.kubernetes.io/worker-")}'
```

## TODO

- Create securityGroups for infra nodes.
- Create iamInstanceProfile for infra node.

## References

- https://docs.openshift.com/container-platform/4.2/machine_management/creating_machinesets/creating-machineset-aws.html
