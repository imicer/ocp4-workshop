#cloud-config
preserve_hostname: false
fqdn: bastion-ocp

# Allow management users to login using SSH key
users:
  - name: maintuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: wheel
    ssh_authorized_keys:
      - ${OCP_SSH_PUBKEY}
