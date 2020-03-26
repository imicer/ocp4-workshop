# Kubernetes Basics

Deploy basic Kubernetes examples.

## Pod

Run a one-time pod using the imperative command.

```bash
oc run --rm -it pod-example --image=ubi8/ubi-minimal --restart=Never -- sh
```

Create a pod using the declarative command.

```bash
oc apply -f 01-pod
```

## Deployment

Create a deployment (deploy) using the imperative command.

```bash
oc run deployment-example --generator='deployment/apps.v1' --image=ubi8/ubi-minimal --replicas=3 \
    --command -- sleep 3600
```

Create a deployment using the imperative command.

```bash
oc apply -f 02-deployment
```

Force a deployment rollout.

```bash
oc rollout restart deployment-example
```

Get all deployment versions.

```bash
oc rollout history deploy/deployment-example
```

Rollback to a previous deployment version.

```bash
oc rollout undo deploy/deployment-example --to-revision=0
```

## ReplicaSet

A deployment will also create a `replicaset` that ensures that the specified number of replicas are always running. If a pod is deleted, it will be recreated immediately.

```bash
oc get replicaset
```

Increase or decrease the number of replicas.

```bash
oc scale deploy deployment-example --replicas=1
```

## Service

Expose the deployment with a service (svc) using the imperative command.

```bash
oc expose --name="service-example" \
    --port=8080 --target-port=8080 deploy/deployment-example
```

Create a service using the declarative command.

```bash
oc apply -f 03-svc
```

A Service is an abstraction which defines a logical set of pods and a policy by which to access them, it can be accessed using different endpoints across the cluster.

- `<service-name>` (same namespace)
- `<service-name>.<namespace-name>.svc` (different namespace)
- `<service-name>.<namespace-name>.svc.cluster.local` (different namespace)

## Configmap

Create a configmap (CM) using the imperative command.

```bash
oc create cm cm-example --from-file="04-configmap/data/config.json"
```

Create a configmap (CM) using the declarative command.

```bash
oc appy -f 04-configmap
```

## Secret

Create a secret using the imperative command.

```bash
oc create secret generic secret-example --from-file="05-secret/data/credentials.json"
```

Create a secret using the declarative command.

```bash
oc apply -f 05-secret
```

**IMPORTANT**: Secrets are used for storing sensitive information and they **[must never be stored as code](https://github.com/zricethezav/gitleaks)**. Use a dedicated tool like **[Vault](https://github.com/hashicorp/vault)** for storing sensitive information.

## Persistent volumes

Create a persistent volume claim (PVC) using the declarative command.

```bash
oc apply -f 06-pvc/<platform>
```

When a pod mounts this PVC, the volume is mounted in the node under the following path (see below) and the folder is shared with the pod according to the `.spec.template.spec.volumes` and `.spec.template.spec.container.volumeMounts` configuration.

```bash
/var
└── lib
    └── kubelet
        └── plugins
            └── kubernetes.io
                └── aws-ebs
                    └── mounts
                        └── aws
                            └── <aws-region>
                                └── <volume-id>
                                    └── <pvc files> # --volume nodePath:mountPath
```

## StatefulSet

Create an statefulset (STS) using the declarative command.

```bash
oc apply -f 07-sts
```

Measure write performance using **file storage**.

```bash
$ dd if=/dev/zero of=/tmp/shared-pvc/bytes.zero bs=50k count=10k
10240+0 records in
10240+0 records out
524288000 bytes (524 MB, 500 MiB) copied, 0.238921 s, 2.2 GB/s
```

Measure write performance using **block storage**.

```bash
$ dd if=/dev/zero of=/tmp/dedicated-pvc/bytes.zero bs=50k count=10k
10240+0 records in
10240+0 records out
524288000 bytes (524 MB, 500 MiB) copied, 0.335379 s, 1.6 GB/s
```

## References

- https://kubernetes.io/docs/concepts/workloads/pods/pod
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment
- https://kubernetes.io/docs/concepts/services-networking/service
- https://cloud.google.com/kubernetes-engine/docs/concepts/configmap
- https://kubernetes.io/docs/concepts/configuration/secret
- https://kubernetes.io/es/docs/concepts/workloads/controllers/statefulset