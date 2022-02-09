# Kubernetes etcd Backup

This container provides a simple approach to backup the `etcd` into a `Persistent Volume`. It is using the `etcdctl` and `kubectl` tools to query the respective `etcd` Pods and perform the snapshot using the `etcdctl` tool.

The `etcd-backup` pod is deployed into Kubernetes and using the `Cronjob` to schedule the snapshot.

It is currently based on Alpine base image and supports on `amd64` and `arm64` architecture. You need to build the specific container for the respective architecture. Please refer to the next section.

## Build the Container

1. Build the base image

    The current `etcd` version is defaulted into "v3.5.0" in the [Dockerfile.alpine](./Dockerfile.alpine). 
    You can change the `etcd` version to your preferred version using `--build-arg ETCD_VERSION=v3.5.0` at the `docker build` command.

  ```
  # Internal insecured registry
  docker buildx build --platform linux/arm64,linux/amd64 -t nexus.internal:7082/repository/containers/etcd-backup-base:1.0.0  -f Dockerfile.alpine --push --output=type=registry,registry.insecure=true .

  # Docker.io
  docker buildx build --platform linux/arm64,linux/amd64 -t chengkuan/etcd-backup-base:1.0.0  -f Dockerfile.alpine --push .
  ```

2. Build the arm64 base image

    The current `kubectl` version is defaulted into "v1.22.4" in the [Dockerfile.alpine.arm64](./Dockerfile.alpine.arm64) file. 
    You can change the `kubectl` version to your preferred version using `--build-arg KUBE_VERSION=v1.22.4` at the `docker build` command.

  ```
  # Internal insecured registry
  docker buildx build --platform linux/arm64 -t nexus.internal:7082/repository/containers/etcd-backup:arm64-1.0.0  -f Dockerfile.alpine.arm64 --push --output=type=registry,registry.insecure=true .

  # Docker.io
  docker buildx build --platform linux/arm64 -t chengkuan/etcd-backup:arm64-1.0.0  -f Dockerfile.alpine.arm64 --push .
  ```

3. Build the amd64 base image

    The current `kubectl` version is defaulted into "v1.22.4" in the [Dockerfile.alpine.amd64](./Dockerfile.alpine.amd64) file. 
    You can change the `kubectl` version to your preferred version using `--build-arg KUBE_VERSION=v1.22.4` at the `docker build` command.

  ```
  # Internal insecured registry
  docker buildx build --platform linux/amd64 -t nexus.internal:7082/repository/containers/etcd-backup:amd64-1.0.0  -f Dockerfile.alpine.amd64 --push --output=type=registry,registry.insecure=true .

  # Docker.io
  docker buildx build --platform linux/amd64 -t chengkuan/etcd-backup:amd64-1.0.0  -f Dockerfile.alpine.amd64 --push .
  ```

## Deploy into Kubernetes

1. Open [etcd-backup.yaml](./etcd-backup.yaml) and change the `Conjob` schedule to your preference. 

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
        # Change the schedule here. This is with timezone set to UTC+0:00
        schedule: "0 0 * * *"
        jobTemplate:
    ...
    ```
    Refer the Kubernetes [Cronjob syntax](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/#cron-schedule-syntax) for more configuration option.
    
    Please note that Cronjob does not support customize timezone which is always defaulted to UTC+0:00. Refers the [reported issue here](https://github.com/kubernetes/kubernetes/issues/47202).

2. Change the timezone via the YAML environmental variable. This affects the snapshot filename and the logging timestamp.
    ```yaml
          - env:
            - name: TZ
              value: "Asia/Kuala_Lumpur"
    ```

3. The YAML also defines the location for the `etcd` POD PKI certificates and key using a `Hostpath` definition. We also define the PVC to store the snapshot file. This is also the location for the log file.

    ```
          volumeMounts:
            - mountPath: /etc/kubernetes/pki/etcd
              name: etcd-certs
              readOnly: true
            - mountPath: /backup
              name: snapshot-dir
          restartPolicy: OnFailure
          volumes:
          - hostPath:
              path: /etc/kubernetes/pki/etcd
              type: Directory
            name: etcd-certs
          - name: snapshot-dir
            persistentVolumeClaim:
              claimName: etcd-backup-snapshot-pvc

    ```

2. Deploy the container to Kubernetes

    ```
    $ kubectl create -f etcd-backup.yaml
    ```
    Note: This will create all the necessary ClusterRole, ClusterRoleBinding, PVC, namespaces and Pod. Make sure the required PersistentVolume are created if your Kubernetes cluster does not support `Dynamic Storage Class`. Refer [Kubernetes documentation](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistent-volumes) for guide to create PersistentVolume if required.

3. To test the container

    ```
    kubectl create job testjob --from=cronjob/etcd-backup -n etcd-backup
    ```
