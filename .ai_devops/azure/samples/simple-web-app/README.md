# Simple Web Application for Azure Container Instances

This is a sample web application designed for deployment to Azure Container Instances using the AI DevOps framework.

## Application Overview

The application is a lightweight nginx-based web server that provides:

- **Static Web Content**: Modern, responsive web interface
- **Health Endpoints**: `/health` and `/ready` for monitoring
- **Error Pages**: Custom 404 and 5xx error pages
- **Security Headers**: Basic security configuration
- **Monitoring**: Built-in health checks and logging

## Quick Deployment

### Prerequisites
- Azure CLI installed and authenticated
- Docker (for custom builds)
- Bash shell

### One-Command Deployment
```bash
# Deploy with default settings
./deploy.sh

# Deploy without building (uses nginx:latest)
./deploy.sh false my-app production rg-prod "West US"
```

### Manual Deployment Steps

1. **Build the image** (optional):
   ```bash
   docker build -t simple-web-app:latest .
   ```

2. **Deploy to Azure**:
   ```bash
   ../scripts/deploy-docker-container.sh \
     "my-web-app" \
     "simple-web-app:latest" \
     "development" \
     "rg-containers" \
     "East US"
   ```

3. **Validate deployment**:
   ```bash
   ../scripts/validate-deployment.sh rg-containers my-web-app
   ```

## Application Structure

```
simple-web-app/
├── Dockerfile              # Container definition
├── nginx.conf              # Nginx configuration
├── health-check.sh         # Health check script
├── deploy.sh               # Deployment automation
├── README.md               # This file
└── static/                 # Web content
    ├── index.html          # Main page
    ├── 404.html            # Not found page
    └── 50x.html            # Server error page
```

## Configuration

### Environment Variables

The application responds to these environment variables:

- `ENVIRONMENT`: deployment environment (development/staging/production)
- `DEPLOYED_BY`: who/what deployed the application
- `DEPLOYMENT_TIME`: when the application was deployed

### Health Checks

The application provides multiple health check endpoints:

- `GET /health` - Basic health status
- `GET /ready` - Readiness check
- Built-in Docker health check every 30 seconds

### Security Features

- Runs as non-root user (nginx)
- Security headers enabled
- Server tokens hidden
- Input validation on endpoints

## Customization

### Modifying Content

Edit files in the `static/` directory to customize the web application:

- `index.html` - Main application page
- `404.html` - Custom 404 error page
- `50x.html` - Server error pages

### Nginx Configuration

Modify `nginx.conf` to:
- Add new routes
- Configure proxy backends
- Adjust security settings
- Enable additional features

### Health Checks

Customize `health-check.sh` to:
- Add application-specific checks
- Integrate with external dependencies
- Modify check intervals
- Add custom monitoring

## Deployment Options

### Development Environment
```bash
./deploy.sh true dev-app development rg-dev "East US"
```

### Staging Environment
```bash
./deploy.sh true staging-app staging rg-staging "Central US"
```

### Production Environment
```bash
./deploy.sh true prod-app production rg-prod "West US 2"
```

## Monitoring and Troubleshooting

### View Logs
```bash
az container logs --resource-group rg-containers --name my-app --follow
```

### Check Status
```bash
../scripts/cleanup-containers.sh status rg-containers my-app
```

### Restart Application
```bash
az container restart --resource-group rg-containers --name my-app
```

### Debug Health Issues
```bash
# Test health endpoint directly
curl http://your-app-fqdn.eastus.azurecontainer.io/health

# Run comprehensive validation
../scripts/validate-deployment.sh rg-containers my-app
```

## Advanced Features

### Azure Container Registry Integration

The deployment script automatically:
1. Creates ACR if it doesn't exist
2. Builds and pushes custom images
3. Configures container authentication
4. Uses private registry for deployments

### Blue-Green Deployment

Deploy multiple versions for zero-downtime updates:

```bash
# Deploy green version
./deploy.sh true app-green production rg-prod

# Test green version
curl http://app-green-fqdn/health

# Switch traffic (manual DNS/load balancer update)
# Clean up blue version
az container delete --resource-group rg-prod --name app-blue --yes
```

### Auto-scaling with Azure Container Groups

For higher load, consider Azure Container Apps or AKS for auto-scaling capabilities.

## Performance Optimization

### Image Size Optimization
- Uses `nginx:alpine` for small base image
- Multi-stage builds supported
- Static content compression enabled

### Resource Configuration
- CPU: 0.5-2.0 cores based on environment
- Memory: 1-4 GB based on environment
- Storage: Minimal (1 GB)

### Caching
- Static assets cached for 1 month
- Gzip compression enabled
- Efficient nginx configuration

## Security Considerations

### Container Security
- Non-root user execution
- Read-only root filesystem option
- Minimal attack surface

### Network Security
- HTTPS support ready
- Security headers enabled
- Rate limiting can be added

### Secrets Management
- Environment variables for non-sensitive config
- Azure Key Vault integration available
- No secrets in container images

## Troubleshooting Guide

### Common Issues

**Container won't start:**
- Check image availability
- Verify resource limits
- Review container logs

**Health checks failing:**
- Test endpoints manually
- Check nginx configuration
- Verify port bindings

**Performance issues:**
- Monitor resource usage
- Check nginx access logs
- Consider resource scaling

### Getting Help

1. Check container logs first
2. Run validation script
3. Test health endpoints manually
4. Review Azure portal for insights

## Integration with AI DevOps Framework

This application is designed to work seamlessly with:

- **Claude Deployment Analysis**: Automated deployment readiness assessment
- **Infrastructure Validation**: Configuration and security validation
- **Performance Monitoring**: Built-in metrics and health checks
- **Cost Optimization**: Resource usage optimization recommendations

The application follows framework best practices for:
- Containerization standards
- Health check implementation
- Logging and monitoring
- Security configuration
- Deployment automation

## License

This sample application is provided as-is for demonstration purposes with the AI DevOps Framework.