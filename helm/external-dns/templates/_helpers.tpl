{{- define "external-dns.name" -}}
{{- .Chart.Name }}
{{- end }}

{{- define "external-dns.fullname" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "external-dns.clusterRoleName" -}}
{{- printf "%s-%s" (include "external-dns.fullname" .) (sha256sum .Release.Namespace | trunc 8) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "external-dns.labels" -}}
app.kubernetes.io/name: {{ include "external-dns.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}
