apiVersion: imageregistry.operator.openshift.io/v1
kind: Config
metadata:
  name: cluster
spec:
  managementState: Managed
  replicas: 1
  defaultRoute: true
  disableRedirect: false
  readOnly: false
  httpSecret: ${REGISTRY_HTTP_SECRET}
  logging: 2
  storage:
    pvc:
      claim: registry-images-0
  nodeSelector:
    node-role.kubernetes.io/infra: ""
  requests:
    read:
      maxInQueue: 0
      maxRunning: 0
      maxWaitInQueue: 0s
    write:
      maxInQueue: 0
      maxRunning: 0
      maxWaitInQueue: 0s
  proxy:
    http: ""
    https: ""
    noProxy: ""