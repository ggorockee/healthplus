{{/*
Expand the name of the chart.
*/}}
{{- define "healthplus.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "healthplus.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "healthplus.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "healthplus.labels" -}}
helm.sh/chart: {{ include "healthplus.chart" . }}
{{ include "healthplus.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.environmentType }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "healthplus.selectorLabels" -}}
app.kubernetes.io/name: {{ include "healthplus.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "healthplus.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "healthplus.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get environment-specific configuration based on environmentType
This helper function returns the entire configuration block for the current environment
*/}}
{{- define "healthplus.envConfig" -}}
{{- if eq .Values.environmentType "production" }}
{{- toYaml .Values.production }}
{{- else }}
{{- toYaml .Values.development }}
{{- end }}
{{- end }}

{{/*
Get environment-specific config data for ConfigMap
*/}}
{{- define "healthplus.configData" -}}
{{- if eq .Values.environmentType "production" }}
{{- toYaml .Values.production.config }}
{{- else }}
{{- toYaml .Values.development.config }}
{{- end }}
{{- end }}

{{/*
Get environment-specific replica count
*/}}
{{- define "healthplus.replicaCount" -}}
{{- if eq .Values.environmentType "production" }}
{{- .Values.production.replicaCount }}
{{- else }}
{{- .Values.development.replicaCount }}
{{- end }}
{{- end }}

{{/*
Get environment-specific resources
*/}}
{{- define "healthplus.resources" -}}
{{- if eq .Values.environmentType "production" }}
{{- toYaml .Values.production.resources }}
{{- else }}
{{- toYaml .Values.development.resources }}
{{- end }}
{{- end }}

{{/*
Get environment-specific liveness probe
*/}}
{{- define "healthplus.livenessProbe" -}}
{{- if eq .Values.environmentType "production" }}
{{- toYaml .Values.production.livenessProbe }}
{{- else }}
{{- toYaml .Values.development.livenessProbe }}
{{- end }}
{{- end }}

{{/*
Get environment-specific readiness probe
*/}}
{{- define "healthplus.readinessProbe" -}}
{{- if eq .Values.environmentType "production" }}
{{- toYaml .Values.production.readinessProbe }}
{{- else }}
{{- toYaml .Values.development.readinessProbe }}
{{- end }}
{{- end }}

{{/*
Pod labels including extra labels for fluent-bit
*/}}
{{- define "healthplus.podLabels" -}}
{{ include "healthplus.selectorLabels" . }}
environment: {{ .Values.environmentType }}
{{- with .Values.podExtraLabels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Create namespace name
*/}}
{{- define "healthplus.namespace" -}}
{{- if .Values.namespaceOverride }}
{{- .Values.namespaceOverride }}
{{- else }}
{{- .Release.Namespace }}
{{- end }}
{{- end }}