#!/bin/bash

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export OCP_RELEASE=$(oc version -o json  --client | jq -r '.releaseClientVersion')
export LOCAL_REGISTRY=$(hostname -f):5000
export REGISTRY_AUTH_FILE=${BASEDIR}/pull_secret.json
export RELEASE_NAME="ocp-release"
export ARCHITECTURE=x86_64
export REDHAT_DEFAULT_REGISTRY=registry.redhat.io

declare -A indices
indices["certified_operator"]="redhat/certified-operator-index"
indices["redhat_operator"]="redhat/redhat-operator-index"
indices["community_operator"]="redhat/community-operator-index"

declare -A packages
packages["certified_operator"]="local-storage-operator,ocs-operator,performance-addon-operator,ptp-operator,sriov-network-operator,advanced-cluster-management,performance-addon-operator,openshift-gitops-operator"
packages["redhat_operator"]="sriov-fec,n3000"
packages["community_operator"]="hive-operator"

OCP_RELEASE_SHORT=${OCP_RELEASE%\.*}

# Disable all default CatalogSource
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# certified-operator
certified_operator(){
  # build index
  opm index prune \
      -f ${REDHAT_DEFAULT_REGISTRY}/${indices[certified_operator]}:v${OCP_RELEASE_SHORT} \
      -p ${packages[certified_operator]} \
      -t ${LOCAL_REGISTRY}/${indices[certified_operator]}:v${OCP_RELEASE_SHORT}

  podman push ${LOCAL_REGISTRY}/${indices[certified_operator]}:v${OCP_RELEASE_SHORT}

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: certified-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: Certified Operators Mirror
  image: ${LOCAL_REGISTRY}/${indices[certified_operator]}:v${OCP_RELEASE_SHORT}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${LOCAL_REGISTRY}/${indices[certified_operator]}:v${OCP_RELEASE_SHORT} \
      ${LOCAL_REGISTRY}/olm \
      -a ${REGISTRY_AUTH_FILE} \
      --max-components=5 \
      --to-manifests=certified-operator-index/

  if [ -s certified-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f certified-operator-index/imageContentSourcePolicy.yaml
  else
      oc image mirror \
        -a ${REGISTRY_AUTH_FILE} \
        --skip-multiple-scopes=true \
        -f certified-operator-index/mapping.txt
  fi

}

# redhat-operator
redhat_operator(){
  opm index prune \
      -f ${REDHAT_DEFAULT_REGISTRY}/${indices[redhat_operator]}:v${OCP_RELEASE_SHORT} \
      -p ${packages[redhat_operator]} \
      -t ${LOCAL_REGISTRY}/${indices[redhat_operator]}:v${OCP_RELEASE_SHORT}

  podman push ${LOCAL_REGISTRY}/${indices[redhat_operator]}:v${OCP_RELEASE_SHORT}

# Create CatalogSource
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: Red Hat Operators Mirror
  image: ${LOCAL_REGISTRY}/${indices[redhat_operator]}:v${OCP_RELEASE_SHORT}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${LOCAL_REGISTRY}/${indices[redhat_operator]}:v${OCP_RELEASE_SHORT} \
      ${LOCAL_REGISTRY}/olm \
      -a ${REGISTRY_AUTH_FILE} \
      --max-components=5 \
      --to-manifests=redhat-operator-index/

  if [ -s redhat-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f redhat-operator-index/imageContentSourcePolicy.yaml
  else
      oc image mirror \
        --skip-multiple-scopes=true \
        -a ${REGISTRY_AUTH_FILE} \
        -f redhat-operator-index/mapping.txt
  fi
}

# community-operator
community_operator(){
  opm index prune \
      -f ${REDHAT_DEFAULT_REGISTRY}/${indices[community_operator]}:v${OCP_RELEASE_SHORT} \
      -p ${packages[community_operator]} \
      -t ${LOCAL_REGISTRY}/${indices[community_operator]}:v${OCP_RELEASE_SHORT}

  podman push ${LOCAL_REGISTRY}/${indices[community_operator]}:v${OCP_RELEASE_SHORT}

# Create CatalogSource
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: community-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: Community Operators Mirror
  image: ${LOCAL_REGISTRY}/${indices[community_operator]}:v${OCP_RELEASE_SHORT}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${LOCAL_REGISTRY}/${indices[community_operator]}:v${OCP_RELEASE_SHORT} \
      ${LOCAL_REGISTRY}/olm \
      -a ${REGISTRY_AUTH_FILE} \
      --max-components=5 \
      --to-manifests=community-operator-index/

  if [ -s community-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f community-operator-index/imageContentSourcePolicy.yaml
  else
      oc image mirror \
        --skip-multiple-scopes=true \
        -a ${REGISTRY_AUTH_FILE} \
        -f community-operator-index/mapping.txt
  fi

}

certified_operator
redhat_operator
#community_operator
