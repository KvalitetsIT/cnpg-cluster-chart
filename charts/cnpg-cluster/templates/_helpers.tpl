{{- define "cnpg-cluster.fullname" -}}
{{- .Values.fullnameOverride | default .Values.nameOverride | default .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cnpg-cluster.labels" -}}
app.kubernetes.io/managed-by: "Helm"
app.kubernetes.io/instance: {{ .Release.Name | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}

{{- define "cnpg-cluster.metadata" -}}
{{- $metadata := (default dict .metadata) -}}
{{- if and .name (not (hasKey $metadata "name")) -}}
{{- $_ := set $metadata "name" .name -}}
{{- end -}}
{{- if hasKey $metadata "name" -}}
{{- $_ := set $metadata "name" (tpl (get $metadata "name") .root) -}}
{{- end -}}
{{- $namespace := .namespace | default .root.Release.Namespace -}}
{{- if and $namespace (not (hasKey $metadata "namespace")) -}}
{{- $_ := set $metadata "namespace" $namespace -}}
{{- end -}}
{{- $commonLabels := (include "cnpg-cluster.labels" .root | fromYaml) -}}
{{- $customLabels := (default dict .metadata.labels) -}}
{{- $_ := set $metadata "labels" (merge $customLabels $commonLabels) -}}
{{- if .metadata.annotations -}}
{{- $_ := set $metadata "annotations" .metadata.annotations -}}
{{- end -}}
{{- toYaml $metadata -}}
{{- end }}

{{- define "cnpg.bootstrap" -}}
{{- if not (empty .Values.initdb) }}
bootstrap:
  initdb:
    {{- toYaml .Values.initdb | nindent 4 }}
{{- else if not (empty .Values.recovery) }}
bootstrap:
  recovery:
    {{- toYaml .Values.recovery | nindent 4 }}
{{- else if not (empty .Values.pgBaseBackup) }}
bootstrap:
  pg_basebackup:
    {{- toYaml .Values.pgBaseBackup | nindent 4 }}
{{- end }}
{{- end }}

{{- define "cnpg.backup" -}}
{{- if .Values.backup.volumeSnapshot.enabled }}
backup:
  target: {{ .Values.backup.target }}
  retentionPolicy: {{ .Values.backup.retentionPolicy | quote }}
  volumeSnapshot:
    {{- with .Values.backup.volumeSnapshot.className }}
    className: {{ . | quote }}
    {{- end }}
    {{- with .Values.backup.volumeSnapshot.walClassName }}
    walClassName: {{ . | quote }}
    {{- end }}
    online: {{ .Values.backup.volumeSnapshot.online }}
    snapshotOwnerReference: {{ .Values.backup.volumeSnapshot.snapshotOwnerReference }}
{{- end }}
{{- end }}

{{- define "cnpg.plugins" -}}
{{- $plugins := deepCopy (.Values.plugins | default list) }}
{{- if .Values.objectStore.enabled }}
{{- $plugins = append $plugins (dict "name" "barman-cloud.cloudnative-pg.io" "isWALArchiver" true "parameters" (dict "barmanObjectName" (include "cnpg-cluster.fullname" .))) }}
{{- end }}
{{- if $plugins }}
plugins:
  {{- toYaml $plugins | nindent 2 }}
{{- end }}
{{- end }}

{{- define "cnpg.managed" -}}
{{- if .Values.roles }}
managed:
  roles:
    {{- toYaml .Values.roles | nindent 4 }}
{{- end }}
{{- end }}

{{- define "cnpg.monitoring" -}}
{{- if .Values.monitoring.enabled }}
monitoring:
  enablePodMonitor: {{ .Values.monitoring.enablePodMonitor }}
  {{- with .Values.monitoring.podMonitorRelabelings }}
  podMonitorRelabelings:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.monitoring.podMonitorMetricRelabelings }}
  podMonitorMetricRelabelings:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  disableDefaultQueries: {{ .Values.monitoring.disableDefaultQueries }}
  {{- with .Values.monitoring.customQueriesSecret }}
  customQueriesSecret:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
