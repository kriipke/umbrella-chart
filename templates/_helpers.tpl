{{- define "umbrella-chart.ingress" -}}
{{- if .Values.ingress.host }}
  {{- if not (or (eq .Values.ingress.type "aws") (eq .Values.ingress.type "emissary")) }}
    {{- fail ".Values.ingress.type must be either 'aws' or 'emissary' when .Values.ingress.host is not empty" }}
  {{- end }}
{{- end }}

{{- if eq .Values.ingress.type "aws" }}

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-aws-ingress
  annotations:
    alb.ingress.kubernetes.io/scheme: {{ default "internal" .Values.ingress.aws.scheme }}
    alb.ingress.kubernetes.io/target-type: {{ default "ip" .Values.ingress.aws.targetType }}
    alb.ingress.kubernetes.io/subnets: {{ required ".Values.ingress.aws.subnet must contain values." ( .Values.ingress.aws.subnets | join "," ) }}
    alb.ingress.kubernetes.io/security-groups: {{  required ".Values.ingress.aws.subnet must contain values." ( .Values.ingress.aws.securityGroups | join "," ) }}
    {{- if .Values.ingress.aws.sslCertificateArn }}
    alb.ingress.kubernetes.io/certificate-arn: {{ .Values.ingress.aws.sslCertificateArn }}
    {{- end }}
spec:
  rules:
    - host: {{ .Values.ingress.host }}
      http:
        paths:
          - path: {{ default "/" .Values.ingress.path }}
            pathType: Prefix
            backend:
              service:
                name: {{ .Release.Name }}-service
                port:
                  number: 80

{{- else if eq .Values.ingress.type "emissary" }}

apiVersion: getambassador.io/v3alpha1
kind: Mapping
metadata:
  name: {{ .Release.Name }}-mapping
  {{- if .Values.ingress.emissary.annotations }}
  annotations:
    {{- with .Values.ingress.emissary.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  prefix: {{ default "/" .Values.ingress.path }}
  host: {{ .Values.ingress.host }}
  service: {{ .Release.Name }}-service.{{ .Release.Namespace }}.svc.cluster.local
  timeout_ms: {{ default "60000" .Values.ingress.emissary.timeout }}
  retries: {{ default "3" .Values.ingress.emissary.retries }}

{{- else }}
# Ingress type is not specified or invalid
{{- fail "ingress.type must be either 'aws' or 'emissary'" }}
{{- end }}
{{- end }}


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
    name: {{ .Chart.Name }}
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
