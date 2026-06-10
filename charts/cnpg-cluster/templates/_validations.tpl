{{- define "cnpg-cluster.validate.instances" -}}
{{- if not .Values.instances }}
  {{- fail "instances is required" }}
{{- end }}
{{- end }}

{{- define "cnpg-cluster.validate.image" -}}
{{- if and (not .Values.imageName) (not .Values.imageCatalogRef.name) }}
  {{- fail "either imageName or imageCatalogRef must be set (imageName is preferred)" }}
{{- end }}
{{- end }}

{{- define "cnpg-cluster.validate.bootstrap" -}}
{{- if gt (len (compact (list .Values.initdb .Values.recovery .Values.pgBaseBackup))) 1 }}
  {{- fail "only one of initdb, recovery, or pgBaseBackup may be set" }}
{{- end }}
{{- end }}

{{- define "cnpg-cluster.validate.objectStore" -}}
{{- if and .Values.objectStore.enabled .Values.objectStore.configuration.endpointURL }}
  {{- fail "objectStore.configuration.endpointURL is not supported. Use global.objectStore.configuration.endpointURL instead." }}
{{- end }}
{{- if and .Values.objectStore.enabled (not .Values.global.objectStore.configuration.endpointURL) }}
  {{- fail "global.objectStore.configuration.endpointURL is required when objectStore is enabled" }}
{{- end }}
{{- end }}
