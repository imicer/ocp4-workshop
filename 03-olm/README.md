# Operators

An Operator is a piece of software that extends Kubernetes to understand a specific application’s operational requirements.

## Install sandwich operator

1. Install CRD.

```
oc apply -f sandwich-operator/sandwich-crd.yml
```

2. Order a vegan sandwich.

```
oc apply -f sandwich-operator/sandwich-example.yml
```

## OLM

1. Get all operator sources availables.

```
oc get operatorsource -n openshift-marketplace
```

2. Get all operator in the list of package manifests for a source.

```
oc get packagemanifests -l "catalog=${operator_source}" -n openshift-marketplace
```

Get the `channel`, `catalog source` and the `install modes` from the package manifest.

```
oc describe packagemanifests <operator> -n openshift-marketplace
```

Subscribe to the operator.

```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: ${operator_name}
  namespace: ${operator_namespace}
spec:
  channel: ${operator_channel}
  installPlanApproval: Automatic # Or Manual
  name: ${operator_name}
  source: ${operator_source}
  sourceNamespace: openshift-marketplace
```

Get current operator status.

```
oc get csv -n ${operator_namespace}
```

## Sandwich operator

- https://github.com/kubernetes/sample-controller
- https://octetz.com/docs/2019/2019-10-13-controllers-and-operators/
