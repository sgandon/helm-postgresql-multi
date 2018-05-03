{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
Truncate at 63 chars characters due to limitations of the DNS system.
*/}}
{{- define "tpostgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "tpostgresql.fullname" -}}
{{- $name := (include "tpostgresql.name" .) -}}
{{- printf "%s-%s" .Release.Name $name -}}
{{- end -}}

{{/*
Create a default chart name including the version number
*/}}
{{- define "tpostgresql.chart" -}}
{{- $name := (include "tpostgresql.name" .) -}}
{{- printf "%s" $name | replace "+" "_" -}}
{{- end -}}


{{/*
Define labels which are used throughout the chart files
*/}}
{{- define "tpostgresql.labels" -}}
app: {{ include "tpostgresql.fullname" . }}
chart: {{ include "tpostgresql.chart" . }}
release: {{ .Release.Name }}
heritage: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "tpostgresql.serviceAccoundName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "tpostgresql.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}


{{/*
compute Postgres Jdbc url from values for flyway, cause flyway fails to connect using only the service name
so we use the complete dns name but I don't know why this fails.
*/}}
{{- define "tpostgresql.postgresql.embedded.host" -}}
{{- $port := .Values.postgresqlembedded.service.port | toString -}}
{{- $release:= default .Release.Name .Values.global.infraReleaseName | toString -}}
{{- printf "%s-%s" $release .Values.postgresqlembedded.service.name -}}
{{- end -}}


{{/*
compute postgres secret name from values
*/}}
{{- define "tpostgresql.master.secret" -}}
{{- $release:= default .Release.Name .Values.global.infraReleaseName | toString -}}
{{- printf "%s-%s" $release .Values.masterSecretName -}}
{{- end -}}

{{/*
compute postgres osba secret name from values
*/}}
{{- define "tpostgresql.osba.secret" -}}
{{- $release:= default .Release.Name .Values.global.infraReleaseName | toString -}}
{{- printf "%s-%s" $release "postgresql-osba-secret" -}}
{{- end -}}

{{/*
compute postgres embedded secret name from values
*/}}
{{- define "tpostgresql.embedded.secret" -}}
{{- $release:= default .Release.Name .Values.global.infraReleaseName | toString -}}
{{/*hack to have the name of secret, cause service name must match chart name*/}}
{{- printf "%s-%s" $release .Values.postgresqlembedded.service.name -}}
{{- end -}}
