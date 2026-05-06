{{- define "cnpg.monitoring" -}}
{{- if .Values.monitoring.enabled }}
monitoring:
  enablePodMonitor: {{ .Values.monitoring.podMonitor.enabled }}
  {{- with .Values.monitoring.podMonitor.relabelings }}
  podMonitorRelabelings:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.monitoring.podMonitor.metricRelabelings }}
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
