apiVersion: v1
metadata:
  creationTimestamp: null
  name: ${OCP_CLUSTER_NAME}
baseDomain: ${OCP_BASE_DOMAIN}
platform:
  aws:
    region: ${AWS_REGION}
compute:
  - hyperthreading: Enabled
    name: worker
    platform: {}
    replicas: 3
controlPlane:
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
networking:
  clusterNetwork:
    - cidr: ${OCP_CONTAINERS_CIDR}
      hostPrefix: 23
  machineCIDR: ${AWS_VPC_CIDR}
  networkType: OpenShiftSDN
  serviceNetwork:
    - ${OCP_SVC_CIDR}
pullSecret: '${OCP_PULL_SECRET}'
sshKey: ${OCP_SSH_PUBKEY}
