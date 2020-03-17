# RBAC

Define roles and bindings for authorization and access control.

## Roles

Create `cluster-wide` roles.

```
oc apply -f cluster-roles
```

## Cluster-wide bindings

Create `cluster-wide` role bindings.

```
oc apply -f cluster-bindings
```

## Project bindings

Create `project` role bindings.

```
oc apply -f project-bindings/<role-binding> -n <namespace>
```

## References

- https://docs.openshift.com/container-platform/4.2/authentication/using-rbac.html
