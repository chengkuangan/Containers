# Kubernetes etcd Backup

This container provides a simple approach to backup the `etcd` into a `Persistent Volume`. It is using the `etcdctl` and `kubectl` tools to query the respective `etcd` Pods and perform the snapshot using the `etcdctl` tool.

The `etcd-backup` pod is deployed into Kubernetes and using the `Cronjob` to schedule the snapshot.

It is currently based on Alpine base image and supports on `amd64` and `arm64` architecture. You need to build the specific container for the respective architecture. Please refer to the next section.

> Note: This project is created for tutorial pupose. Please refer the [etcdbk](https://github.com/chengkuangan/etcdbk) for the updated container build. 

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
    Refer the timezone values at [wikipedia](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones).

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

    You will observe the output as per the following:
    
    ```
    2022-02-09-12:58:46 PM   Timezone: Asia/Kuala_Lumpur
    2022-02-09-12:58:47 PM   Startinng snapshot for etcd-kube0.internal ... 
    2022-02-09-12:58:47 PM   ADVERTISED_CLIENT_URL = https://10.0.0.110:2379
    2022-02-09-12:58:47 PM   ETCD_SERVER_CERT = /etc/kubernetes/pki/etcd/server.crt
    2022-02-09-12:58:47 PM   ETCD_SERVER_KEY = /etc/kubernetes/pki/etcd/server.key
    2022-02-09-12:58:47 PM   ETCD_CACERT = /etc/kubernetes/pki/etcd/ca.crt
    2022-02-09-12:58:47 PM   Backing up etcd-kube0.internal ... Snapshot file: /backup/etcd-kube0.internal-2022-02-09-12-58-1644382727 ...
    2022-02-09-12:58:48 PM   {"level":"info","ts":1644382728.0371673,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/backup/etcd-kube0.internal-2022-02-09-12-58-1644382727.part"}
    {"level":"info","ts":1644382728.0592608,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
    {"level":"info","ts":1644382728.059408,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://10.0.0.110:2379"}
    {"level":"info","ts":1644382728.6281931,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
    {"level":"info","ts":1644382728.7922444,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://10.0.0.110:2379","size":"12 MB","took":"now"}
    {"level":"info","ts":1644382728.8014007,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/backup/etcd-kube0.internal-2022-02-09-12-58-1644382727"}
    Snapshot saved at /backup/etcd-kube0.internal-2022-02-09-12-58-1644382727
    2022-02-09-12:58:48 PM   Startinng snapshot for etcd-kube1.internal ... 
    2022-02-09-12:58:49 PM   ADVERTISED_CLIENT_URL = https://10.0.0.111:2379
    2022-02-09-12:58:49 PM   ETCD_SERVER_CERT = /etc/kubernetes/pki/etcd/server.crt
    2022-02-09-12:58:49 PM   ETCD_SERVER_KEY = /etc/kubernetes/pki/etcd/server.key
    2022-02-09-12:58:49 PM   ETCD_CACERT = /etc/kubernetes/pki/etcd/ca.crt
    2022-02-09-12:58:49 PM   Backing up etcd-kube1.internal ... Snapshot file: /backup/etcd-kube1.internal-2022-02-09-12-58-1644382729 ...
    2022-02-09-12:58:50 PM   {"level":"info","ts":1644382729.6139565,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/backup/etcd-kube1.internal-2022-02-09-12-58-1644382729.part"}
    {"level":"info","ts":1644382729.6572225,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
    {"level":"info","ts":1644382729.6585956,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://10.0.0.111:2379"}
    {"level":"info","ts":1644382730.1461122,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
    {"level":"info","ts":1644382730.5825508,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://10.0.0.111:2379","size":"12 MB","took":"now"}
    {"level":"info","ts":1644382730.6201115,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/backup/etcd-kube1.internal-2022-02-09-12-58-1644382729"}
    Snapshot saved at /backup/etcd-kube1.internal-2022-02-09-12-58-1644382729
    2022-02-09-12:58:50 PM   Startinng snapshot for etcd-kube2.internal ... 
    2022-02-09-12:58:50 PM   ADVERTISED_CLIENT_URL = https://10.0.0.112:2379
    2022-02-09-12:58:51 PM   ETCD_SERVER_CERT = /etc/kubernetes/pki/etcd/server.crt
    2022-02-09-12:58:51 PM   ETCD_SERVER_KEY = /etc/kubernetes/pki/etcd/server.key
    2022-02-09-12:58:51 PM   ETCD_CACERT = /etc/kubernetes/pki/etcd/ca.crt
    2022-02-09-12:58:51 PM   Backing up etcd-kube2.internal ... Snapshot file: /backup/etcd-kube2.internal-2022-02-09-12-58-1644382731 ...
    2022-02-09-12:58:52 PM   {"level":"info","ts":1644382731.4680276,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/backup/etcd-kube2.internal-2022-02-09-12-58-1644382731.part"}
    {"level":"info","ts":1644382731.4753816,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
    {"level":"info","ts":1644382731.475609,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://10.0.0.112:2379"}
    {"level":"info","ts":1644382732.0035121,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
    {"level":"info","ts":1644382732.3840053,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://10.0.0.112:2379","size":"12 MB","took":"now"}
    {"level":"info","ts":1644382732.3858457,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/backup/etcd-kube2.internal-2022-02-09-12-58-1644382731"}
    Snapshot saved at /backup/etcd-kube2.internal-2022-02-09-12-58-1644382731

    ```
# Reference

- Refer [How to use etcdctl to Backup Kubernetes etcd Data?](https://braindose.blog/2022/02/09/etcdctl-backup-kubernetes/) for complete explanation.