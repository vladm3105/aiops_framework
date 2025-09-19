# Azure Container Deployment Framework

**AI-Powered Docker Container Deployment to Azure Container Instances**

This framework provides Claude agents with comprehensive tools and instructions for deploying Docker containers to Azure Container Instances (ACI) with minimal human intervention.

## 🚀 Quick Start

### Option 1: Use the Azure Agent (Recommended)

```bash
# 1. Authenticate with Azure
az login

# 2. Deploy sample application with AI-powered agent
cd .ai_devops/azure
./scripts/azure-agent.sh deploy-sample

# 3. Monitor with intelligent analysis
./scripts/azure-agent.sh monitor rg-containers simple-web-app
```

### Option 2: Direct Script Usage

```bash
# 1. Authenticate with Azure
az login

# 2. Deploy a simple nginx container
./scripts/deploy-docker-container.sh

# 3. Validate the deployment
./scripts/validate-deployment.sh rg-containers simple-app
```

Your container will be available at: `http://simple-app-development-<unique-id>.eastus.azurecontainer.io`

### Deploy the Sample Application

```bash
# Build and deploy the sample web application
cd samples/simple-web-app
./deploy.sh
```

## 📁 Framework Structure

```
.ai_devops/azure/
├── configs/                    # Configuration templates
│   ├── azure-deployment.json  # Main Azure deployment config
│   ├── container-defaults.json # Container defaults and settings
│   └── claude-prompts.json    # Claude AI prompt templates
├── docs/                      # Documentation
│   └── claude-deployment-guide.md # Step-by-step guide for Claude agents
├── samples/                   # Sample applications
│   └── simple-web-app/       # Ready-to-deploy web application
├── scripts/                   # Deployment and management scripts
│   ├── deploy-docker-container.sh    # Main deployment script
│   ├── validate-deployment.sh        # Deployment validation
│   ├── cleanup-containers.sh         # Container management
│   ├── test-deployment.sh           # Comprehensive testing
│   └── claude-integration-test.sh   # Claude integration tests
└── templates/                 # Infrastructure as Code
    ├── arm/                   # ARM templates
    ├── bicep/                 # Bicep templates
    └── deployment-parameters.json # Parameter configurations
```

## 🎯 Core Features

### For Claude Agents

- **📋 Step-by-Step Instructions**: Comprehensive deployment guide specifically written for AI agents
- **🤖 AI-Optimized Prompts**: Pre-configured prompts for deployment analysis, troubleshooting, and optimization
- **⚙️ Configuration Templates**: Environment-specific configurations for development, staging, and production
- **🔍 Automated Validation**: Built-in health checks and deployment validation scripts
- **📊 Testing Framework**: Comprehensive testing suite for deployment verification

### For Human Operators

- **🚀 One-Command Deployment**: Simple scripts for quick container deployment
- **📈 Environment Management**: Support for multiple environments with appropriate resource sizing
- **🔧 Infrastructure as Code**: ARM and Bicep templates for reproducible deployments
- **📋 Monitoring Integration**: Built-in Log Analytics and Application Insights support
- **🛡️ Security Best Practices**: Security-hardened configurations and vulnerability scanning

## 🛠️ Prerequisites

### Required Tools

- **Azure CLI** (`az`) - [Installation Guide](https://docs.microsoft.com/cli/azure/install-azure-cli)
- **Docker** (optional) - For building custom images
- **jq** - For JSON processing
- **curl** - For health checks and API testing

### Azure Setup

- Azure subscription with contributor permissions
- Resource group (will be created if it doesn't exist)
- Optional: Azure Container Registry for private images

### Authentication

```bash
# Login to Azure
az login

# Set default subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

## 📖 Usage Guide

### Basic Deployment

Deploy a container with default settings:

```bash
./scripts/deploy-docker-container.sh
```

### Custom Deployment

Deploy with specific parameters:

```bash
./scripts/deploy-docker-container.sh \
  "my-app" \                    # Container name
  "nginx:latest" \              # Docker image
  "production" \                # Environment
  "rg-prod" \                   # Resource group
  "West US 2"                   # Azure region
```

### Environment-Specific Deployments

The framework automatically adjusts resources based on environment:

| Environment | CPU | Memory | Registry SKU | Features |
|-------------|-----|---------|-------------|----------|
| Development | 0.5 | 1.0 GB | Basic | Debug enabled, reduced resources |
| Staging | 1.0 | 2.0 GB | Standard | Production-like config, monitoring |
| Production | 2.0 | 4.0 GB | Premium | High availability, security scanning |

### Using Infrastructure as Code

Deploy using Bicep templates:

```bash
# Deploy complete infrastructure
az deployment group create \
  --resource-group myRG \
  --template-file templates/bicep/main.bicep \
  --parameters baseName=myapp environment=production
```

Deploy using ARM templates:

```bash
# Deploy container instance only
az deployment group create \
  --resource-group myRG \
  --template-file templates/arm/container-instance.json \
  --parameters containerName=myapp imageName=nginx:latest
```

## 🔍 Validation and Testing

### Quick Validation

```bash
# Validate a specific deployment
./scripts/validate-deployment.sh rg-containers my-app
```

### Comprehensive Testing

```bash
# Run all tests
./scripts/test-deployment.sh all rg-containers my-app

# Test specific components
./scripts/test-deployment.sh azure      # Test Azure connectivity
./scripts/test-deployment.sh scripts   # Test deployment scripts
./scripts/test-deployment.sh templates # Test ARM/Bicep templates
./scripts/test-deployment.sh container # Test container deployment
```

### Claude Integration Testing

```bash
# Test Claude AI integration (simulation mode)
./scripts/claude-integration-test.sh simulation

# Test with real Claude CLI (requires authentication)
./scripts/claude-integration-test.sh real
```

## 🤖 Azure Cloud Agent (NEW)

### Autonomous AI-Powered Operations

The Azure Agent provides intelligent, autonomous cloud operations:

```bash
# Deploy with AI decision making
./scripts/azure-agent.sh deploy my-app nginx:latest production

# Intelligent troubleshooting
./scripts/azure-agent.sh troubleshoot rg-containers my-app

# AI-powered log analysis
./scripts/azure-agent.sh analyze-logs rg-containers my-app

# Comprehensive monitoring
./scripts/azure-agent.sh monitor rg-containers my-app
```

### Agent Features
- **🧠 AI Decision Making**: Uses Claude AI for deployment strategies and troubleshooting
- **🔄 Autonomous Operations**: Self-healing and adaptive deployment management
- **📊 Intelligent Analysis**: Automated log analysis and performance optimization
- **🚨 Proactive Monitoring**: Predictive issue detection and resolution
- **📋 Comprehensive Reporting**: Detailed deployment and operational reports

See [Azure Agent Quick Start](AZURE_AGENT_QUICKSTART.md) for detailed usage.

## 🤖 Claude Agent Integration

### AI-Powered Deployment Analysis

The framework includes pre-configured prompts for Claude to analyze deployments:

```bash
# Configuration analysis
claude-prompt: "container_analysis"
# Input: Container configuration JSON
# Output: Optimization recommendations

# Deployment strategy
claude-prompt: "deployment_strategy"
# Input: Application requirements
# Output: Step-by-step deployment plan

# Troubleshooting
claude-prompt: "troubleshooting"
# Input: Error logs and symptoms
# Output: Diagnostic steps and solutions
```

### Automated Decision Making

Claude agents can use the framework to:

1. **Analyze** application requirements and recommend optimal configurations
2. **Deploy** containers using validated scripts and templates
3. **Monitor** deployment health and performance
4. **Optimize** resource allocation based on usage patterns
5. **Troubleshoot** issues using integrated diagnostic tools

## 🔧 Configuration

### Main Configuration (`configs/azure-deployment.json`)

```json
{
  "azure_deployment": {
    "subscription_id": "your-subscription-id",
    "default_location": "East US",
    "default_resource_group": "rg-containers",
    "environments": {
      "production": {
        "resource_group_suffix": "-prod",
        "container_resources": {
          "cpu": 2.0,
          "memory": 4.0
        },
        "high_availability": true
      }
    }
  }
}
```

### Container Defaults (`configs/container-defaults.json`)

```json
{
  "container_defaults": {
    "resource_limits": {
      "cpu_max": 4.0,
      "memory_max_gb": 16.0
    },
    "health_check": {
      "enabled": true,
      "path": "/health",
      "interval_seconds": 30
    },
    "security": {
      "run_as_non_root": true,
      "read_only_root_filesystem": false
    }
  }
}
```

## 🎨 Sample Applications

### Simple Web App

Ready-to-deploy nginx-based web application:

```bash
cd samples/simple-web-app
./deploy.sh

# Features:
# - Custom nginx configuration
# - Health check endpoints (/health, /ready)
# - Responsive web interface
# - Error pages (404, 5xx)
# - Security headers
# - Container health monitoring
```

### Custom Application

Create your own application:

1. Copy the sample application structure
2. Modify the Dockerfile for your application
3. Update nginx.conf (if using nginx)
4. Customize health-check.sh for your app
5. Deploy using the same scripts

## 📊 Monitoring and Logging

### Built-in Health Checks

All deployments include:

- **Liveness Probe**: HTTP GET to `/health` every 30 seconds
- **Readiness Probe**: HTTP GET to `/ready` every 10 seconds
- **Container Monitoring**: CPU, memory, and restart count tracking

### Log Analytics Integration

Enable comprehensive logging:

```bash
# Deploy with Log Analytics
az deployment group create \
  --template-file templates/bicep/main.bicep \
  --parameters enableLogAnalytics=true
```

### Application Insights

For detailed application monitoring:

```bash
# Enable Application Insights in your container
az container create \
  --environment-variables \
    APPINSIGHTS_INSTRUMENTATIONKEY="your-key"
```

## 🛡️ Security Features

### Container Security

- **Non-root execution**: Containers run as non-privileged users
- **Security headers**: HTTP security headers enabled by default
- **Image scanning**: Vulnerability scanning for Premium registry SKU
- **Managed identity**: Azure AD integration for secure resource access

### Network Security

- **Public/Private networking**: Support for VNet integration
- **Firewall rules**: Configurable network access controls
- **TLS termination**: HTTPS support with Let's Encrypt integration

### Secrets Management

- **Azure Key Vault**: Integration for sensitive configuration
- **Environment variables**: Secure injection of runtime configuration
- **No secrets in images**: Best practices for secret handling

## 🔄 Deployment Strategies

### Blue-Green Deployment

Zero-downtime deployment strategy:

```bash
# Deploy green version
./scripts/deploy-docker-container.sh app-green myapp:v2 production

# Validate green version
./scripts/validate-deployment.sh rg-prod app-green

# Switch traffic (manual step)
# Update DNS or load balancer configuration

# Clean up blue version
./scripts/cleanup-containers.sh delete rg-prod app-blue
```

### Rolling Updates

Gradual deployment updates:

```bash
# Scale down current version
az container stop --resource-group rg-prod --name app-v1

# Deploy new version
./scripts/deploy-docker-container.sh app-v2 myapp:v2 production

# Validate and clean up
./scripts/validate-deployment.sh rg-prod app-v2
./scripts/cleanup-containers.sh delete rg-prod app-v1
```

### Canary Deployment

Risk-mitigated deployment approach:

```bash
# Deploy canary with reduced traffic
./scripts/deploy-docker-container.sh app-canary myapp:v2 production

# Monitor canary performance
# Gradually increase traffic
# Full rollout after validation
```

## 🚨 Troubleshooting

### Common Issues

#### Container Won't Start

```bash
# Check container events and logs
az container show --resource-group rg --name app --query instanceView.events
az container logs --resource-group rg --name app

# Common causes:
# - Image pull failures
# - Insufficient resources
# - Port conflicts
# - Environment variable issues
```

#### Image Pull Failures

```bash
# For private registries, ensure authentication
az acr login --name myregistry

# Check image exists
az acr repository show --name myregistry --image myapp:latest

# Verify registry credentials
az acr credential show --name myregistry
```

#### Network Connectivity Issues

```bash
# Check public IP assignment
az container show --resource-group rg --name app --query ipAddress

# Test connectivity
curl -f http://your-container-fqdn.region.azurecontainer.io

# Check DNS resolution
nslookup your-container-fqdn.region.azurecontainer.io
```

#### Performance Issues

```bash
# Check resource usage
az container show --resource-group rg --name app --query containers[0].resources

# Monitor metrics
az monitor metrics list --resource containerResourceId --metric "CpuUsage,MemoryUsage"

# Scale resources
az container create --cpu 2 --memory 4 # Recreate with more resources
```

### Getting Help

1. **Run validation**: `./scripts/validate-deployment.sh`
2. **Check logs**: `az container logs --follow`
3. **Test connectivity**: `curl -f http://your-app/health`
4. **Review configuration**: Check JSON files for syntax errors
5. **Use Claude integration**: Run AI-powered troubleshooting prompts

## 📚 Advanced Topics

### Custom Base Images

```dockerfile
# Multi-stage build for optimized images
FROM node:alpine AS builder
COPY package*.json ./
RUN npm ci --only=production

FROM node:alpine
COPY --from=builder /app/node_modules ./node_modules
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Azure Container Registry Integration

```bash
# Create ACR
az acr create --name myregistry --resource-group rg --sku Premium

# Build and push
az acr build --registry myregistry --image myapp:latest .

# Deploy with ACR image
./scripts/deploy-docker-container.sh myapp myregistry.azurecr.io/myapp:latest production
```

### VNet Integration

```bash
# Deploy with network profile for VNet integration
az deployment group create \
  --template-file templates/bicep/main.bicep \
  --parameters networkProfileId="/subscriptions/.../networkProfiles/myProfile"
```

### High Availability

```bash
# Production deployment with HA features
az deployment group create \
  --template-file templates/bicep/main.bicep \
  --parameters \
    environment=production \
    enableManagedIdentity=true \
    enableVulnerabilityScanning=true \
    registrySku=Premium
```

## 🤝 Contributing

### Framework Enhancement

1. Fork the repository
2. Create feature branch
3. Add tests for new functionality
4. Update documentation
5. Submit pull request

### Adding New Templates

1. Create ARM/Bicep templates in `templates/`
2. Add parameter files
3. Update deployment scripts
4. Add validation tests
5. Document usage

### Claude Prompt Enhancement

1. Add new prompts to `configs/claude-prompts.json`
2. Test with Claude integration script
3. Document prompt usage
4. Add validation tests

## 📋 Roadmap

### Current Features (v1.0)

- ✅ Basic container deployment
- ✅ Health check integration
- ✅ Multi-environment support
- ✅ ARM/Bicep templates
- ✅ Claude AI integration
- ✅ Comprehensive testing

### Planned Features (v1.1)

- 🔄 GitOps integration
- 🔄 Advanced monitoring dashboards
- 🔄 Automated scaling policies
- 🔄 Multi-region deployment
- 🔄 Cost optimization automation

### Future Features (v2.0)

- 🔮 Kubernetes migration path
- 🔮 Service mesh integration
- 🔮 Advanced security scanning
- 🔮 ML-powered optimization
- 🔮 Cross-cloud deployment

## 📄 License

This Azure Container Deployment Framework is provided as part of the AI DevOps Framework v3.7. See the main framework documentation for license details.

## 🆘 Support

- **Documentation**: Check the [Claude Deployment Guide](docs/claude-deployment-guide.md)
- **Testing**: Run `./scripts/test-deployment.sh all` for comprehensive validation
- **Integration**: Use `./scripts/claude-integration-test.sh` for Claude-specific testing
- **Issues**: Report issues in the main framework repository

---

**Built for Claude Agents, by Claude Agents** 🤖 

*Enabling autonomous container deployment on Azure with AI-powered decision making and optimization.*