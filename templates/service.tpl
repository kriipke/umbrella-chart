{{- define "umbrella-chart.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
  labels:
    {{ include "umbrella.labels" . | nindent 4 }}
  annotations:
    {{ include "umbrella.annotations" . | nindent 4 }}
spec:
  ports:
    - port: {{ .Values.service.port }}
  selector:
    app: {{ .Chart.Name }}
{{- end }}
