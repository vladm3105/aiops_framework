# Claude Agent Azure Container Deployment Guide

This guide provides step-by-step instructions for Claude agents to deploy Docker containers to Azure Container Instances.

## Prerequisites

### Required Tools
- Azure CLI (`az`) installed and authenticated
- Docker (optional, for building custom images)
- jq (for JSON processing)
- curl (for health checks)

### Azure Setup
- Azure subscription with appropriate permissions
- Resource group (will be created if it doesn't exist)
- Optional: Azure Container Registry for private images

### Authentication
```bash
# Login to Azure
az login

# Set subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

## Quick Start - Deploy Simple Container

### Step 1: Basic Nginx Deployment
```bash
# Navigate to Azure deployment directory
cd .ai_devops/azure

# Deploy default nginx container
./scripts/deploy-docker-container.sh
```

This will deploy:
- Container name: `simple-app`
- Image: `nginx:latest`
- Environment: `development`
- Resource group: `rg-containers`
- Location: `East US`

### Step 2: Verify Deployment
```bash
# Check deployment status
./scripts/cleanup-containers.sh status rg-containers simple-app

# View container logs
./scripts/cleanup-containers.sh logs rg-containers simple-app

# Run validation tests
./scripts/validate-deployment.sh rg-containers simple-app
```

## Custom Deployment Instructions

### Deploy Custom Application

```bash
# Deploy with custom parameters
./scripts/deploy-docker-container.sh \
  "my-web-app" \
  "myregistry.azurecr.io/webapp:v1.0" \
  "production" \
  "rg-prod-apps" \
  "West US 2"
```

Parameters:
1. `container_name` - Unique name for your container
2. `image_name` - Docker image (public or private registry)
3. `environment` - development/staging/production
4. `resource_group` - Azure resource group name
5. `location` - Azure region

### Using Configuration Files

Edit `configs/azure-deployment.json` for your specific needs:

```json
{
  "azure_deployment": {
    "subscription_id": "your-subscription-id",
    "default_location": "East US",
    "default_resource_group": "rg-containers"
  }
}
```

Then deploy:
```bash
./scripts/deploy-docker-container.sh my-app nginx:latest production
```

## Deployment Strategies

### Blue-Green Deployment

For zero-downtime deployments:

```bash
# Deploy new version (green)
./scripts/deploy-docker-container.sh \
  "app-green" \
  "myapp:v2.0" \
  "production" \
  "rg-prod"

# Validate green deployment
./scripts/validate-deployment.sh rg-prod app-green

# Switch traffic (manual process)
# Update DNS or load balancer to point to green

# Cleanup old version (blue)
./scripts/cleanup-containers.sh delete rg-prod app-blue
```

### Rolling Update

For gradual updates:

```bash
# Scale down current version
az container stop --resource-group rg-prod --name app-v1

# Deploy new version
./scripts/deploy-docker-container.sh \
  "app-v2" \
  "myapp:v2.0" \
  "production" \
  "rg-prod"

# Validate and cleanup
./scripts/validate-deployment.sh rg-prod app-v2
./scripts/cleanup-containers.sh delete rg-prod app-v1
```

## Configuration Management

### Environment Variables

Set environment-specific variables in your deployment:

```bash
# Edit the deployment script to add custom environment variables
# Or use Azure CLI directly:

az container create \
  --resource-group rg-containers \
  --name my-app \
  --image nginx:latest \
  --environment-variables \
    API_URL="https://api.mycompany.com" \
    DATABASE_URL="postgresql://..." \
    LOG_LEVEL="info"
```

### Secrets Management

For sensitive data, use Azure Key Vault:

```bash
# Create Key Vault
az keyvault create \
  --name "kv-myapp" \
  --resource-group rg-containers \
  --location "East US"

# Store secret
az keyvault secret set \
  --vault-name "kv-myapp" \
  --name "database-password" \
  --value "your-secret-password"

# Reference in container deployment (requires managed identity)
az container create \
  --resource-group rg-containers \
  --name my-app \
  --image myapp:latest \
  --assign-identity \
  --secure-environment-variables \
    DB_PASSWORD="@Microsoft.KeyVault(SecretUri=https://kv-myapp.vault.azure.net/secrets/database-password/)"
```

## Monitoring and Logging

### Basic Monitoring

```bash
# View real-time logs
az container logs --resource-group rg-containers --name my-app --follow

# Get container metrics
az monitor metrics list \
  --resource "/subscriptions/SUBSCRIPTION-ID/resourceGroups/rg-containers/providers/Microsoft.ContainerInstance/containerGroups/my-app" \
  --metric "CpuUsage,MemoryUsage"
```

### Log Analytics Integration

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --resource-group rg-containers \
  --workspace-name "law-containers"

# Deploy container with logging
az container create \
  --resource-group rg-containers \
  --name my-app \
  --image nginx:latest \
  --log-type loganalytics \
  --log-analytics-workspace-id "workspace-id" \
  --log-analytics-workspace-key "workspace-key"
```

## Troubleshooting Guide

### Common Issues

#### Container Won't Start

```bash
# Check container events
az container show \
  --resource-group rg-containers \
  --name my-app \
  --query instanceView.events

# Check container logs
az container logs \
  --resource-group rg-containers \
  --name my-app
```

#### Image Pull Failures

```bash
# For private registries, ensure authentication
az acr login --name myregistry

# Check image exists
az acr repository show --name myregistry --image myapp:latest

# Verify registry credentials in deployment
az container show \
  --resource-group rg-containers \
  --name my-app \
  --query containers[0].image
```

#### Network Connectivity Issues

```bash
# Check public IP assignment
az container show \
  --resource-group rg-containers \
  --name my-app \
  --query ipAddress

# Test connectivity
curl -f http://your-container-fqdn.eastus.azurecontainer.io

# Check DNS resolution
nslookup your-container-fqdn.eastus.azurecontainer.io
```

### Resource Limitations

```bash
# Check resource usage
az container show \
  --resource-group rg-containers \
  --name my-app \
  --query containers[0].resources

# Scale up resources
az container create \
  --resource-group rg-containers \
  --name my-app-scaled \
  --image nginx:latest \
  --cpu 2 \
  --memory 4
```

## Performance Optimization

### Resource Right-Sizing

1. **Monitor Usage**: Use the validation script to check resource utilization
2. **Adjust Resources**: Modify CPU and memory allocation based on actual usage
3. **Cost Optimization**: Use smaller instances for development environments

```bash
# Deploy with optimized resources
az container create \
  --resource-group rg-containers \
  --name my-app \
  --image nginx:latest \
  --cpu 0.5 \
  --memory 1 \
  --restart-policy OnFailure
```

### Startup Optimization

```bash
# Use multi-stage builds for smaller images
# Example Dockerfile optimization:
# FROM node:alpine AS builder
# COPY package*.json ./
# RUN npm ci --only=production
# 
# FROM node:alpine
# COPY --from=builder /app/node_modules ./node_modules
# COPY . .
# CMD ["node", "server.js"]
```

## Security Best Practices

### Image Security

1. **Use Official Images**: Start with official base images
2. **Scan Images**: Use Azure Security Center or third-party scanners
3. **Update Regularly**: Keep base images and dependencies updated

```bash
# Scan image for vulnerabilities (if Azure Security Center is enabled)
az security assessment list \
  --query "[?resourceDetails.resourceType=='Microsoft.ContainerInstance/containerGroups']"
```

### Network Security

```bash
# Deploy with network profile (advanced)
az network vnet create \
  --resource-group rg-containers \
  --name vnet-containers \
  --subnet-name subnet-containers

az container create \
  --resource-group rg-containers \
  --name my-app \
  --image nginx:latest \
  --vnet vnet-containers \
  --subnet subnet-containers
```

### Access Control

```bash
# Use managed identity for Azure resource access
az container create \
  --resource-group rg-containers \
  --name my-app \
  --image myapp:latest \
  --assign-identity \
  --role contributor \
  --scope /subscriptions/SUBSCRIPTION-ID/resourceGroups/rg-containers
```

## Automation and CI/CD Integration

### GitHub Actions Integration

The deployment scripts are designed to work with GitHub Actions. See the main Azure deployment workflow in `.github/workflows/claude-azure-deployment.yml`.

### Environment Variables for Automation

```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_RESOURCE_GROUP="rg-containers"
export AZURE_LOCATION="East US"
export CONTAINER_NAME="my-app"
export IMAGE_NAME="nginx:latest"
export ENVIRONMENT="production"
```

### Automated Validation

```bash
# Run automated validation
./scripts/validate-deployment.sh $AZURE_RESOURCE_GROUP $CONTAINER_NAME

# Check exit code for automation
if [ $? -eq 0 ]; then
  echo "Deployment validation passed"
else
  echo "Deployment validation failed"
  exit 1
fi
```

## Cost Management

### Resource Cleanup

```bash
# List all containers in resource group
./scripts/cleanup-containers.sh list rg-containers

# Delete specific container
./scripts/cleanup-containers.sh delete rg-containers my-app

# Delete all containers (use with caution)
./scripts/cleanup-containers.sh delete-all rg-containers
```

### Cost Monitoring

```bash
# Set up budget alerts
az consumption budget create \
  --budget-name "container-budget" \
  --amount 100 \
  --category cost \
  --time-grain monthly \
  --time-period start-date=2024-01-01 \
  --resource-group rg-containers
```

## Advanced Scenarios

### Multi-Container Deployments

```bash
# Deploy multiple containers in one group
az container create \
  --resource-group rg-containers \
  --name my-app-group \
  --yaml-file multi-container.yaml
```

### Persistent Storage

```bash
# Create Azure File Share
az storage account create \
  --resource-group rg-containers \
  --name storageaccount \
  --sku Standard_LRS

az storage share create \
  --name app-data \
  --account-name storageaccount

# Mount in container
az container create \
  --resource-group rg-containers \
  --name my-app \
  --image nginx:latest \
  --azure-file-volume-account-name storageaccount \
  --azure-file-volume-account-key "storage-key" \
  --azure-file-volume-share-name app-data \
  --azure-file-volume-mount-path /data
```

## Support and Resources

### Useful Commands Reference

```bash
# Quick status check
az container list --resource-group rg-containers --output table

# Restart container
az container restart --resource-group rg-containers --name my-app

# Get container IP
az container show --resource-group rg-containers --name my-app --query ipAddress.ip --output tsv

# Get container FQDN
az container show --resource-group rg-containers --name my-app --query ipAddress.fqdn --output tsv
```

### Additional Resources

- [Azure Container Instances Documentation](https://docs.microsoft.com/azure/container-instances/)
- [Azure CLI Reference](https://docs.microsoft.com/cli/azure/container)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

This guide provides comprehensive instructions for Claude agents to successfully deploy and manage Docker containers on Azure. Follow the step-by-step procedures and adapt them to your specific requirements.