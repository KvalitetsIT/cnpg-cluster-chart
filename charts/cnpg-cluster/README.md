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

### Cluster

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | Release name | Override the Cluster name. |
| metadata | object | {} | Metadata overrides for the Cluster resource. |
| instances | int | 1 | Number of PostgreSQL instances in the cluster. |
| imageName | string | "" | Container image for PostgreSQL. Takes precedence over imageCatalogRef. |
| imageCatalogRef | object | {} | Reference to an ImageCatalog or ClusterImageCatalog resource. |
| imagePullPolicy | string | IfNotPresent | Image pull policy for the PostgreSQL container. |
| imagePullSecrets | list | [] | Image pull secrets for private registries. |
| postgresUID | int | -1 | UID for the postgres process. -1 means use the default from the image. |
| postgresGID | int | -1 | GID for the postgres process. -1 means use the default from the image. |

### Storage

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| storage | object | see values.yaml | PVC storage configuration for PostgreSQL data. |
| storage.size | string | 8Gi | Size of the PVC for PostgreSQL data. |
| storage.storageClass | string | cluster default | Storage class for the data PVC. |

### WAL Storage

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| walStorage | object | see values.yaml | Separate PVC configuration for WAL files. |
| walStorage.enabled | bool | false | Set to true to use a separate PVC for WAL files. |
| walStorage.size | string | 1Gi | Size of the WAL PVC. |
| walStorage.storageClass | string | cluster default | Storage class for the WAL PVC. |

### PostgreSQL

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| postgresql | object | see values.yaml | PostgreSQL engine configuration. |
| postgresql.parameters | object | {} | PostgreSQL configuration parameters (postgresql.conf knobs). |
| postgresql.pg_hba | list | [] | pg_hba.conf rules appended after the operator-managed entries. |
| postgresql.pg_ident | list | [] | pg_ident.conf rules. |
| postgresql.shared_preload_libraries | list | [] | Libraries added to shared_preload_libraries. |

### Bootstrap

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| initdb | object | {} | initdb bootstrap config. Maps to spec.bootstrap.initdb. |
| recovery | object | {} | Recovery bootstrap config. Maps to spec.bootstrap.recovery. |
| pgBaseBackup | object | {} | pg_basebackup bootstrap config. Maps to spec.bootstrap.pg_basebackup. |
| externalClusters | list | [] | External cluster definitions used for recovery or replica sources. Maps to spec.externalClusters. |

### Replication

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replica | object | {} | Replica cluster configuration. Maps to spec.replica. |
| replicationSlots | object | {} | Replication slot configuration. Maps to spec.replicationSlots. |
| minSyncReplicas | int | 0 | Minimum number of synchronous standby replicas required for a commit to succeed. |
| maxSyncReplicas | int | 0 | Maximum number of synchronous standby replicas. |

### Roles & Databases

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| roles | list | [] | Declarative role management. Maps to spec.managed.roles. |
| databases | list | [] | List of Database CRD resources to create. Each entry requires a name field. The cluster reference is auto-injected. All other fields map directly to the Database spec. |

### Backup

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| backup | object | see values.yaml | VolumeSnapshot backup, scheduled backups, and WAL settings. |
| backup.target | string | prefer-standby | Which instance to take backups from. prefer-standby avoids load on the primary. |
| backup.retentionPolicy | string | "30d" | Backup retention policy (e.g. "30d", "10" for 10 backups). |
| backup.volumeSnapshot.enabled | bool | false | Set to true to enable VolumeSnapshot-based backups. |
| backup.volumeSnapshot.className | string | "" | VolumeSnapshotClass for the data volume snapshot. |
| backup.volumeSnapshot.walClassName | string | "" | VolumeSnapshotClass for the WAL volume snapshot. |
| backup.volumeSnapshot.online | bool | true | Take the snapshot while the instance is running (online snapshot). |
| backup.volumeSnapshot.snapshotOwnerReference | string | cluster | Which resource owns the snapshots (cluster or none). |
| backup.scheduledBackups | list | [] | List of ScheduledBackup resources to create for this cluster. |

### Plugins

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| plugins | list | [] | Additional plugins to inject into the Cluster spec. The barman-cloud plugin entry is auto-injected when objectStore.enabled is true. |

### Monitoring

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitoring | object | see values.yaml | Monitoring configuration including PodMonitor and custom queries. |
| monitoring.enabled | bool | false | Set to true to enable monitoring. |
| monitoring.podMonitor.enabled | bool | true | Set to true to create a PodMonitor resource. |
| monitoring.podMonitor.labels | object | {} | Additional labels to add to the PodMonitor. |
| monitoring.podMonitor.relabelings | list | [] | Relabeling rules applied to scraped metrics. |
| monitoring.podMonitor.metricRelabelings | list | [] | Metric relabeling rules applied after scraping. |
| monitoring.disableDefaultQueries | bool | false | Disable the default Prometheus queries shipped by CNPG. |
| monitoring.customQueriesSecret | list | [] | References to secrets containing custom Prometheus queries (ConfigMap key: custom-queries.yaml). |

### Resources & Scheduling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | object | {} | CPU and memory resource requests/limits for the PostgreSQL container. |
| priorityClassName | string | "" | PriorityClass for the PostgreSQL pods. |
| schedulerName | string | default Kubernetes scheduler | Custom scheduler name. |
| nodeSelector | object | {} | Node selector for the PostgreSQL pods. |
| tolerations | list | [] | Tolerations for the PostgreSQL pods. |
| topologySpreadConstraints | list | [] | Topology spread constraints for the PostgreSQL pods. |
| affinity | object | {} | Affinity rules for the PostgreSQL pods. |

### Access & Security

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| certificates | object | {} | TLS certificate configuration. Maps to spec.certificates. |
| enableSuperuserAccess | bool | true | Allow direct connections to the postgres superuser. |
| superuserSecret | string | "" | Name of an existing secret containing the superuser password. |

### Lifecycle

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| primaryUpdateMethod | string | switchover | Method used to perform a controlled switchover (switchover or restart). |
| primaryUpdateStrategy | string | unsupervised | When to apply updates: unsupervised applies them automatically. |
| logLevel | string | info | Log level for the instance manager (error, warning, info, debug, trace). |
| switchoverDelay | int | 40 | Seconds to wait for a switchover to complete before forcing a failover. |
| failoverDelay | int | 0 | Seconds to wait before triggering an automatic failover. |
| startDelay | int | 30 | Seconds to wait for the instance to start before marking it as failed. |
| stopDelay | int | 30 | Seconds to wait for the instance to stop cleanly before sending SIGKILL. |
| smartShutdownTimeout | int | 120 | Seconds to wait for smart shutdown (idle connections drain) before switching to fast shutdown. |

### Metadata & Volumes

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| inheritedMetadata | object | {} | Labels and annotations inherited by all child resources (pods, PVCs, etc.). |
| serviceAccountTemplate | object | {} | Template for the ServiceAccount created for the cluster pods. |
| env | list | [] | Extra environment variables for the PostgreSQL container. |
| envFrom | list | [] | Extra environment variables sourced from ConfigMaps or Secrets. |
| projectedVolumeTemplate | object | {} | Projected volume template mounted into the PostgreSQL pods. |

### Poolers

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| poolers | list | [] | List of Pooler (PgBouncer) resources to create for this cluster. |

### Object Store

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| objectStore | object | see values.yaml | ObjectStore resource for the barman-cloud plugin. Enabling this automatically injects the plugin entry into the Cluster spec. |
| objectStore.enabled | bool | false | Set to true to create an ObjectStore resource and enable the barman-cloud plugin. |
| objectStore.retentionPolicy | string | "30d" | Backup retention policy. |
| objectStore.configuration | object | see values.yaml | ObjectStore configuration. Set destinationPath and s3Credentials at minimum. |
| objectStore.configuration.wal.compression | string | gzip | Compression algorithm for WAL files. |
| objectStore.configuration.wal.maxParallel | int | 8 | Number of parallel WAL upload workers. |
| objectStore.instanceSidecarConfiguration | object | see values.yaml | Sidecar container configuration for the barman-cloud plugin. |
| objectStore.instanceSidecarConfiguration.resources.limits.memory | string | 512Mi | Memory limit for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.limits.cpu | string | 500m | CPU limit for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.requests.memory | string | 256Mi | Memory request for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.requests.cpu | string | 250m | CPU request for the barman-cloud sidecar. |

### Other Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
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
    endpointURL: hel1.your-objectstorage.com
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
