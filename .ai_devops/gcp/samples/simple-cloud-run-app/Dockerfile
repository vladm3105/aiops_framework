# Simple Cloud Run Application Dockerfile
# This is a sample application for Google Cloud Run deployment

FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Copy application code
COPY . .

# Set proper ownership
RUN chown -R appuser:appuser /app

# Add labels for better container management
LABEL maintainer="CloudeAgent" \
      version="1.0.0" \
      description="Simple Cloud Run application for AI DevOps framework" \
      gcp.deployment.framework="ai-devops"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Switch to non-root user
USER appuser

# Expose port (Cloud Run uses PORT environment variable)
EXPOSE 8080

# Start application
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app