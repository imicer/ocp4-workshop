# RBAC

Role-based access control (RBAC) is a method of regulating access to computer or network resources based on the roles of individual users within an enterprise. RBAC uses the `rbac.authorization.k8s.io` API Group to drive authorization decisions, allowing admins to dynamically configure policies through the API Server.

## Cluster-wide roles

In the RBAC API, a role contains rules that represent a set of permissions. Permissions are purely additive (there are no “deny” rules). A role can be defined within a namespace with a Role, or cluster-wide with a ClusterRole.

Create `cluster-wide` roles.

```
oc apply -f cluster-roles
```

## Cluster-wide bindings

A role binding grants the permissions defined in a role to a user or set of users. It holds a list of subjects (users, groups, or service accounts), and a reference to the role being granted. Permissions can be granted within a namespace with a RoleBinding, or cluster-wide with a ClusterRoleBinding.

Create `cluster-wide` bindings.

|   Cluster Binding   |  Cluster role  | User  |    Group     | Service Account |
| :-----------------: | :------------: | :---: | :----------: | :-------------: |
|  99-cluster-admins  | cluster-admin  |   -   |    DevOps    |        -        |
| 99-cluster-auditors | cluster-reader |   -   | Architecture |        -        |

```bash
oc apply -f cluster-bindings
```

Bind cluster-admin role to `recovery` user.

```bash
oc adm policy add-cluster-role-to-user cluster-admin recovery \
    --rolebinding-name=recovery-cluster-admin
```

## Disable project self-provisioning

Remove `system:authenticated:oauth` group from `self-provisioners` CRB.

```bash
oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'
```

Avoid CRB to be automatically updated.

```bash
oc annotate clusterrolebinding self-provisioners \
    "rbac.authorization.kubernetes.io/autoupdate=false" \
    --overwrite
```

## Remove kubeadmin user

After you define an identity provider and create a new cluster-admin user, you can remove the kubeadmin to improve cluster security.

**IMPORTANT**: If you follow this procedure before another user is a cluster-admin, then OpenShift Container Platform must be reinstalled. It is not possible to undo this command.

```bash
oc delete secret kubeadmin -n kube-system
```

## Deployment

Apply the changes given by the previous configuration.

```bash
./install.sh
```

## References

- https://docs.openshift.com/container-platform/4.2/authentication/using-rbac.html
