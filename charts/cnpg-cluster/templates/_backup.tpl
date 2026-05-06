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

{{- define "cnpg.backup" -}}
{{- if or .Values.backup.enabled .Values.backup.volumeSnapshot.enabled }}
backup:
  target: {{ .Values.backup.target }}
  retentionPolicy: {{ .Values.backup.retentionPolicy | quote }}
  {{- if .Values.backup.enabled }}
  barmanObjectStore:
    destinationPath: {{ printf "s3://%s%s" .Values.backup.s3.bucket .Values.backup.s3.path | quote }}
    {{- with .Values.backup.s3.endpointURL }}
    endpointURL: {{ . | quote }}
    {{- end }}
    {{- if and .Values.backup.s3.endpointCA.name .Values.backup.s3.endpointCA.key }}
    endpointCA:
      name: {{ .Values.backup.s3.endpointCA.name | quote }}
      key: {{ .Values.backup.s3.endpointCA.key | quote }}
    {{- end }}
    s3Credentials:
      {{- if .Values.backup.s3.inheritFromIAMRole }}
      inheritFromIAMRole: true
      {{- else }}
      accessKeyId:
        name: {{ .Values.backup.s3.secret.name | quote }}
        key: {{ .Values.backup.s3.secret.accessKeyKey | quote }}
      secretAccessKey:
        name: {{ .Values.backup.s3.secret.name | quote }}
        key: {{ .Values.backup.s3.secret.secretKeyKey | quote }}
      {{- if .Values.backup.s3.secret.regionKey }}
      region:
        name: {{ .Values.backup.s3.secret.name | quote }}
        key: {{ .Values.backup.s3.secret.regionKey | quote }}
      {{- end }}
      {{- end }}
    wal:
      compression: {{ .Values.backup.wal.compression }}
      maxParallel: {{ .Values.backup.wal.maxParallel }}
    data:
      compression: {{ .Values.backup.data.compression }}
      jobs: {{ .Values.backup.data.jobs }}
  {{- end }}
  {{- if .Values.backup.volumeSnapshot.enabled }}
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
{{- end }}
