apiVersion: machine.openshift.io/v1beta1
kind: MachineSet
metadata:
  labels:
    machine.openshift.io/cluster-api-cluster: ${OCP_CLUSTER_ID}
  name: ${OCP_CLUSTER_ID}-infra-${OCP_NODE_AZ}
  namespace: openshift-machine-api
spec:
  replicas: 1
  selector:
    matchLabels:
      machine.openshift.io/cluster-api-cluster: ${OCP_CLUSTER_ID}
      machine.openshift.io/cluster-api-machineset: ${OCP_CLUSTER_ID}-infra-${OCP_NODE_AZ}
  template:
    metadata:
      creationTimestamp: null
      labels:
        machine.openshift.io/cluster-api-cluster: ${OCP_CLUSTER_ID}
        machine.openshift.io/cluster-api-machine-role: infra
        machine.openshift.io/cluster-api-machine-type: infra
        machine.openshift.io/cluster-api-machineset: ${OCP_CLUSTER_ID}-infra-${OCP_NODE_AZ}
    spec:
      metadata:
        creationTimestamp: null
      providerSpec:
        value:
          apiVersion: awsproviderconfig.openshift.io/v1beta1
          kind: AWSMachineProviderConfig
          metadata:
            creationTimestamp: null
          instanceType: m5.4xlarge # OCS requirement
          ami:
            id: ami-092b69120ecf915ed
          iamInstanceProfile:
            id: ${OCP_CLUSTER_ID}-worker-profile
          userDataSecret:
            name: infra-user-data
          credentialsSecret:
            name: aws-cloud-credentials
          blockDevices:
            - ebs:
                iops: 0
                volumeSize: 120
                volumeType: gp2
          deviceIndex: 0
          placement:
            availabilityZone: ${OCP_NODE_AZ}
            region: ${OCP_CLUSTER_DATACENTER}
          subnet:
            filters:
              - name: tag:Name
                values:
                  - ${OCP_CLUSTER_ID}-private-${OCP_NODE_AZ}
          publicIp: null
          securityGroups:
            - filters:
                - name: tag:Name
                  values:
                    - ${OCP_CLUSTER_ID}-worker-sg
          tags:
            - name: kubernetes.io/cluster/${OCP_CLUSTER_ID}
              value: owned
            - name: node-role.kubernetes.io
              value: infra
