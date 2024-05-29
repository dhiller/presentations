set -exo pipefail

SCRIPT_PATH="$(
    cd "$(dirname "$BASH_SOURCE[0]")/"
    echo "$(pwd)/"
)"

# port forward kubevirtci cdi-uploadproxy to enable uploading
kubectl port-forward -n cdi service/cdi-uploadproxy-nodeport 18443:443 &

# upload image (note that we want a block volume with RWX access for live migration)
kubectl virt image-upload pvc windows-vm-disk \
    --image-path=${SCRIPT_PATH}/../WinXP-Lernwerkstatt-9-disk1.qcow2 --size=15Gi \
    --block-volume=true --access-mode=ReadWriteMany --insecure --uploadproxy-url=https://127.0.0.1:18443

kubectl create -f ${SCRIPT_PATH}/../manifests/windows-xp-vm.yaml
