# cnpg-cluster

Helm chart for deploying CloudNativePG clusters and related resources. Ships with a default CiliumNetworkPolicy allowing the CNPG operator to reach cluster pods.

**Homepage:** <https://github.com/KvalitetsIT>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| KvalitetsIT | <kithosting@kvalitetsit.dk> | <https://github.com/KvalitetsIT/helm-repo> |

## Source Code

* <https://github.com/KvalitetsIT/cnpg-chart>
* <https://github.com/KvalitetsIT/cnpg-chart/tree/main/charts/cnpg>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://raw.githubusercontent.com/KvalitetsIT/helm-repo/master/ | templates | 2.1.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | `""` | Override the Cluster name. Defaults to the Helm release name. |
| metadata | object | `{}` | Metadata overrides for the Cluster resource. |
| instances | int | `1` | Number of PostgreSQL instances in the cluster. |
| imageName | string | `""` | Container image for PostgreSQL. Takes precedence over imageCatalogRef. |
| imageCatalogRef | object | `{}` | Reference to an ImageCatalog or ClusterImageCatalog resource. |
| imagePullPolicy | string | `"IfNotPresent"` | Image pull policy for the PostgreSQL container. |
| imagePullSecrets | list | `[]` | Image pull secrets for private registries. |
| postgresUID | int | `-1` | UID for the postgres process. -1 means use the default from the image. |
| postgresGID | int | `-1` | GID for the postgres process. -1 means use the default from the image. |
| storage.size | string | `"8Gi"` | Size of the PVC for PostgreSQL data. |
| storage.storageClass | string | `""` | Storage class for the data PVC. Defaults to the cluster default. |
| walStorage.enabled | bool | `false` | Set to true to use a separate PVC for WAL files. |
| walStorage.size | string | `"1Gi"` | Size of the WAL PVC. |
| walStorage.storageClass | string | `""` | Storage class for the WAL PVC. Defaults to the cluster default. |
| postgresql.parameters | object | `{}` | PostgreSQL configuration parameters (postgresql.conf knobs). |
| postgresql.pg_hba | list | `[]` | pg_hba.conf rules appended after the operator-managed entries. |
| postgresql.pg_ident | list | `[]` | pg_ident.conf rules. |
| postgresql.shared_preload_libraries | list | `[]` | Libraries added to shared_preload_libraries. |
| initdb | object | `{}` | initdb bootstrap config. Maps to spec.bootstrap.initdb. |
| recovery | object | `{}` | Recovery bootstrap config. Maps to spec.bootstrap.recovery. |
| pgBaseBackup | object | `{}` | pg_basebackup bootstrap config. Maps to spec.bootstrap.pg_basebackup. |
| externalClusters | list | `[]` | External cluster definitions used for recovery or replica sources. Maps to spec.externalClusters. |
| replica | object | `{}` | Replica cluster configuration. Maps to spec.replica. |
| replicationSlots | object | `{}` | Replication slot configuration. Maps to spec.replicationSlots. |
| roles | list | `[]` | Declarative role management. Maps to spec.managed.roles. |
| databases | list | `[]` | List of Database CRD resources to create. Each entry requires a name field. The cluster reference is auto-injected. All other fields map directly to the Database spec. |
| backup | object | see values.yaml | S3/VolumeSnapshot backup, scheduled backups, and WAL settings. |
| plugins | list | `[]` | Additional plugins to inject into the Cluster spec. The barman-cloud plugin entry is auto-injected when objectStore.enabled is true. |
| monitoring | object | see values.yaml | Monitoring configuration including PodMonitor and custom queries. |
| resources | object | `{}` | CPU and memory resource requests/limits for the PostgreSQL container. |
| priorityClassName | string | `""` | PriorityClass for the PostgreSQL pods. |
| schedulerName | string | `""` | Custom scheduler name. Defaults to the Kubernetes default scheduler. |
| nodeSelector | object | `{}` | Node selector for the PostgreSQL pods. |
| tolerations | list | `[]` | Tolerations for the PostgreSQL pods. |
| topologySpreadConstraints | list | `[]` | Topology spread constraints for the PostgreSQL pods. |
| affinity | object | `{}` | Affinity rules for the PostgreSQL pods. |
| minSyncReplicas | int | `0` | Minimum number of synchronous standby replicas required for a commit to succeed. |
| maxSyncReplicas | int | `0` | Maximum number of synchronous standby replicas. |
| certificates | object | `{}` | TLS certificate configuration. Maps to spec.certificates. |
| enableSuperuserAccess | bool | `true` | Allow direct connections to the postgres superuser. |
| superuserSecret | string | `""` | Name of an existing secret containing the superuser password. |
| primaryUpdateMethod | string | `"switchover"` | Method used to perform a controlled switchover (switchover or restart). |
| primaryUpdateStrategy | string | `"unsupervised"` | When to apply updates: unsupervised applies them automatically. |
| logLevel | string | `"info"` | Log level for the instance manager (error, warning, info, debug, trace). |
| switchoverDelay | int | `40` | Seconds to wait for a switchover to complete before forcing a failover. |
| failoverDelay | int | `0` | Seconds to wait before triggering an automatic failover. |
| startDelay | int | `30` | Seconds to wait for the instance to start before marking it as failed. |
| stopDelay | int | `30` | Seconds to wait for the instance to stop cleanly before sending SIGKILL. |
| smartShutdownTimeout | int | `120` | Seconds to wait for smart shutdown (idle connections drain) before switching to fast shutdown. |
| inheritedMetadata | object | `{}` | Labels and annotations inherited by all child resources (pods, PVCs, etc.). |
| serviceAccountTemplate | object | `{}` | Template for the ServiceAccount created for the cluster pods. |
| env | list | `[]` | Extra environment variables for the PostgreSQL container. |
| envFrom | list | `[]` | Extra environment variables sourced from ConfigMaps or Secrets. |
| projectedVolumeTemplate | object | `{}` | Projected volume template mounted into the PostgreSQL pods. |
| poolers | list | `[]` | List of Pooler (PgBouncer) resources to create for this cluster. |
| objectStore | object | see values.yaml | ObjectStore resource for the barman-cloud plugin. Enabling this automatically injects the plugin entry into the Cluster spec. |
| templates | object | see values.yaml | CiliumNetworkPolicy and other resources rendered via the KvalitetsIT templates chart. |

## Usage

This is a Helm chart for deploying CloudNativePG clusters and related resources.
By default it renders a `CiliumNetworkPolicy` that allows the CNPG operator to reach cluster pods.
Configure the sections below to deploy a cluster and additional resources.

### Cluster

Renders a CloudNativePG `Cluster` resource. `instances` and either `imageName` or `imageCatalogRef` are required.
Override the resource name via `nameOverride` or add custom labels/annotations via `metadata.labels`/`metadata.annotations`.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi
```

### Backup with barman-cloud plugin

Renders an `ObjectStore` resource and wires the barman-cloud plugin into the `Cluster` spec.
Requires the barman-cloud CNPG plugin to be installed in the cluster.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi

objectStore:
  enabled: true
  configuration:
    destinationPath: s3://my-bucket/
    endpointURL: https://minio.example.com
    s3Credentials:
      accessKeyId:
        name: aws-creds
        key: ACCESS_KEY_ID
      secretAccessKey:
        name: aws-creds
        key: ACCESS_SECRET_KEY
    wal:
      compression: gzip

backup:
  enabled: false
  scheduledBackups:
    - name: daily
      schedule: "0 0 3 * * *"
      backupOwnerReference: self
      method: plugin
      pluginConfiguration:
        name: barman-cloud.cloudnative-pg.io
```

### Recovery from backup

Point `recovery.source` at an `externalClusters` entry to bootstrap from a previous backup.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 3
storage:
  size: 10Gi

externalClusters:
  - name: source-cluster
    barmanObjectStore:
      destinationPath: s3://my-bucket/source-cluster
      s3Credentials:
        accessKeyId:
          name: aws-creds
          key: ACCESS_KEY_ID
        secretAccessKey:
          name: aws-creds
          key: ACCESS_SECRET_KEY

recovery:
  source: source-cluster
```

### Poolers (PgBouncer)

Each entry in `poolers` renders a `Pooler` resource named `<cluster>-<name>`.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi

poolers:
  - name: rw
    type: rw
    instances: 2
    pgbouncer:
      poolMode: transaction
      parameters:
        max_client_conn: "200"
        default_pool_size: "10"
  - name: ro
    type: ro
    instances: 1
    pgbouncer:
      poolMode: session
```

### ImageCatalog reference

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi

# Reference a catalog managed by a separate chart/component
imageCatalogRef:
  apiGroup: postgresql.cnpg.io
  kind: ClusterImageCatalog
  name: postgresql
  major: 16
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
