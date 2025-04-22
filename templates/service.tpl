{{- define "umbrella-chart.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ include (print .Chart.Name ".fullname") . }}
  labels:
    {{- include "umbrella.labels" . | nindent 4 }}
  annotations:
    {{- include "umbrella.annotations" . | nindent 4 }}
spec:
  ports:
    - port: {{ .Values.service.port }}
  selector:
    app: {{ include (print .Chart.Name ".fullname") . }}
{{- end }}
