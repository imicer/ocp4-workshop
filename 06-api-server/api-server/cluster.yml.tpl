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
