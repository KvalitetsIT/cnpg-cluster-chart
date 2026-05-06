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
