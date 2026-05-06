{{- define "cnpg-cluster.fullname" -}}
{{- .Values.nameOverride | default .Release.Name | trunc 63 | trimSuffix "-" }}
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
