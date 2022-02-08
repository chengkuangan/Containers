# Kubernetes etcd Backup

This container provides a simple approach to backup the `etcd` into a `Persistent Volume`. It is using the `etcdctl` and `kubectl` tools to query the respective `etcd` Pods and perform the snapshot using the `etcdctl` tool.

The `etcd-backup` pod is deployed into Kubernetes and using the `Cronjob` to schedule the snapshot.

It is currently based on Alpine base image and supports on `amd64` and `arm64` architecture. You need to build the specific container for the respective architecture. Please refer the next section.

## Build the Container

```
# build for arm64 and push to registry
$ docker buildx build --platform linux/arm64 -t chengkuan/etcd-backup:arm64-1.0.0 -f Dockerfile.alpine.arm64 --push .

# build for amd64 and push to registry
$ docker buildx build --platform linux/amd64 -t chengkuan/etcd-backup:amd64-1.0.0 -f Dockerfile.alpine.amd64 --push .

# push to internal insecured registry
$ docker buildx build --platform linux/arm64 -t nexus.internal:7082/repository/containers/etcd-backup:arm64-1.0.0 -f Dockerfile.alpine.arm64 --push --output=type=registry,registry.insecure=true .
docker buildx build --platform linux/amd64 -t nexus.internal:7082/repository/containers/etcd-backup:amd64-1.0.0 -f Dockerfile.alpine.amd64 --push --output=type=registry,registry.insecure=true .

# Specifiying a specific kubectl and etcd version
$ docker buildx build --build-arg KUBE_VERSION=v1.22.4 --build-arg ETCD_VERSION=v3.5.0 --platform linux/arm64 -t nexus.internal:7082/repository/containers/etcd-backup:alpine-arm64-1.0.0 -f Dockerfile.alpine.arm64 --push --output=type=registry,registry.insecure=true .
$ docker buildx build --build-arg KUBE_VERSION=v1.22.4 --build-arg ETCD_VERSION=v3.5.0 --platform linux/amd64 -t nexus.internal:7082/repository/containers/etcd-backup:alpine-amd64-1.0.0 -f Dockerfile.alpine.amd64 --push --output=type=registry,registry.insecure=true .

```

## Deploy into Kubernetes

1. Open [etcd-backup.yaml](./etcd-backup.yaml) and change the `Conjob` schedule to the schedule that you prefer. 

    ```yaml
    apiVersion: batch/v1
    kind: CronJob
    metadata:
        name: ectd-backup
        namespace: etcd-backup
        labels:
            app: etcd-backup
            app-group: etcd-backup
    spec:
        # Change the schedule here
        schedule: "* 6 * * *"
        jobTemplate:

    ```
    Refer the Kubernetes [Cronjob syntax](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax) for more configuration option.

2. Deploy the container to Kubernetes

    ```
    $ kubectl create -f etcd-backup.yaml
    ```
    Note: This will create all the necessary ClusterRole, ClusterRoleBinding, PVC, namespaces and Pod. Make sure the required `PersistentVolume` are created if your Kubernetes cluster does not support `Dynamic Storage Class`.

