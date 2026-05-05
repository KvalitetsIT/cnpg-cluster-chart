{{- define "cnpg.managed" -}}
{{- if or .Values.roles .Values.databases }}
managed:
  {{- with .Values.roles }}
  roles:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.databases }}
  databases:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
