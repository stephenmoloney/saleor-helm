{{/* vim: set filetype=mustache: */}}

{{/*
Expand the name of the chart.
*/}}
{{- define "saleor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified saleor app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "saleor.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified sentry app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sentry.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "saleor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Generate standard environment configuration.
*/}}
{{- define "saleor.standardEnv" }}
{{- $smtp := .Values.saleor.django.email.smtpSettings }}
envFrom:
  - configMapRef:
      name: {{ template "saleor.fullname" . }}-env
env:
{{- if and (eq .Values.sentry.enabled true) (eq .Values.sentry.user.project.create true)  }}
  - name: SENTRY_PUBLIC_KEY
    valueFrom:
      configMapKeyRef:
        name: {{ .Release.Name }}-sentry
        key: public-key
  - name: SENTRY_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.sentry.existingSecret }}
        name: {{ .Values.sentry.existingSecret }}
      {{- else }}
        name: {{ .Release.Name }}-sentry
      {{- end }}
        key: private-key
{{- end }}
{{- if eq .Values.postgresql.enabled true }}
  - name: POSTGRESQL_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.postgresql.existingSecret }}
        name: {{ .Values.postgresql.existingSecret }}
      {{- else }}
        name: {{ .Release.Name }}-postgresql
      {{- end }}
        key: postgresql-password
{{- else }}
  - name: POSTGRESQL_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.postgresql.existingSecret }}
        name: {{ .Values.postgresql.existingSecret }}
      {{- else }}
        name: {{ .Release.Name }}-postgresql
      {{- end }}
        key: ext-postgresql-password
{{- end }}
{{- if and (eq .Values.redis.enabled true) (eq .Values.redis.usePassword true) }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.redis.existingSecret }}
        name: {{ .Values.redis.existingSecret }}
      {{- else }}
        name: {{ .Release.Name }}-redis
      {{- end }}
        key: redis-password
{{- end }}
{{- if eq .Values.redis.enabled false }}
  - name: REDIS_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.redis.existingSecret }}
        name: {{ .Values.redis.existingSecret }}
      {{- else }}
        name: {{ .Release.Name }}-redis
      {{- end }}
        key: ext-redis-password
{{- end }}
{{- if and (eq .Values.elasticsearch.enabled false) (eq .Values.saleor.django.externalServices.elasticsearch.enabled true) }}
  - name: ELASTICSEARCH_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.existingSecret }}
        name: {{ .Values.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: ext-elasticsearch-password
{{- end }}
  - name: EMAIL_PASSWORD
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: email-password
        optional: true
  - name: OPENEXCHANGERATES_API_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: open-exchanges-api-key
  - name: RECAPTCHA_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: recaptcha-private-key
        optional: true
  - name: SECRET_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: saleor-secret-key
  - name: VATLAYER_ACCESS_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: vat-layer-access-key
        optional: true
{{- if or (eq .Values.saleor.django.aws.static.enabled true) (eq .Values.saleor.django.aws.media.enabled true) -}}
  - name: AWS_ACCESS_KEY_ID
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: aws-access-key-id
  - name: AWS_SECRET_ACCESS_KEY
    valueFrom:
      secretKeyRef:
      {{- if .Values.saleor.existingSecret }}
        name: {{ .Values.saleor.existingSecret }}
      {{- else }}
        name: {{ template "saleor.fullname" . }}
      {{- end }}
        key: aws-access-key-secret
{{- end -}}

{{- if eq .Values.postgresql.enabled true }}
  - name: DATABASE_URL
    value: "postgres://$(POSTGRESQL_USER):$(POSTGRESQL_PASSWORD)@$(POSTGRESQL_HOST):$(POSTGRESQL_PORT)/$(POSTGRESQL_DATABASE)"
{{- else if (eq .Values.saleor.django.externalServices.postgresql.requireSSL true) }}
  - name: DATABASE_URL
    value: "postgres://$(POSTGRESQL_USER):$(POSTGRESQL_PASSWORD)@$(POSTGRESQL_HOST):$(POSTGRESQL_PORT)/$(POSTGRESQL_DATABASE)?sslmode=verify-full"
{{- else if (eq .Values.saleor.django.externalServices.postgresql.requireSSL false) }}
  - name: DATABASE_URL
    value: "postgres://$(POSTGRESQL_USER):$(POSTGRESQL_PASSWORD)@$(POSTGRESQL_HOST):$(POSTGRESQL_PORT)/$(POSTGRESQL_DATABASE)"
{{- end }}

{{- if eq $smtp.generic.enabled true }}
  - name: EMAIL_URL
    value: "smtp://{{ $smtp.generic.loginName }}@{{ $smtp.generic.customDomainName }}:$(EMAIL_PASSWORD)@{{ $smtp.generic.providerDomainName }}:{{ $smtp.generic.port }}/{{ $smtp.generic.extraArgs }}"
{{- else if (eq $smtp.mailjet.enabled true) }}
  - name: EMAIL_URL
    value: "smtp://{{ $smtp.mailjet.username }}:$(EMAIL_PASSWORD)@in-v3.mailjet.com:587/?tls=True"
{{- else if (eq $smtp.amazonSES.enabled true) }}
  - name: EMAIL_URL
    value: "smtp://{{ $smtp.amazonSES.username }}:$(EMAIL_PASSWORD)@email-smtp.{{ $smtp.amazonSES.region }}.amazonaws.com:587/?tls=True"
{{- end }}

{{- if eq .Values.elasticsearch.enabled true }}
  - name: ELASTICSEARCH_URL
    value: "http://$(ELASTICSEARCH_HOST):$(ELASTICSEARCH_PORT)"
{{- else if .Values.saleor.django.externalServices.elasticsearch.enabled true }}
{{- if .Values.saleor.django.externalServices.elasticsearch.tls true }}
  - name: ELASTICSEARCH_URL
    value: "https://$(ELASTICSEARCH_USER):$(ELASTICSEARCH_PASSWORD)@$(ELASTICSEARCH_HOST):$(ELASTICSEARCH_PORT)"
{{- else }}
  - name: ELASTICSEARCH_URL
    value: "http://$(ELASTICSEARCH_USER):$(ELASTICSEARCH_PASSWORD)@$(ELASTICSEARCH_HOST):$(ELASTICSEARCH_PORT)"
{{- end }}
{{- end }}

{{- if eq .Values.redis.enabled false }}
{{- if eq .Values.redis.tls true }}
  - name: REDIS_URL
    value: "rediss://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(REDIS_DB_NUMBER)"
  - name: CELERY_BROKER_URL
    value: "rediss://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(CELERY_BROKER_DB_NUMBER)"
{{- else }}
  - name: REDIS_URL
    value: "redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(REDIS_DB_NUMBER)"
  - name: CELERY_BROKER_URL
    value: "redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(CELERY_BROKER_DB_NUMBER)"
{{- end }}
{{- else if eq .Values.redis.usePassword true }}
  - name: REDIS_URL
    value: "redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(REDIS_DB_NUMBER)"
  - name: CELERY_BROKER_URL
    value: "redis://:$(REDIS_PASSWORD)@$(REDIS_HOST):$(REDIS_PORT)/$(CELERY_BROKER_DB_NUMBER)"
{{- else }}
  - name: REDIS_URL
    value: "redis://$(REDIS_HOST):$(REDIS_PORT)/$(REDIS_DB_NUMBER)"
  - name: CELERY_BROKER_URL
    value: "redis://$(REDIS_HOST):$(REDIS_PORT)/$(CELERY_BROKER_DB_NUMBER)"
{{- end }}
{{- end -}}

{{/*
A script to check if the saleor-postgresql service is ready
*/}}
{{- define "saleor.postgresql.isReady" -}}
function is_pg_ready {
  pg_isready \
    --host={{ .Release.Name }}-postgresql \
    --port={{ .Values.postgresql.service.port }} \
    --username={{ .Values.postgresql.postgresqlUsername }} \
    --dbname={{ .Values.postgresql.postgresqlDatabase }} \
    --timeout=1
}

while [[ "$(is_pg_ready)" != *"accepting connections"* ]]; do
  echo "response from server: $(is_pg_ready)";
  echo "waiting for {{ .Release.Name }}-postgresql service" && sleep 5s;
done

echo "$(is_pg_ready)"
echo "{{ .Release.Name }}-postgresql is ready"
{{- end -}}

{{/*
A script to check if the elasticsearch service is ready
*/}}
{{- define "saleor.elasticsearch.isReady" -}}

function elasticsearch_status {
  curl --silent --max-time 5 '{{ .Release.Name }}-{{ .Values.elasticsearch.cluster.name }}-client:9200/_cat/health' | awk '{print $4}'
}

while [[ "$(elasticsearch_status)" != "green" ]]; do
  echo "waiting for {{ .Release.Name }}-{{ .Values.elasticsearch.cluster.name }}-client to be have green status" && sleep 5s;
done

echo "current status: $(elasticsearch_status)"
{{- end -}}


{{/*
A script to check if the redis service is ready
*/}}
{{- define "saleor.redis.isReady" -}}

#!/bin/bash

function redis_status {
  redis-cli --no-auth-warning -u "$(REDIS_URL)" ping
}

while [[ "$(redis_status)" != "PONG" ]]; do
  echo "waiting for saleor-redis-master return PONG" && sleep 5s;
done

echo "redis current ping response: $(redis_status)"
{{- end -}}
