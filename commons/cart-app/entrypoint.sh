#!/bin/sh

# Inject environment variable into the HTML
envsubst '$POD_NAME' < /usr/share/nginx/html/index.template.html > /usr/share/nginx/html/index.html
# Start NGINX
exec nginx -g "daemon off;"

