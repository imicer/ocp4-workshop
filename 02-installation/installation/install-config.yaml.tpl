apiVersion: v1
metadata:
  name: ${OCP_CLUSTER_NAME}
baseDomain: ${OCP_DNS_DOMAIN}
controlPlane:
  name: master
  replicas: 3
  architecture: amd64
  hyperthreading: Enabled
  platform: {}
compute:
  - name: worker
    replicas: 3
    architecture: amd64
    hyperthreading: Enabled
    platform: {}
networking:
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  machineCIDR: 10.0.0.0/16
  networkType: OpenShiftSDN
  serviceNetwork:
    - 172.30.0.0/16
platform:
  aws:
    region: ${AWS_REGION}
pullSecret: '${OCP_PULL_SECRET}'
sshKey: ${OCP_SSH_PUBKEY}