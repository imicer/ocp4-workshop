# Quarkus deployment

Deploy a RESTful APIs with all CRUD operations (create, retrieve, update, delete) to manage a products list.

<!-- TOC -->

- [Quarkus deployment](#quarkus-deployment)
  - [Deploy application](#deploy-application)
  - [CD Pipeline](#cd-pipeline)
  - [References](#references)

<!-- /TOC -->

## Deploy application

1. Deploy application in Openshift.

```
oc apply -f manifests -n ${OCP_PROJECT}
```

2. Add internal route to `/etc/hosts`.

```
echo "127.0.0.1 ${APP_URL}" >> /etc/hosts
```

3. Use bastion to forward HTTP traffic (ensure security group is open).

```
ssh -N -L 8443:${APP_URL}:443 -i ${BASTION_SSH_KEY} ${BASTION_SSH_USER}@${BASTION_PUBLIC_IP}
```

4. Go to **https://quarkus-example.apps.opentlc.internal:8443**

## CD Pipeline

Automate all these steps in a single pipeline.

```
./cd-pipeline.sh
```

## References

- https://github.com/cescoffier/quarkus-deep-dive
- https://docs.openshift.com/container-platform/4.2/applications/projects/configuring-project-creation.html
