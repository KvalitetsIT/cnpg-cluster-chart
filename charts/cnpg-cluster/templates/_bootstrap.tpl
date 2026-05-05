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
