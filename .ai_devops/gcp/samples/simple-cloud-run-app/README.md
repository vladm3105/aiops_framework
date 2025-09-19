# Simple Cloud Run Application

A sample Flask application designed for Google Cloud Run deployment, demonstrating best practices for containerized applications in GCP.

## Features

- **Health Checks**: Comprehensive health, startup, and readiness probes
- **Logging**: Structured logging with Google Cloud Logging integration
- **Monitoring**: Prometheus metrics and Google Cloud Monitoring integration
- **Error Reporting**: Automatic error reporting to Google Cloud Error Reporting
- **Security**: Non-root container execution and secure defaults
- **Configuration**: Environment-based configuration management
- **Dashboard**: Simple web dashboard for application status

## Quick Start

### Prerequisites

- Google Cloud CLI (`gcloud`) installed and authenticated
- Docker installed
- Google Cloud project with billing enabled
- Required APIs enabled: Cloud Run, Cloud Build, Container Registry

### Deploy the Application

1. **Set your project ID:**
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   ```

2. **Deploy using the deployment script:**
   ```bash
   chmod +x deploy.sh
   ./deploy.sh $PROJECT_ID
   ```

3. **Or deploy manually:**
   ```bash
   # Build and push image
   docker build -t gcr.io/$PROJECT_ID/simple-cloud-run-app:latest .
   docker push gcr.io/$PROJECT_ID/simple-cloud-run-app:latest
   
   # Deploy to Cloud Run
   gcloud run deploy simple-cloud-run-app \
     --image gcr.io/$PROJECT_ID/simple-cloud-run-app:latest \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

## Application Endpoints

| Endpoint | Description | Purpose |
|----------|-------------|---------|
| `/` | Home page with application info | Main application endpoint |
| `/health` | Health check endpoint | Cloud Run health checks |
| `/startup` | Startup probe endpoint | Cloud Run startup probes |
| `/ready` | Readiness probe endpoint | Kubernetes-style readiness checks |
| `/metrics` | Prometheus metrics | Monitoring and observability |
| `/config` | Application configuration | Configuration inspection |
| `/info` | Detailed application information | Diagnostics and debugging |
| `/dashboard` | Simple HTML dashboard | Web-based status overview |
| `/test-error` | Test error endpoint (non-prod) | Error reporting testing |
| `/test-log` | Test logging endpoint (non-prod) | Log level testing |

## Environment Configuration

The application supports three deployment environments:

### Development
- Debug mode enabled
- Verbose logging (debug level)
- Lower resource limits
- Unauthenticated access allowed
- Test endpoints enabled

### Staging
- Production-like configuration
- Info-level logging
- Medium resource allocation
- Unauthenticated access allowed
- Test endpoints disabled

### Production
- Optimized for performance
- Warning-level logging
- High resource allocation
- Authentication required
- Test endpoints disabled

## Configuration Options

Environment variables for customization:

| Variable | Default | Description |
|----------|---------|-------------|
| `ENVIRONMENT` | `development` | Deployment environment |
| `DEBUG` | `false` | Enable debug mode |
| `LOG_LEVEL` | `info` | Logging level (debug, info, warn, error) |
| `PORT` | `8080` | Application port |
| `ENABLE_MONITORING` | `true` | Enable Prometheus metrics |
| `GOOGLE_CLOUD_PROJECT` | - | GCP project ID (auto-detected) |
| `GOOGLE_CLOUD_REGION` | `us-central1` | GCP region |
| `DEPLOYED_BY` | `manual` | Deployment source identifier |
| `DEPLOYMENT_TIME` | - | Deployment timestamp (auto-generated) |

## Cloud Run Configuration

### Resource Specifications

| Environment | CPU | Memory | Min Instances | Max Instances | Concurrency |
|-------------|-----|--------|---------------|---------------|-------------|
| Development | 1 | 512Mi | 0 | 10 | 10 |
| Staging | 1 | 1Gi | 0 | 50 | 50 |
| Production | 2 | 2Gi | 1 | 100 | 100 |

### Health Check Configuration

- **Startup Probe**: `/startup` endpoint, 240s timeout
- **Liveness Probe**: `/health` endpoint, 10s interval
- **Readiness Probe**: `/ready` endpoint, 30s timeout

## Monitoring and Observability

### Google Cloud Integration

- **Cloud Logging**: Structured JSON logs with automatic ingestion
- **Cloud Monitoring**: Custom metrics and performance monitoring
- **Error Reporting**: Automatic exception tracking and alerting
- **Cloud Trace**: Request tracing (optional, configurable)

### Prometheus Metrics

The `/metrics` endpoint exposes:

- `app_requests_total`: Total number of requests by method, endpoint, and status
- `app_request_duration_seconds`: Request duration histogram
- Standard Python/Flask metrics

### Log Structure

All logs use structured JSON format:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "info",
  "logger": "app",
  "message": "Request completed",
  "method": "GET",
  "path": "/health",
  "status_code": 200,
  "duration": 0.045,
  "user_agent": "GoogleHC/1.0",
  "remote_addr": "10.1.1.1"
}
```

## Security Features

### Container Security
- **Non-root execution**: Application runs as `appuser` (UID 1000)
- **Minimal base image**: Python 3.11 slim image
- **Security scanning**: Automatic vulnerability scanning in GCR
- **Read-only filesystem**: Root filesystem mounted read-only (configurable)

### Application Security
- **Secret management**: Integration with Google Secret Manager
- **HTTPS only**: Automatic HTTPS termination by Cloud Run
- **IAM integration**: Service account-based authentication
- **Input validation**: Request validation and sanitization

### Network Security
- **VPC integration**: Optional VPC connector support
- **Ingress control**: Configurable ingress (all, internal, internal+LB)
- **Egress control**: Configurable egress (all, private ranges only)

## Performance Optimization

### Cold Start Optimization
- **Minimal dependencies**: Optimized requirements.txt
- **Layer caching**: Multi-stage Docker builds
- **Fast startup**: Minimal initialization time
- **CPU boost**: Optional startup CPU boost

### Runtime Performance
- **Gunicorn WSGI**: Production-ready WSGI server
- **Connection pooling**: Efficient database connections
- **Caching**: Application-level caching strategies
- **Resource tuning**: Environment-specific resource allocation

## Development Workflow

### Local Development
1. **Set up environment:**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Run locally:**
   ```bash
   export ENVIRONMENT=development
   export DEBUG=true
   python app.py
   ```

3. **Test endpoints:**
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8080/metrics
   ```

### Testing with Docker
1. **Build image:**
   ```bash
   docker build -t simple-cloud-run-app .
   ```

2. **Run container:**
   ```bash
   docker run -p 8080:8080 -e ENVIRONMENT=development simple-cloud-run-app
   ```

3. **Test application:**
   ```bash
   curl http://localhost:8080/dashboard
   ```

## Deployment Strategies

### Blue-Green Deployment
```bash
# Deploy new version without traffic
gcloud run deploy simple-cloud-run-app \
  --image gcr.io/$PROJECT_ID/simple-cloud-run-app:v2 \
  --no-traffic \
  --tag blue

# Validate deployment
curl https://blue---simple-cloud-run-app-xyz.a.run.app/health

# Switch traffic
gcloud run services update-traffic simple-cloud-run-app \
  --to-tags blue=100
```

### Canary Deployment
```bash
# Deploy canary version
gcloud run deploy simple-cloud-run-app \
  --image gcr.io/$PROJECT_ID/simple-cloud-run-app:v2 \
  --tag canary \
  --no-traffic

# Route 10% traffic to canary
gcloud run services update-traffic simple-cloud-run-app \
  --to-tags canary=10
```

## Troubleshooting

### Common Issues

#### Service Won't Start
1. Check service logs:
   ```bash
   gcloud run services logs read simple-cloud-run-app --region us-central1
   ```

2. Verify image exists:
   ```bash
   gcloud container images list --repository=gcr.io/$PROJECT_ID
   ```

3. Check service configuration:
   ```bash
   gcloud run services describe simple-cloud-run-app --region us-central1
   ```

#### Health Checks Failing
1. Test health endpoint directly:
   ```bash
   curl -v https://your-service-url/health
   ```

2. Check startup logs for initialization errors
3. Verify environment variables are set correctly

#### Performance Issues
1. Monitor metrics:
   ```bash
   # View request latency
   curl https://your-service-url/metrics | grep app_request_duration
   ```

2. Check resource utilization in Cloud Console
3. Analyze cold start frequency

### Debugging Commands

```bash
# View service status
gcloud run services list --region us-central1

# Get service URL
gcloud run services describe simple-cloud-run-app \
  --region us-central1 \
  --format="value(status.url)"

# View real-time logs
gcloud run services logs read simple-cloud-run-app \
  --region us-central1 \
  --follow

# Check resource usage
gcloud run services describe simple-cloud-run-app \
  --region us-central1 \
  --format="table(spec.template.spec.containers[0].resources)"
```

## Integration with AI DevOps Framework

This sample application is designed to work with the AI DevOps Framework:

- **Automated deployment**: Compatible with framework deployment scripts
- **Monitoring integration**: Metrics and logs feed into AI monitoring agents
- **Health validation**: Endpoints support automated health checking
- **Configuration management**: Environment-based configuration
- **Security compliance**: Follows framework security standards

### Framework Integration Points

1. **Deployment Scripts**: Use with `../scripts/deploy-cloud-run.sh`
2. **Validation Scripts**: Compatible with `../scripts/validate-cloud-run.sh`
3. **Management Scripts**: Use with `../scripts/manage-cloud-run.sh`
4. **AI Prompts**: Provides data for Claude analysis prompts
5. **Monitoring**: Integrates with framework monitoring strategy

## Contributing

When modifying this sample application:

1. Maintain compatibility with all three environments
2. Update health check endpoints as needed
3. Follow security best practices
4. Update documentation for any new features
5. Test deployment in development environment first

## Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Google Cloud Python Client Libraries](https://cloud.google.com/python/docs/reference)
- [Container Best Practices](https://cloud.google.com/solutions/best-practices-for-building-containers)
- [Cloud Run Security](https://cloud.google.com/run/docs/securing/service-identity)