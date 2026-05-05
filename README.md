# cnpg-cluster Chart

This repository contains a Helm chart for deploying a single [CloudNativePG](https://cloudnative-pg.io/) cluster.
The chart is located at [`charts/cnpg-cluster`](charts/cnpg-cluster).

The chart renders a single `Cluster` resource and its supporting resources (ObjectStore, ScheduledBackup, Pooler, PodMonitor, PrometheusRule) based on the values you provide.

---

## Features

- Single CNPG `Cluster` resource per Helm release
- S3 backup via `barmanObjectStore` (legacy inline) or the barman-cloud plugin (`ObjectStore` CRD)
- VolumeSnapshot-based backups
- Scheduled backups (`ScheduledBackup`)
- PgBouncer connection poolers (`Pooler`)
- Prometheus monitoring (`PodMonitor`, `PrometheusRule`)
- Declarative role and database management
- Bootstrap via `initdb`, `recovery`, or `pg_basebackup`

---

## Design principles

- Value keys closely match the corresponding CloudNativePG resource fields
- Resource structures follow the original API as closely as practical
- Minimal opinionated defaults — common Helm labels are always added; little else is decided for you

---

## Repository structure

```text
.
├── charts/
│   └── cnpg-cluster/
│       ├── Chart.yaml
│       ├── values.yaml
│       ├── values-docs.yaml
│       ├── README.md.gotmpl
│       ├── README.md
│       ├── .helmignore
│       ├── templates/
│       └── ci/
│           ├── cluster-values.yaml
│           ├── full-cluster-values.yaml
│           ├── barman-plugin-cluster-values.yaml
│           └── image-catalog-values.yaml
├── Makefile
├── ct.yaml
└── README.md
```

---

## Quick start

```yaml
# values.yaml
imageName: ghcr.io/cloudnative-pg/postgresql:16.6
instances: 3

storage:
  size: 20Gi
  storageClass: fast-ssd
```

```sh
helm install my-cluster oci://ghcr.io/kvalitetsit/cnpg-cluster -f values.yaml
```

---

## values.yaml vs values-docs.yaml vs ci/*-values.yaml

### values.yaml

- Defines the actual Helm defaults (intentionally minimal)
- Used by Helm at install and upgrade time

### values-docs.yaml

- Used **only for documentation** — does not affect chart behavior
- Contains fully populated example structures so helm-docs can produce a readable Values table

### ci/*-values.yaml

- Concrete scenario examples used for chart testing (`ct`)
- Useful as copy-paste starting points

---

## Generating documentation

```sh
make docs
```

Runs `helm-docs` in a container and regenerates the chart README from `values-docs.yaml` and `README.md.gotmpl`.

---

## Adding new resources or examples

1. Add templates under [`charts/cnpg-cluster/templates`](charts/cnpg-cluster/templates)
2. Document values in [`charts/cnpg-cluster/values-docs.yaml`](charts/cnpg-cluster/values-docs.yaml)
3. Add custom documentation in [`charts/cnpg-cluster/README.md.gotmpl`](charts/cnpg-cluster/README.md.gotmpl)
4. Add an example values file under [`charts/cnpg-cluster/ci`](charts/cnpg-cluster/ci)
