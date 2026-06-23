{{- define "byoc.image" -}}
{{ .Values.image.registry }}/{{ . }}:{{ .Values.image.tag }}
{{- end -}}

{{- define "byoc.commonEnv" -}}
- name: PG_DSN
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: pg-dsn
- name: REDIS_ADDR
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: redis-addr
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: redis-password
- name: CLICKHOUSE_ADDR
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: clickhouse-addr
- name: CLICKHOUSE_DB
  value: {{ .Values.dependencies.clickhouse.database | quote }}
- name: CLICKHOUSE_USER
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: clickhouse-user
- name: CLICKHOUSE_PASS
  valueFrom:
    secretKeyRef:
      name: forge-byoc-secrets
      key: clickhouse-pass
{{- end -}}
