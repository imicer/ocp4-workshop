# Quarkus OCI image

Create a RESTful APIs with all CRUD operations (create, retrieve, update, delete) to manage a products list.

<!-- TOC -->

- [Quarkus OCI image](#quarkus-oci-image)
  - [Requirements](#requirements)
  - [Specification](#specification)
  - [Try application](#try-application)
  - [Operations](#operations)
    - [Get a list of products](#get-a-list-of-products)
    - [Create a new product](#create-a-new-product)
    - [Get a product](#get-a-product)
    - [Update a product](#update-a-product)
    - [Delete a product](#delete-a-product)
  - [Build and publish image to registry](#build-and-publish-image-to-registry)
  - [CI Pipeline](#ci-pipeline)
  - [References](#references)

<!-- /TOC -->

## Requirements

- OpenJDK >= 8
- Maven >= 3.5.3

Set the following variables.

```
export OCI_IMAGE_NAME="quarkus-example"
export OCI_IMAGE_TAG="v1.0.0-native"
export OCP_PROJECT="quarkus-example"
export OCP_REGISTRY_URL=$(oc get route public-access -n openshift-image-registry -o "custom-columns=URL:.spec.host" | grep -v URL)
export OCP_REGISTRY_TOKEN=$(oc get secret $(oc get sa builder -n ${OCP_PROJECT} -o json |\
  jq -r '.secrets[] | select(.name|test(".token.")) | .name') -n ${OCP_PROJECT} -o json |\
  jq -r '.data.token' | base64 -d)
```

## Specification

Each product has the following structure.

```json
{
  "name":"<product-name>",
  "id":"<product-id>"
}
```

## Try application

```bash
mvn compile quarkus:dev
```

## Operations

Set application url.

```
APP_URL="http://localhost:8080"
```

### Get a list of products

```
curl -X GET ${APP_URL} -s -k | jq '.'
```

### Create a new product

```
PRODUCT_NAME=""
curl -X POST -d '{"name":"'${PRODUCT_NAME}'"}' -H "Content-Type: application/json" ${APP_URL} -k
```

### Get a product

```
PRODUCT_ID=""
curl -X GET ${APP_URL}/${PRODUCT_ID} -s -k | jq '.'
```

### Update a product

```
PRODUCT_ID=""
PRODUCT_NAME=""
curl -X PATCH -d '{"name":"'${PRODUCT_NAME}'"}' -H "Content-Type: application/json" ${APP_URL}/${PRODUCT_ID} -k
```

### Delete a product

```
PRODUCT_ID=""
curl -X DELETE -H "Content-Type: application/json" ${APP_URL}/${PRODUCT_ID} -k
```

## Build and publish image to registry

1. Build the OCI image.

```
podman build -t ${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} -f oci/native/Dockerfile .
```

2. Login into Openshift registry.

```
podman login "https://${OCP_REGISTRY_URL}" \
  --username="builder" \
  --password="${OCP_REGISTRY_TOKEN}" \
  --tls-verify=false
```

3. Promote image to the registry.

```
podman push ${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} \
  ${OCP_REGISTRY_URL}/${OCP_PROJECT}/${OCI_IMAGE_NAME}:${OCI_IMAGE_TAG} \
  --tls-verify=false
```

## CI Pipeline

Automate all these steps in a single pipeline.

```
./ci-pipeline.sh
```

## References

- https://github.com/cescoffier/quarkus-deep-dive
- https://docs.openshift.com/container-platform/4.2/applications/projects/configuring-project-creation.html
