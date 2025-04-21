{{- define "umbrella-chart.hpa" -}}
{{- if eq .Values.podCount.type "dynamic" }}
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ .Chart.Name }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ .Values.service.name }}
  minReplicas: {{ .Values.podCount.dynamic.minReplicas }}
  maxReplicas: {{ .Values.podCount.dynamic.maxReplicas }}
  metrics:
  {{- with .Values.podCount.dynamic.metrics }}
    {{- toYaml . | nindent 4 }}
  {{- else }}
    {{- with .Values.podCount.dynamic.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: {{ . }}
    {{- end }}
    {{- with .Values.podCount.dynamic.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: {{ . }}
    {{- end }}
  {{- end }}
  {{- with .Values.podCount.dynamic.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
