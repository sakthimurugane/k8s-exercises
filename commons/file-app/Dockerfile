FROM alpine:latest

# Install NGINX
RUN apk add --no-cache nginx

# Create required dirs
RUN mkdir -p /run/nginx /usr/share/nginx/html /mnt/logs

# Copy index.html
COPY index.html /usr/share/nginx/html/index.html

# Copy custom nginx.conf
COPY nginx.conf /etc/nginx/nginx.conf

# Expose HTTP
EXPOSE 80

# Start NGINX in foreground
CMD ["nginx", "-g", "daemon off;"]

