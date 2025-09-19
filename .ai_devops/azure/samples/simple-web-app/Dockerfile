# Simple Web Application Dockerfile
# This is a sample application for Azure Container Instances deployment

FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy static content
COPY static/ /usr/share/nginx/html/

# Copy health check script
COPY health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/health-check.sh

# Add labels for better container management
LABEL maintainer="CloudeAgent" \
      version="1.0.0" \
      description="Simple web application for Azure Container Instances" \
      azure.deployment.framework="ai-devops"

# Ensure /tmp is writable (default, but explicit)
RUN chmod 755 /tmp

# Simple health check using curl (more reliable than wget)
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

# Expose port
EXPOSE 80

# Keep as root user for Azure Container Instances (acceptable for containers)

# Start nginx
CMD ["nginx", "-g", "daemon off;"]