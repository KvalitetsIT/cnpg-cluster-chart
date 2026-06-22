# cnpg-cluster

Helm chart for deploying CloudNativePG clusters and related resources. Ships with a default CiliumNetworkPolicy allowing the CNPG operator to reach cluster pods.

**Homepage:** <https://github.com/KvalitetsIT>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| KvalitetsIT | <kithosting@kvalitetsit.dk> | <https://github.com/KvalitetsIT/helm-repo> |

## Source Code

* <https://github.com/KvalitetsIT/cnpg-cluster-chart>
* <https://github.com/KvalitetsIT/cnpg-cluster-chart/tree/main/charts/cnpg-cluster>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://raw.githubusercontent.com/KvalitetsIT/helm-repo/master/ | templates | 2.2.0 |

## Values

### Global

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global | object | see values.yaml | Global values propagated to all chart dependencies. |
| global.objectStore.configuration.endpointURL | string | "" | S3-compatible endpoint URL. Mirrors objectStore.configuration.endpointURL and is accessible to subchart dependencies (e.g. CiliumNetworkPolicy egress rules). |

### Cluster

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| nameOverride | string | Release name | Override the Cluster name. |
| metadata | object | {} | Metadata overrides for the Cluster resource. |
| instances | int | 1 | Number of PostgreSQL instances in the cluster. |
| enablePDB | string | auto | Manage the PodDisruptionBudget for the cluster. When null (default), the chart automatically sets this to `false` for single-instance clusters (instances=1) and leaves it unset (operator default: `true`) for multi-instance clusters. Set explicitly to `true` or `false` to override this behaviour. |
| clusterSpec | object | {} | Passthrough for any ClusterSpec fields not explicitly exposed by chart values. Fields here are appended to the Cluster spec as-is. Do not duplicate keys already managed by other values. |
| imageName | string | "" | Container image for PostgreSQL. Takes precedence over imageCatalogRef. |
| imageCatalogRef | object | {} | Reference to an ImageCatalog or ClusterImageCatalog resource. |
| imagePullPolicy | string | IfNotPresent | Image pull policy for the PostgreSQL container. |
| imagePullSecrets | list | [] | Image pull secrets for private registries. |

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

### Roles & Databases

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| roles | list | [] | Declarative role management. Maps to spec.managed.roles. See [example](#roles--databases-1) and the [RoleConfiguration API](https://cloudnative-pg.io/docs/1.29/cloudnative-pg.v1#roleconfiguration). |
| databases | list | [] | List of Database CRD resources to create. Each entry requires a name field. The cluster reference is auto-injected. All other fields map directly to the Database spec. See [example](#roles--databases-1) and the [Database API](https://cloudnative-pg.io/docs/1.29/cloudnative-pg.v1#database). |

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
| backup.scheduledBackups | list | [] | List of ScheduledBackup resources to create for this cluster. See the [ScheduledBackup API](https://cloudnative-pg.io/docs/1.29/cloudnative-pg.v1#scheduledbackup). |

### Plugins

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| plugins | list | [] | Additional plugins to inject into the Cluster spec. The barman-cloud plugin entry is auto-injected when objectStore.enabled is true. |

### Monitoring

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| monitoring | object | see values.yaml | Monitoring configuration including PodMonitor and custom queries. |
| monitoring.enabled | bool | false | Set to true to enable monitoring. |
| monitoring.enablePodMonitor | bool | true | Set to true to create a PodMonitor resource. |
| monitoring.podMonitorRelabelings | list | [] | Relabeling rules applied to scraped metrics. |
| monitoring.podMonitorMetricRelabelings | list | [] | Metric relabeling rules applied after scraping. |
| monitoring.disableDefaultQueries | bool | false | Disable the default Prometheus queries shipped by CNPG. |
| monitoring.customQueriesSecret | list | [] | References to secrets containing custom Prometheus queries (ConfigMap key: custom-queries.yaml). |

### Resources & Scheduling

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| resources | object | {} | CPU and memory resource requests/limits for the PostgreSQL container. |
| priorityClassName | string | "" | PriorityClass for the PostgreSQL pods. |
| nodeSelector | object | {} | Node selector for the PostgreSQL pods. |
| tolerations | list | [] | Tolerations for the PostgreSQL pods. |
| topologySpreadConstraints | list | [] | Topology spread constraints for the PostgreSQL pods. |
| affinity | object | {} | Affinity rules for the PostgreSQL pods. |

### Access & Security

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enableSuperuserAccess | bool | true | Allow direct connections to the postgres superuser. |
| superuserSecret | string | "" | Name of an existing secret containing the superuser password. |

### Lifecycle

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| primaryUpdateMethod | string | switchover | Method used to perform a controlled switchover (switchover or restart). |
| primaryUpdateStrategy | string | unsupervised | When to apply updates: unsupervised applies them automatically. |

### Metadata & Volumes

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| env | list | [] | Extra environment variables for the PostgreSQL container. |
| envFrom | list | [] | Extra environment variables sourced from ConfigMaps or Secrets. |

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
| objectStore.configuration | object | see values.yaml | ObjectStore configuration. Set destinationPath and s3Credentials at minimum. Note: endpointURL is set under global.objectStore.configuration.endpointURL (not here), so it propagates to subchart dependencies such as the CiliumNetworkPolicy egress template. Setting it here instead will produce a validation error at render time. |
| objectStore.configuration.destinationPath | string | "" | S3 destination path for backups (e.g. s3://my-bucket/my-cluster). Required. |
| objectStore.configuration.s3Credentials | object | {} | S3 credentials referencing Kubernetes secret keys. |
| objectStore.configuration.s3Credentials.accessKeyId | object | {} | Secret key reference for the S3 access key ID. |
| objectStore.configuration.s3Credentials.secretAccessKey | object | {} | Secret key reference for the S3 secret access key. |
| objectStore.configuration.wal.compression | string | gzip | Compression algorithm for WAL files (gzip, bzip2, snappy). |
| objectStore.configuration.wal.maxParallel | int | 8 | Number of parallel WAL upload workers. |
| objectStore.configuration.data.compression | string | gzip | Compression algorithm for base backup data files (gzip, bzip2, snappy). |
| objectStore.configuration.data.jobs | int | 8 | Number of parallel data upload workers. |
| objectStore.instanceSidecarConfiguration | object | see values.yaml | Sidecar container configuration for the barman-cloud plugin. |
| objectStore.instanceSidecarConfiguration.resources.limits.memory | string | 512Mi | Memory limit for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.limits.cpu | string | 500m | CPU limit for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.requests.memory | string | 256Mi | Memory request for the barman-cloud sidecar. |
| objectStore.instanceSidecarConfiguration.resources.requests.cpu | string | 250m | CPU request for the barman-cloud sidecar. |

### Network Policies

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ciliumNetworkPolicies | object | see values.yaml | CiliumNetworkPolicy resources. Each entry is rendered by the templates chart helper with root set to this chart's context, so template strings (e.g. include "cnpg-cluster.fullname") resolve correctly. The map key is used as a name suffix; the cluster fullname is prepended automatically. Set enabled: false on any entry to suppress it. |
| networkPolicies | object | see values.yaml | Standard NetworkPolicy resources for pod-to-pod traffic that does not require Cilium-specific features. Rendered with the same iterator pattern as ciliumNetworkPolicies. |

## Usage

This is a Helm chart for deploying CloudNativePG clusters and related resources.
Configure the sections below to deploy a cluster and additional resources.

### Network policies

The chart ships with network policies enabled by default. When Cilium is present (`cilium.io/v2` CRD available), `CiliumNetworkPolicy` resources are rendered; otherwise standard `NetworkPolicy` resources are used as a fallback.

The following policies are rendered by default:

| Policy | Type | Purpose |
|--------|------|---------|
| `<name>-cnpg-cluster` | Cilium / fallback | Allows all cluster pods to reach the kube-apiserver and CoreDNS. Allows the CNPG operator to reach cluster pods on port 8000. |
| `<name>-cnpg-cluster-initdb` | Cilium / fallback | Allows initdb job pods to reach the kube-apiserver. |
| `<name>-cnpg-cluster-intracluster` | Cilium / fallback | Allows all pods in the same CNPG cluster to communicate with each other on ports 5432 (PostgreSQL) and 8000 (health/metrics). This uses `cnpg.io/cluster` as the selector rather than role-specific labels, which is necessary because pods require network access during startup before the operator has assigned `instanceRole` or `jobRole` labels. |
| `<name>-cnpg-cluster-prometheus` | NetworkPolicy | Allows Prometheus to scrape cluster pods on port 9187. |

Additional policies or overrides can be added via `ciliumNetworkPolicies` and `networkPolicies` in `values.yaml`.

### Cluster

Renders a CloudNativePG `Cluster` resource. `instances` and either `imageName` or `imageCatalogRef` are required.
Override the resource name via `nameOverride` or add custom labels/annotations via `metadata.labels`/`metadata.annotations`.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi
```

### ClusterSpec passthrough

Any field from the [ClusterSpec API](https://cloudnative-pg.io/docs/1.29/cloudnative-pg.v1/#postgresql-cnpg-io-v1-ClusterSpec) not exposed as a top-level chart value can be placed under `clusterSpec` and it will flow directly to the underlying `Cluster` resource.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi

# Any field from the ClusterSpec not exposed as a top-level chart value can be
# placed here and it will flow directly to the underlying Cluster resource.
clusterSpec:
  switchoverDelay: 40
  startDelay: 30
```

### Backup with barman-cloud plugin

Renders an `ObjectStore` resource and wires the barman-cloud plugin into the `Cluster` spec.
Requires the barman-cloud CNPG plugin to be installed in the cluster.

> [!NOTE]
> `endpointURL` must be set under `global.objectStore.configuration.endpointURL` — **not** under `objectStore.configuration`.
> This is required so the value propagates to subchart dependencies, including the CiliumNetworkPolicy egress rule that allows cluster pods to reach the S3 endpoint.
> Setting it under `objectStore.configuration` will produce a validation error at render time.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 1Gi

# endpointURL must be set under global so it propagates to subchart dependencies
# (e.g. the CiliumNetworkPolicy egress rule). The barman-object-store template
# reads it directly from global.objectStore.configuration.endpointURL.
global:
  objectStore:
    configuration:
      endpointURL: hel1.your-objectstorage.com

objectStore:
  enabled: true
  configuration:
    destinationPath: s3://my-bucket/
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
instances: 1
storage:
  size: 1Gi

imageCatalogRef:
  apiGroup: postgresql.cnpg.io
  kind: ClusterImageCatalog
  name: postgresql
  major: 16
```

### Roles & Databases

Declarative role and database management via `roles` and `databases`.
Roles map to `spec.managed.roles` on the `Cluster` resource and are continuously reconciled by the operator.
Each entry in `databases` creates a separate `Database` CRD; the cluster reference is auto-injected by the chart.

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:18.3-202604270853-system-bookworm@sha256:73110ae76402e63a849eb4f4dfb7608d2222758cbf2d66a2df60628458b9cd4f
instances: 1
storage:
  size: 8Gi

initdb:
  database: app
  owner: app

roles:
  - name: app
    ensure: present
    login: true
    passwordSecret:
      name: app-secret
  - name: reporting
    ensure: present
    login: true
    passwordSecret:
      name: reporting-secret
    comment: Read-only reporting account
  - name: migration
    ensure: present
    login: true
    createDb: false
    passwordSecret:
      name: migration-secret
    comment: Account used by schema migration tooling

databases:
  - name: app
    ensure: present
    owner: app
  - name: reporting
    ensure: present
    owner: reporting
    comment: Separate database for reporting queries
```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
