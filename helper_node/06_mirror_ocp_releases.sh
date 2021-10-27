#!/bin/bash

UPSTREAM_REGISTRY=quay.io
PRODUCT_REPO=openshift-release-dev
RELEASE_NAME=ocp-release
LOCAL_REGISTRY=$(hostname -f):5000

OCP_RELEASE=$(curl -v --silent https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/latest/release.txt --stderr - |grep ^Name: |awk '{ print $2 }')

# Login into podman registry
podman login $(hostname -f):5000 -u kni -p kni --authfile ${LOCAL_SECRET_JSON}

# Mirror the release
# Potential improvement: Check tags using curl and only mirror if release has not been already mirrored
${BIN_PATH}/oc adm -a ${LOCAL_SECRET_JSON} release mirror --from=${UPSTREAM_REGISTRY}/${PRODUCT_REPO}/${RELEASE_NAME}:${OCP_RELEASE}-x86_64 --to=${LOCAL_REGISTRY}/ocp4 --to-release-image=${LOCAL_REGISTRY}/ocp4/release:${OCP_RELEASE}


