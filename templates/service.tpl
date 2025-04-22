{{- define "umbrella-chart.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
spec:
  ports:
  - port: {{ .Values.service.port }}
  selector:
    app: {{ .Chart.Name }}
{{- end }}
