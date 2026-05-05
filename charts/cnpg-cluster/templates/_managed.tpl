{{- define "cnpg.managed" -}}
{{- if .Values.roles }}
managed:
  roles:
    {{- toYaml .Values.roles | nindent 4 }}
{{- end }}
{{- end }}
