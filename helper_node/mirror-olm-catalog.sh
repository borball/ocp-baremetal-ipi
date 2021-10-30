#!/bin/bash

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export OCP_RELEASE=$(oc version -o json  --client | jq -r '.releaseClientVersion')
export LOCAL_REGISTRY=$(hostname -f):5000
export LOCAL_REGISTRY_OLM=$(hostname -f):5000/olm
export REGISTRY_AUTH_FILE=${BASEDIR}/pull_secret.json
export RELEASE_NAME="ocp-release"
export ARCHITECTURE=x86_64
export REDHAT_DEFAULT_REGISTRY=registry.redhat.io
export OCP_RELEASE_SHORT=${OCP_RELEASE%\.*}

declare -A remote_index
remote_index["certified_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/certified-operator-index:v${OCP_RELEASE_SHORT}"
remote_index["redhat_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/redhat-operator-index:v${OCP_RELEASE_SHORT}"
remote_index["community_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/community-operator-index:v${OCP_RELEASE_SHORT}"

declare -A local_index
local_index["certified_operator"]="${LOCAL_REGISTRY}/olm-index/certified-operator-index:v${OCP_RELEASE_SHORT}"
local_index["redhat_operator"]="${LOCAL_REGISTRY}/olm-index/redhat-operator-index:v${OCP_RELEASE_SHORT}"
local_index["community_operator"]="${LOCAL_REGISTRY}/olm-index/community-operator-index:v${OCP_RELEASE_SHORT}"

declare -A packages
packages["certified_operator"]="local-storage-operator,ocs-operator,performance-addon-operator,ptp-operator,sriov-network-operator,advanced-cluster-management,performance-addon-operator,openshift-gitops-operator"
packages["redhat_operator"]="sriov-fec,n3000"
packages["community_operator"]="hive-operator"


# Disable all default CatalogSource
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# certified-operator
certified_operator(){
  # build index
  opm index prune -f ${remote_index[certified_operator]} -p ${packages[certified_operator]} -t ${local_index[certified_operator]}
  podman push ${local_index[certified_operator]}

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: certified-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: Certified Operators Mirror
  image: ${local_index[certified_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${local_index[certified_operator]} \
      ${LOCAL_REGISTRY_OLM} \
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
  # build index
  opm index prune -f ${remote_index[redhat_operator]} -p ${packages[redhat_operator]} -t ${local_index[redhat_operator]}
  podman push ${local_index[redhat_operator]}

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: RedHat Operators Mirror
  image: ${local_index[redhat_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${local_index[redhat_operator]} \
      ${LOCAL_REGISTRY_OLM} \
      -a ${REGISTRY_AUTH_FILE} \
      --max-components=5 \
      --to-manifests=redhat-operator-index/

  if [ -s redhat-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f redhat-operator-index/imageContentSourcePolicy.yaml
  else
      oc image mirror \
        -a ${REGISTRY_AUTH_FILE} \
        --skip-multiple-scopes=true \
        -f redhat-operator-index/mapping.txt
  fi
}

# community-operator
community_operator(){
  # build index
  opm index prune -f ${remote_index[community_operator]} -p ${packages[community_operator]} -t ${local_index[community_operator]}
  podman push ${local_index[community_operator]}

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: community-operators-mirror
  namespace: openshift-marketplace
spec:
  displayName: Community Operators Mirror
  image: ${local_index[community_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  # mirror images
  oc adm catalog mirror \
      ${local_index[community_operator]} \
      ${LOCAL_REGISTRY_OLM} \
      -a ${REGISTRY_AUTH_FILE} \
      --max-components=5 \
      --to-manifests=community-operator-index/

  if [ -s community-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f community-operator-index/imageContentSourcePolicy.yaml
  else
      oc image mirror \
        -a ${REGISTRY_AUTH_FILE} \
        --skip-multiple-scopes=true \
        -f community-operator-index/mapping.txt
  fi
}

certified_operator
redhat_operator
#community_operator
