# OCP4 installation

Install OPC 4 in AWS using IPI procedure.

## Requirements

- OpenTLC account.

## Installation

1. Load environment configuration.

```
source environment/<env>
```

2. Connect to the bastion using SSH.

```
ssh ${BASTION_SSH_USER}@${BASTION_SSH_HOST}
```

3. Create installation directories.

```
mkdir -p ocp-installer/configuration
```

4. Download the installer from **[Red Hat official site](https://mirror.openshift.com/pub/openshift-v4/clients/ocp)**.

```
wget https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.2.16/openshift-install-linux-4.2.16.tar.gz
```

5. Extract the installer.

```
tar -xvf openshift-install-linux-4.2.16.tar.gz
```

6. Render installer configuration.

```
envsubst < configuration/install-config.yaml.tpl > configuration/install-config.yaml
```

7. Copy  `install-config.yaml` into bastion.

```
scp configuration/install-config.yaml ${BASTION_SSH_USER}@${BASTION_SSH_HOST}:ocp-installer/configuration
```

8. Run installer to generate manifest files (must introduce AWS credentials).

```
./openshift-install create manifests --dir=configuration --log-level=debug
```

9. Run installer to generate ignition from manifest files.

```
./openshift-install create ignition-configs --dir=configuration --log-level=debug
```

10. Finally, run the installer to setup the cluster.

```
./openshift-install create cluster --dir=configuration --log-level=debug
```

## Additional bastion

1. Create a new instance with the following options.

- **Network**: Select OCP VPC.
- **Subnet**: Select any public subnet.
- **Auto-asign Public IP**: Enable.
- **Capacity reservation**: None.

2. Set userdata to allow SSH.

```
envsubst < bastion/cloudinit.tpl | xsel -ib
```

## References

- https://docs.openshift.com/container-platform/4.2/installing/installing_aws
- https://cloud.redhat.com/openshift/install/aws/installer-provisioned
