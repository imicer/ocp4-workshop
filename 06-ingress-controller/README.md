# Ingress controller

Deploy additional ingress controllers for consuming Openshift services from out of the cluster.

## Requirements

1. Load environment configuration.

```
source environment/<env>
```

## Default

Move default ingress controller to `infra` nodes.

```
oc patch ingresscontroller default \
    --type=merge \
    --patch '{"spec":{"nodePlacement":{"nodeSelector":{"matchLabels":{"node-role.kubernetes.io/infra":""}}}}}' \
    --namespace openshift-ingress-operator
```

## Internal applications

Deploy a new ingress controller for internal applications.

### Generate certificate

Generate certificate private key for internal applications.

```
openssl genrsa 4096 > certificates/internal-apps/tls.key
```

Generate self-signed certificate for the wildcard domain (e.g. *.apps.opentlc.internal).

```
openssl req -new -x509 -nodes -sha1 -days 365 \
    -key certificates/internal-apps/tls.key > certificates/internal-apps/tls.crt
```

### Deploy ingress controller

Create secret from TLS certificate.

```
oc create secret tls internal-apps-cert \
  --cert=certificates/internal-apps/tls.crt \
  --key=certificates/internal-apps/tls.key \
  --namespace openshift-ingress
```

Deploy ingress controller.

```
envsubst < manifests/internal-apps.yml | oc apply -f -
```

### Create a DNS entry for LB

1. Create DNS hosted zone.

```
aws route53 create-hosted-zone \
  --name="${INTERNAL_APPS_DNS_DOMAIN}" \
  --vpc=VPCRegion="${AWS_REGION}",VPCId="${AWS_VPC_ID}" \
  --hosted-zone-config=PrivateZone=true,Comment="MANUAL" \
  --caller-reference="$(uuidgen)"
```

2. Create a new DNS record to send traffic to ingress controller LB.

## References

- https://docs.openshift.com/container-platform/4.2/networking/ingress-operator.html
