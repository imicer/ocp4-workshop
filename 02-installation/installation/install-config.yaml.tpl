apiVersion: v1
metadata:
  name: ${OCP_CLUSTER_NAME}
baseDomain: ${OCP_DNS_DOMAIN}
platform:
  aws:
    region: ${AWS_REGION}
    userTags:
      environment: opentlc
fips: true
publish: External
controlPlane:
  name: master
  replicas: 3
  hyperthreading: Enabled
  platform:
    aws:
      zones:
        - ${AWS_REGION}a
        - ${AWS_REGION}b
        - ${AWS_REGION}c
      rootVolume:
        iops: 4000
        size: 120
        type: io1
      type: m5.xlarge
compute:
  - name: worker
    replicas: 2
    hyperthreading: Enabled
    platform:
      aws:
      zones:
        - ${AWS_REGION}a
        - ${AWS_REGION}b
        - ${AWS_REGION}c
      rootVolume:
        iops: 2000
        size: 120
        type: io1
      type: c5.xlarge
networking:
  networkType: OVNKubernetes
  machineNetwork:
    - cidr: 10.0.0.0/16
  clusterNetwork:
    - cidr: 10.128.0.0/14
      hostPrefix: 23
  serviceNetwork:
    - 172.30.0.0/16
pullSecret: '${OCP_PULL_SECRET}'
sshKey: ${OCP_SSH_PUBKEY}