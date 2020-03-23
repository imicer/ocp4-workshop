# API Server

The API server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others.

## Change public certificate

The certificate must be issued for the URL used by the client to reach the API server and include the `subjectAltName` extension for the URL.

```yaml
apiVersion: config.openshift.io/v1
kind: APIServer
metadata:
  name: cluster
  annotations:
    release.openshift.io/create-only: "true" # Do not allow CVO to update the resource
spec:
  servingCerts:
    namedCertificates:
      - names:
          - ${OCP_API_SERVER}
        servingCertificate:
          name: api-server-public-cert
```

## Deployment

Apply the changes given by the previous configuration.

```bash
./install.sh
```

## References

- https://docs.openshift.com/container-platform/4.2/authentication/certificates/api-server.html
- https://access.redhat.com/solutions/4505101