# Authentication

The OpenShift Container Platform master includes a built-in OAuth server. Users obtain OAuth access tokens to authenticate themselves to the API.

When a person requests a new OAuth token, the OAuth server uses the configured identity provider to determine the identity of the person making the request.

It then determines what user that identity maps to, creates an access token for that user, and returns the token for use.

## OAuth providers

There are many different OAuth providers available.

- HTPasswd
- LDAP
- OpenID
- BasicAuth
- Github
- Gitlab
- Google
- Keystone

Create the `OAuth` CR to configure identity providers.

```yaml
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
    - name: Example provider
      type: <provider>
```

### htpasswd

Create the configmap `htpasswd-users` with the passwd information in `openshift-config` namespace.

```yaml
spec:
  identityProviders:
    ...
    - name: Local authentication
      type: HTPasswd
      mappingMethod: claim
      htpasswd:
        fileData:
          name: htpasswd-users
```

## Deployment

Apply the changes given by the previous configuration.

```bash
./install.sh
```

## References

- https://docs.openshift.com/container-platform/4.2/authentication/identity_providers/configuring-ldap-identity-provider.html
- https://docs.openshift.com/container-platform/4.2/authentication/ldap-syncing.html
- https://github.com/redhat-cop/openshift-management/blob/master/jobs/cronjob-ldap-group-sync.yml
