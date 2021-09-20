#!/bin/bash

BIN_PATH=${BASEDIR}/bin
ASSETS_PATH=${BASEDIR}/assets
CLUSTER_PATH=${BASEDIR}/${cluster_name}
LOCAL_SECRET_JSON=${ASSETS_PATH}/pull_secret.json

UPSTREAM_REGISTRY=quay.io
PRODUCT_REPO=openshift-release-dev
RELEASE_NAME=ocp-release
LOCAL_REGISTRY=$(hostname -f):5000

# Login into podman registry
podman login $(hostname -f):5000 -u kni -p kni --authfile ${LOCAL_SECRET_JSON}

# Mirror the release
# Potential improvement: Check tags using curl and only mirror if release has not been already mirrored
${BIN_PATH}/oc adm -a ${LOCAL_SECRET_JSON} release mirror --from=${UPSTREAM_REGISTRY}/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE} --to=${LOCAL_REGISTRY}/ocp4 --to-release-image=${LOCAL_REGISTRY}/ocp4/release:${OCP_RELEASE}


