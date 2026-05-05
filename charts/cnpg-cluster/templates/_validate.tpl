{{- define "cnpg.validate" -}}

{{- /* instances */}}
{{- if not .Values.instances }}
  {{- fail "instances is required" }}
{{- end }}

{{- /* image */}}
{{- if and (not .Values.imageName) (not .Values.imageCatalogRef.name) }}
  {{- fail "either imageName or imageCatalogRef must be set (imageName is preferred)" }}
{{- end }}

{{- end }}
