# containerdays.io 2022

## KubeVirt - Making running virtual machines in Kubernetes a mainstream activity

This repository contains the accompanying material for [my talk at containerdays 2022](https://www.containerdays.io/agenda/conferenceday2/#kubevirt-making-running-virtual-machines-in-a-kubernetes-cluster-a-mainstream-activity)

### [slides](./slides/)

Contains a pdf version of the [slides for the presentation](./slides/containerdays.io%20-%20KubeVirt%20-%20making%20running%20virtual%20machines%20in%20a%20kubernetes%20cluster%20a%20mainstream%20activity.pdf)

### [hack](./hack/)

Contains the scripts I used to [deploy the kubevirtci cluster](./hack/deploy-kubevirt-on-kubevirtci.sh) and to [import the vm disk](./hack/import-vm-image.sh).

#### `kubectl virt ...`

Note: whenever you are reading 

```shell
$ kubectl virt ...
```

effectively [`virtctl`](https://kubevirt.io/user-guide/operations/virtctl_client_tool/) is used. This is achieved through the [kubectl-virt-plugin](https://github.com/kubevirt/kubectl-virt-plugin) which is based on [krew](https://krew.sigs.k8s.io/).

Those calls can be replaced by

```shell
$ virtctl ...
```

### [manifests](./manifests/)

Contains the manifests for the [example vm](./manifests/windows-xp-vm.yaml) and for the [snapshot](./manifests/snapshot.yaml) resp. [restore](./manifests/restore-snapshot.yaml) objects I used

### [grafana](./grafana/)

Contains the example dashboard I used for showing the vm stats. It's based on [this one](https://grafana.com/grafana/dashboards/11748-kubevirt/)

### Backup video @ YT

The [backup demo video](https://youtu.be/5frqhRJXFIM) including explanations
