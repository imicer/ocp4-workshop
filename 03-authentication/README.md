# Authentication

Configure authentication providers (local authentication, LDAP, OIDC, etc).

## Local authentication

1. Create `htpasswd` with all users.

```
htpasswd -B -b users/htpasswd recovery *****
htpasswd -B -b users/htpasswd platform-admin-a *****
htpasswd -B -b users/htpasswd architect-a *****
htpasswd -B -b users/htpasswd developer-a *****
```

2. Create `htpass-users` secret.

```
oc create secret generic htpass-users \
    --from-file=htpasswd=users/htpasswd \
    --namespace openshift-config
```

3. Add `cluster-admin` role to user `recovery`.

```
oc adm policy add-cluster-role-to-user cluster-admin recovery \
  --rolebinding-name=recovery-cluster-admin
```

## Deploy Oauth

1. Deploy OAuth configuration.

```
oc apply -f oauth/cluster-oauth.yml
```

2. Remove `kubeadmin` user (optional).

```
oc delete secret kubeadmin -n kube-system
```

## References

- https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-ldap-identity-provider.html
- https://docs.openshift.com/container-platform/4.2/authentication/ldap-syncing.html
- https://github.com/redhat-cop/openshift-management/blob/master/jobs/cronjob-ldap-group-sync.yml
