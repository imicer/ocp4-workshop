# RBAC

Define roles and bindings for authorization and access control.

3. Add `cluster-admin` role to user `recovery`.

```
oc adm policy add-cluster-role-to-user cluster-admin recovery \
  --rolebinding-name=recovery-cluster-admin
```

Deploy OAuth configuration.

```bash
oc apply -f oauth/cluster-oauth.yml
```

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
