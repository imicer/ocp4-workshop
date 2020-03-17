# Install Openshift 4.2 IPI

## Instrucctions

Create a `environment-name.env` file with the specific environment configuration parameters.

### Openshift 4

Set configuration parameters for `Openshift`.

```bash
OCP_CLUSTER_NAME="ocp"
OCP_DNS_DOMAIN="sandbox1467.opentlc.com"
OCP_PULL_SECRET='{"auths":{"cloud.openshift.com":{"auth":"...'
OCP_SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EA..."
```

### Cloud provider

Set configuration parameters for the corresponding `cloud provider`.

```bash
AWS_REGION="eu-central-1"
AWS_ACCESS_KEY="1234"
AWS_SECRET_KEY="S3CR3T!"
```

## Installation

Run the autonomus installer and wait until the installation is finished.

```bash
./install.sh <environment-name>
```

## SSH bastion

Create a new instance with the following options.

- **Network**: Select OCP VPC.
- **Subnet**: Select any public subnet.
- **Auto-asign Public IP**: Enable.
- **Capacity reservation**: None.

Set userdata to allow SSH.

```bash
envsubst < bastion/cloudinit.tpl
```

## References

- https://docs.openshift.com/container-platform/4.2/welcome/index.html