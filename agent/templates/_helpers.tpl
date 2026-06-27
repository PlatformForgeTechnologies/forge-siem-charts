{{- define "agent.name" -}}forge-siem-agent{{- end -}}

{{- define "agent.fullname" -}}{{ include "agent.name" . }}-{{ .Release.Name }}{{- end -}}

{{- define "agent.labels" -}}
app.kubernetes.io/name: {{ include "agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "agent.groups" -}}
{{- join "," .Values.enrollment.groups -}}
{{- end -}}
