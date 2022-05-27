#!/bin/bash

BASEDIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

export OCP_RELEASE=$(oc version -o json  --client | jq -r '.releaseClientVersion')
export LOCAL_REGISTRY=$(hostname -f):5000
export LOCAL_REGISTRY_OLM=$(hostname -f):5000/olm
export REGISTRY_AUTH_FILE=${BASEDIR}/assets/pull_secret.json
export REDHAT_DEFAULT_REGISTRY=registry.redhat.io
export OCP_RELEASE_SHORT=${OCP_RELEASE%\.*}

declare -A remote_index
remote_index["redhat_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/redhat-operator-index:v${OCP_RELEASE_SHORT}"
remote_index["certified_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/certified-operator-index:v${OCP_RELEASE_SHORT}"
remote_index["community_operator"]="${REDHAT_DEFAULT_REGISTRY}/redhat/community-operator-index:v${OCP_RELEASE_SHORT}"

declare -A local_index
local_index["redhat_operator"]="${LOCAL_REGISTRY}/olm-index/redhat-operator-index:v${OCP_RELEASE_SHORT}"
local_index["certified_operator"]="${LOCAL_REGISTRY}/olm-index/certified-operator-index:v${OCP_RELEASE_SHORT}"
local_index["community_operator"]="${LOCAL_REGISTRY}/olm-index/community-operator-index:v${OCP_RELEASE_SHORT}"

declare -A packages
packages["redhat_operator"]="local-storage-operator,ocs-operator,performance-addon-operator,ptp-operator,sriov-network-operator,advanced-cluster-management,performance-addon-operator,openshift-gitops-operator"
packages["certified_operator"]="sriov-fec,n3000"
packages["community_operator"]="hive-operator"

# Disable all default CatalogSource
oc patch OperatorHub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'

# redhat-operator
redhat_operator(){
  # build index
  opm index prune --from-index ${remote_index[redhat_operator]} --packages ${packages[redhat_operator]} --tag ${local_index[redhat_operator]} --permissive
  GODEBUG=x509ignoreCN=0 podman push ${local_index[redhat_operator]}
  # mirror images
  GODEBUG=x509ignoreCN=0 oc adm catalog mirror ${local_index[redhat_operator]} ${LOCAL_REGISTRY_OLM} -a ${REGISTRY_AUTH_FILE} --max-components=5 --to-manifests=redhat-operator-index/

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators
  namespace: openshift-marketplace
spec:
  displayName: Red Hat Operators Mirror
  image: ${local_index[redhat_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  if [ -s redhat-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f redhat-operator-index/imageContentSourcePolicy.yaml
  fi
}

# certified-operator
certified_operator(){
  # build index
  opm index prune --from-index ${remote_index[certified_operator]} --packages ${packages[certified_operator]} --tag ${local_index[certified_operator]} --permissive
  GODEBUG=x509ignoreCN=0 podman push ${local_index[certified_operator]}
  # mirror images
  GODEBUG=x509ignoreCN=0 oc adm catalog mirror ${local_index[certified_operator]} ${LOCAL_REGISTRY_OLM} -a ${REGISTRY_AUTH_FILE} --max-components=5 --to-manifests=certified-operator-index/

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: certified-operators
  namespace: openshift-marketplace
spec:
  displayName: Certified Operators Mirror
  image: ${local_index[certified_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  if [ -s certified-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f certified-operator-index/imageContentSourcePolicy.yaml
  fi

}

# community-operator
community_operator(){
  # build index
  opm index prune --from-index ${remote_index[community_operator]} --packages ${packages[community_operator]} --tag ${local_index[community_operator]} --permissive
  GODEBUG=x509ignoreCN=0 podman push ${local_index[community_operator]}
  # mirror images
  GODEBUG=x509ignoreCN=0 oc adm catalog mirror ${local_index[community_operator]} ${LOCAL_REGISTRY_OLM} -a ${REGISTRY_AUTH_FILE} --max-components=5 --to-manifests=community-operator-index/

  # Create CatalogSource
  oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: community-operators
  namespace: openshift-marketplace
spec:
  displayName: Community Operators Mirror
  image: ${local_index[community_operator]}
  publisher: Red Hat
  sourceType: grpc
EOF

  if [ -s community-operator-index/imageContentSourcePolicy.yaml ]; then
    oc apply -f community-operator-index/imageContentSourcePolicy.yaml
  fi
}

redhat_operator
#certified_operator
#community_operator
