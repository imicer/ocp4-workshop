# Ingress controller

Configure default ingress controller and deploy additional ones for consuming Openshift services from outside the cluster.

## Configuration

An ingress controller is a reverse proxy to route traffic from external requests to internal pods. The minimal specification for an ingress controller is the following.

```yaml
apiVersion: operator.openshift.io/v1
kind: IngressController
metadata:
  name: internal-apps
  namespace: openshift-ingress-operator
spec:
  replicas: 3
  domain: apps.example.internal
```

### Default certificate

A wildcard certificate can be used for those applications that do not use TLS. Generate or request a TLS certificate (tls.crt and tls.key) and create a secret from it.

```bash
oc create secret tls internal-apps-cert --cert=tls.crt --key=tls.key -n openshift-ingress
```

Add the certificate to the ingress controller specification.

```yaml
spec:
  ...
  defaultCertificate:
    name: internal-apps-cert
```

### Node placement

Select the nodes where the ingress controller pods will be running.

```yaml
spec:
  ...
  nodePlacement:
    nodeSelector:
      matchLabels:
        node-role.kubernetes.io/infra: ""
```

### Namespace selector

Restrict which namespaces can use an ingress controllers.

```yaml
spec:
  ...
  namespaceSelector:
    matchLabels:
      ingress-traffic.opentlc.com/internal: ""
```

### Route selector

Allow application to use different ingress controller to expose traffic.

```yaml
spec:
  ...
  routeSelector:
    matchLabels:
      route-type: internal
```

### Publishing strategy

Deploy the ingress controller base on to the environment features (baremetal or cloud provider).

- **Private**

It does not publish the ingress controller. In this configuration, the ingress controller deployment uses container networking, and is not explicitly published. The user must manually publish the ingress controller.

```yaml
  ...
  endpointPublishingStrategy:
    type: Private
    private: {}
```

- **HostNetwork**

It publishes the ingress controller on node ports where the ingress controller is deployed. In this configuration, the ingress controller deployment uses host networking, bound to node ports 80 and 443. The user is responsible for configuring an external load balancer to publish the ingress controller via the node ports.

```yaml
  ...
  endpointPublishingStrategy:
    type: HostNetwork
    hostNetwork: {}
```

- **LoadBalancerService**

Publishes the ingress controller using a Kubernetes LoadBalancer Service. In this configuration, the ingress controller deployment uses container networking but LoadBalancer Service is created (see https://kubernetes.io/docs/concepts/services-networking/#loadbalancer).

If domain is set, a wildcard DNS record will be managed to point at the LoadBalancer Service's external name. DNS records are managed only in DNS zones defined by `dns.config.openshift.io/cluster` (`.spec.publicZone` and `.spec.privateZone`).

```yaml
  ...
  endpointPublishingStrategy:
    type: LoadBalancerService
    loadBalancer:
      scope: External/Internal
```

**IMPORTANT**: Wildcard DNS management is currently supported only on the AWS platform.

## Deployment

Apply the changes given by the previous configuration.

```bash
./install.sh <environment-name>
```

## References

- https://docs.openshift.com/container-platform/4.2/networking/ingress-operator.html
