FROM nginx:alpine

# Copy template
COPY index.template.html /usr/share/nginx/html/index.template.html

# Copy health-check config
COPY health-check.conf /etc/nginx/conf.d/health-check.conf

# Add entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

