# Projects

The project is the organizational unit for different OCP components.

## Disable project self-provisioning

Remove `system:authenticated:oauth` group from `self-provisioners` CRB.

```
oc patch clusterrolebinding.rbac self-provisioners -p '{"subjects": null}'
```

Avoid CRB to be automatically updated.

```
oc annotate clusterrolebinding self-provisioners \
    "rbac.authorization.kubernetes.io/autoupdate=false" \
    --overwrite
```

## Project templating

Default settings for a project can be inherited from a `Template`. When a project is created with `oc new-project <name>` or from the web console, the default template is applied with the custom configuration.

**NOTE**: The default template will not be applied if the project is created from a `YAML` manifest.

Create the default `Template`.

```
oc apply -f default-template/project.yml
```

Set this template as the default one for new projects.

```
oc patch project.config cluster \
    --type=merge \
    --patch \
    '{"spec":{"projectRequestTemplate":{"name":"default-project-template"}}}'
```

## Kustomize

Create projects (and any other Kubernetes deployment) using raw, template-free YAML files for multiple purposes, leaving the original YAML untouched and usable as is.

```
projects
├── kustomization.yml
├── base
│   ├── kustomization.yml
│   └── manifests
│       ├── network-policies
│       │   └── *.yml
│       ├── rbac
│       │   └── *.yml
│       └── service-accounts
│           └── *.yml
└── overlay
    ├── project1
    │   ├── kustomization.yml
    │   └── manifests
    │       └── *.yml
    └── project2
        ├── kustomization.yml
        └── manifests
            └── *.yml
```

### Create projects

Just run the following command.

```
oc kustomize projects | oc apply -f -
```

### Service account tokens

- Get token for centralized deployments.

```
OCP_API_TOKEN="$(oc get secret $(oc get sa cicd-deployer-root -n cicd -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -n cicd -o json |\
  jq -r '.data.token' | base64 -d)"
```

- Get token for isolated deployments.

```
OCP_PROJECT="quarkus-example"
OCP_SERVICE_ACCOUNT="cicd-deployer"

OCP_API_TOKEN="$(oc get secret $(oc get sa ${OCP_SERVICE_ACCOUNT} -n ${OCP_PROJECT} -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -n ${OCP_PROJECT} -o json |\
  jq -r '.data.token' | base64 -d)"
```

- Authenticate against Openshift API.

```
oc login --server=${OCP_API_URL} --token=${OCP_API_TOKEN}
```

## References

- https://docs.openshift.com/container-platform/4.2/applications/projects/configuring-project-creation.html
