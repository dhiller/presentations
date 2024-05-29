set -exo pipefail

SCRIPT_PATH="$(
    cd "$(dirname "$BASH_SOURCE[0]")/"
    echo "$(pwd)/"
)"

CWD=$(pwd)

cd $GH/kubevirt.io/kubevirtci

# kubevirtci configuration variables

# fix kubevirtci tag due to regression
export KUBEVIRTCI_TAG=2208120024-700826c

export KUBEVIRT_NUM_NODES=2
export KUBEVIRT_PROVIDER=k8s-1.24

export KUBEVIRT_DEPLOY_CDI=true
export KUBEVIRT_STORAGE=rook-ceph-default
export KUBEVIRT_DEPLOY_PROMETHEUS=true
export KUBEVIRT_DEPLOY_GRAFANA=true

make cluster-up

cd ${CWD}

# since we are running inside kubevirtci
export KUBECONFIG=$($GH/kubevirt.io/kubevirtci/cluster-up/kubeconfig.sh)

# export kubevirtci grafana and prometheus service
# http://localhost:30008/?orgId=1
kubectl port-forward -n monitoring service/grafana-nodeport 30008:3000 &
# http://localhost:30007/graph
kubectl port-forward -n monitoring service/prometheus-nodeport 30007:9090 &


if [[ -z "$KUBEVIRT_RELEASE" ]]; then
    # stable.txt contains the latest stable version of KubeVirt
    export KUBEVIRT_RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt \
    | grep -oE '([0-9]+\.[0-9]+)' )
fi

# prepare a shared directory for the install
export SHARED_DIR=$(mktemp -d)

KUBEVIRT_TESTING_PATH=$GH/dhiller/kubevirt-testing

# use deployment script that adds the testing resources (i.e. uploadproxy)
# note that deployment script needs `oc` binary because it was not generalized yet
${KUBEVIRT_TESTING_PATH}/hack/kubevirt-testing.sh deploy_release \
    $KUBEVIRT_RELEASE
${KUBEVIRT_TESTING_PATH}/hack/kubevirt-testing.sh deploy_release_test_infra \
    $KUBEVIRT_RELEASE
${KUBEVIRT_TESTING_PATH}/hack/kubevirt-testing.sh wait_on_all_ready


# enable feature gates

#   spec:
#     ...
#     configuration:
#       developerConfiguration:
#         featureGates:
#         - LiveMigration
#         - Snapshot

kubectl patch kubevirt kubevirt -n kubevirt --type merge -p \
    '{"spec": {"configuration": {"developerConfiguration": {"featureGates": [ "LiveMigration", "Snapshot" ]}}}}'

# modify usable machine types
# see https://github.com/kubevirt/kubevirt/issues/2762

#   spec:
#     ...
#     configuration:
#       developerConfiguration:
#         ...
#       emulatedMachines:
#       - "q35*"
#       - "pc-q35*"
#       - "pc*"

kubectl patch kubevirt kubevirt -n kubevirt --type merge -p \
    '{"spec": {"configuration": {"emulatedMachines": [ "q35*", "pc-q35*", "pc*" ]}}}'


