# Machine API

This allows to convey desired state of machines in a cluster in a declarative fashion.

## Create new node pool

Create a new machineset to create a set of machines for a new pool of nodes (see machineset folder).

In cloud providers, the ignition is loaded from `user-data` attribute. It loads the ignition content from the machine-config server (port 22623 in master nodes).

```json
{
    "ignition": {
        "version": "2.2.0",
        "timeouts": {},
        "config": {
            "append": [
                {
                    "source": "https://${OCP_API_URL}:22623/config/pool",
                    "verification": {}
                }
            ]
        },
        "security": {
            "tls": {
                "certificateAuthorities": [
                    {
                        "source": "data:text/plain;charset=utf-8;base64,${OCP_API_CA}",
                        "verification": {}
                    }
                ]
            }
        }
    },
    "networkd": {},
    "passwd": {},
    "storage": {},
    "systemd": {}
}
```

## Scale up/down number of nodes

```bash
oc scale machineset <machineset-name> --replicas=X
```

## Automation

Apply the changes given by the previous configuration.

```bash
./install.sh <cloud-provider> <cluster-id> <datacenter-id>
```

## References

- https://github.com/openshift/machine-config-operator