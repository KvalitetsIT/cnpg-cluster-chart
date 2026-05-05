# cnpg-cluster

Helm chart for rendering CloudNativePG resources from values. The chart renders nothing by default; resources are created only when explicitly configured.

**Homepage:** <https://github.com/KvalitetsIT>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| KvalitetsIT | <kithosting@kvalitetsit.dk> | <https://github.com/KvalitetsIT/helm-repo> |

## Source Code

* <https://github.com/KvalitetsIT/cnpg-chart>
* <https://github.com/KvalitetsIT/cnpg-chart/tree/main/charts/cnpg>

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
| databases | list | `[]` | Declarative database management. Maps to spec.managed.databases. |
| backup.enabled | bool | `false` | Set to true to enable S3 backup via barmanObjectStore. |
| backup.target | string | `"prefer-standby"` | Which instance to take backups from. prefer-standby avoids load on the primary. |
| backup.retentionPolicy | string | `"30d"` | Backup retention policy (e.g. "30d", "10" for 10 backups). |
| backup.s3.bucket | string | `""` | S3 bucket name. |
| backup.s3.path | string | `"/"` | Path prefix inside the bucket. |
| backup.s3.endpointURL | string | `""` | Custom S3-compatible endpoint URL (e.g. for MinIO). |
| backup.s3.endpointCA.name | string | `""` | Name of the ConfigMap or Secret containing the endpoint CA certificate. |
| backup.s3.endpointCA.key | string | `""` | Key within the ConfigMap or Secret. |
| backup.s3.secret.name | string | `""` | Name of the existing secret containing S3 credentials. |
| backup.s3.secret.accessKeyKey | string | `"ACCESS_KEY_ID"` | Key for the AWS access key ID. |
| backup.s3.secret.secretKeyKey | string | `"ACCESS_SECRET_KEY"` | Key for the AWS secret access key. |
| backup.s3.secret.regionKey | string | `""` | Optional: key for AWS region in the same secret. |
| backup.s3.inheritFromIAMRole | bool | `false` | Use pod's IAM role instead of explicit credentials (IRSA / instance profile). |
| backup.wal.compression | string | `"gzip"` | Compression algorithm for WAL files uploaded to S3. |
| backup.wal.maxParallel | int | `1` | Number of parallel WAL upload workers. |
| backup.data.compression | string | `"gzip"` | Compression algorithm for base backup data files. |
| backup.data.jobs | int | `2` | Number of parallel data upload workers. |
| backup.volumeSnapshot.enabled | bool | `false` | Set to true to enable VolumeSnapshot-based backups. |
| backup.volumeSnapshot.className | string | `""` | VolumeSnapshotClass for the data volume snapshot. |
| backup.volumeSnapshot.walClassName | string | `""` | VolumeSnapshotClass for the WAL volume snapshot. |
| backup.volumeSnapshot.online | bool | `true` | Take the snapshot while the instance is running (online snapshot). |
| backup.volumeSnapshot.snapshotOwnerReference | string | `"cluster"` | Which resource owns the snapshots (cluster or none). |
| backup.scheduledBackups | list | `[]` | List of ScheduledBackup resources to create for this cluster. |
| plugins | list | `[]` | Additional plugins to inject into the Cluster spec. The barman-cloud plugin entry is auto-injected when objectStore.enabled is true. |
| monitoring.enabled | bool | `false` | Set to true to enable monitoring. |
| monitoring.podMonitor.enabled | bool | `true` | Set to true to create a PodMonitor resource. |
| monitoring.podMonitor.labels | object | `{}` | Additional labels to add to the PodMonitor. |
| monitoring.podMonitor.relabelings | list | `[]` | Relabeling rules applied to scraped metrics. |
| monitoring.podMonitor.metricRelabelings | list | `[]` | Metric relabeling rules applied after scraping. |
| monitoring.prometheusRule.enabled | bool | `true` | Set to true to create a PrometheusRule resource with CNPG alerting rules. |
| monitoring.prometheusRule.excludeRules | list | `[]` | List of default rule names to exclude. |
| monitoring.disableDefaultQueries | bool | `false` | Disable the default Prometheus queries shipped by CNPG. |
| monitoring.customQueriesSecret | list | `[]` | References to secrets containing custom Prometheus queries (ConfigMap key: custom-queries.yaml). |
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
| additionalLabels | object | `{}` | Extra labels added to the Cluster resource. |
| annotations | object | `{}` | Extra annotations added to the Cluster resource. |
| poolers | list | `[]` | List of Pooler (PgBouncer) resources to create for this cluster. |
| objectStore | object | `{"enabled":false}` | ObjectStore resource for the barman-cloud plugin. The resource name matches the cluster name. Requires the barman-cloud plugin to be installed. Enabling this automatically injects the plugin entry into the Cluster spec. |
| objectStore.enabled | bool | `false` | Set to true to create an ObjectStore resource and enable the barman-cloud plugin. |

## Usage

This is a Helm chart for deploying CloudNativePG resources.
By default, it renders nothing.

Define resources like the sections below to enable rendering.

### Clusters

Renders CloudNativePG `Cluster` resources.
Each entry requires `instances`.
You can override the rendered resource name and namespace via `metadata.name` and `metadata.namespace`.

#### Examples:

```yaml
imageName: ghcr.io/cloudnative-pg/postgresql:16.6
instances: 1
storage:
  size: 1Gi

```

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
