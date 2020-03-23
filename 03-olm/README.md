# Operators

An Operator is a piece of software that extends Kubernetes to understand a specific application’s operational requirements.

## What is an operator?

An operator handles on or more **Custom Resource Definition** (CRD).

```
oc apply -f dbass-operator/operator
```

Create as many instances of a CRD using **Custom Resource** (CR).

```
oc apply -f dbass-operator/databases
```

The operator controller will listen to CR events and will make actions accordingly to its internal logic.

## Operator Lifecycle Manager

The **Operator Lifecycle Manager** (OLM) is also and operator that provides a declarative way to install, manage, and upgrade Operators and their dependencies in a cluster.

### Sources

Get all operator sources availables.

```
oc get operatorsource -n openshift-marketplace
```

Install a new source.

```
oc apply -f sources
```

### Package manifests

Get all package manifests for an operator source.

```
oc get packagemanifests -l "catalog=${operator_source}" -n openshift-marketplace
```

Get the `channel`, `catalog source`, `version` and the `install modes` from the package manifest.

```
oc describe packagemanifests <operator> -n openshift-marketplace
```

### Subscription

Create an Operator Group (OG) to allow an operator to be installed in one, many or all namespaces.

```yaml
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: ${operator_name}
  namespace: ${operator_namespace}
spec: # Leave spec empty to be installed in all namespaces
  targetNamespaces:
    - ${operator_namespace}
    - ${other_namespace}
```

Subscribe to the operator.

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ${operator_name}
  namespace: ${operator_namespace}
spec:
  name: ${operator_name}
  source: ${operator_source}
  sourceNamespace: openshift-marketplace
  channel: ${operator_channel}
  installPlanApproval: Automatic # Or Manual
  startingCSV: ${operator_version}
```

Get current operator status.

```
oc get csv ${operator_name} -n ${operator_namespace}
```

## References

- https://github.com/kubernetes/sample-controller
- https://octetz.com/docs/2019/2019-10-13-controllers-and-operators/
