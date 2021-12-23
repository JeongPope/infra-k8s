# Expands the image name. 
{{- define "redis.image" -}}
{{- printf "%s:%s" .Values.redis.image.repository .Values.redis.image.tags -}}
{{- end -}}