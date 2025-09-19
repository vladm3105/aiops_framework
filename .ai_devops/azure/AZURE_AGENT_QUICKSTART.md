# Azure Agent Quick Start Guide

**🤖 Autonomous Azure Cloud Operations Agent**

## One-Command Setup

```bash
cd .ai_devops/azure
./scripts/azure-agent.sh help
```

## Core Operations

### 🚀 Deployment Operations

```bash
# Deploy sample web application (recommended for first time)
./scripts/azure-agent.sh deploy-sample

# Deploy custom container
./scripts/azure-agent.sh deploy my-app nginx:latest development

# Deploy to production
./scripts/azure-agent.sh deploy prod-app myapp:v1.0 production rg-prod "West US"
```

### 🔍 Troubleshooting Operations

```bash
# Troubleshoot deployment issues
./scripts/azure-agent.sh troubleshoot rg-containers my-app

# Analyze container logs
./scripts/azure-agent.sh analyze-logs rg-containers my-app

# Monitor container status
./scripts/azure-agent.sh monitor rg-containers my-app
```

### 🧪 Testing and Validation

```bash
# Run comprehensive tests
./scripts/azure-agent.sh test rg-containers my-app

# Validate specific deployment
./scripts/azure-agent.sh validate rg-containers my-app

# Test framework components
./scripts/azure-agent.sh test
```

### 🧹 Management Operations

```bash
# List containers in resource group
./scripts/azure-agent.sh cleanup rg-containers

# Delete specific container
./scripts/azure-agent.sh cleanup rg-containers my-app
```

## Agent Features

### 🧠 AI-Powered Decision Making
- Uses Claude AI for deployment strategy recommendations
- Intelligent troubleshooting with root cause analysis
- Automated log analysis with pattern recognition
- Cost and performance optimization suggestions

### 🔄 Autonomous Operations
- **Self-healing**: Detects and resolves common issues
- **Auto-scaling**: Recommends resource adjustments
- **Predictive**: Identifies potential problems before they occur
- **Adaptive**: Learns from deployment patterns and outcomes

### 📊 Comprehensive Reporting
- Deployment success/failure reports
- Performance and resource utilization metrics
- Security assessment and compliance status
- Cost analysis and optimization recommendations

## Quick Examples

### Example 1: Deploy and Monitor Sample App
```bash
# Deploy the sample application
./scripts/azure-agent.sh deploy-sample

# Monitor the deployment
./scripts/azure-agent.sh monitor rg-containers simple-web-app

# Access the application
# URL will be displayed in deployment output: http://app-name.eastus.azurecontainer.io
```

### Example 2: Troubleshoot Failed Deployment
```bash
# If deployment fails, run troubleshooting
./scripts/azure-agent.sh troubleshoot rg-containers my-app

# Analyze logs for specific issues
./scripts/azure-agent.sh analyze-logs rg-containers my-app

# The agent will provide AI-powered diagnosis and solutions
```

### Example 3: Production Deployment Workflow
```bash
# 1. Deploy to staging first
./scripts/azure-agent.sh deploy staging-app myapp:v2.0 staging rg-staging

# 2. Run comprehensive tests
./scripts/azure-agent.sh test rg-staging staging-app

# 3. Monitor performance
./scripts/azure-agent.sh monitor rg-staging staging-app

# 4. Deploy to production if staging tests pass
./scripts/azure-agent.sh deploy prod-app myapp:v2.0 production rg-prod

# 5. Validate production deployment
./scripts/azure-agent.sh validate rg-prod prod-app
```

## Agent Prerequisites

### Required Tools
- ✅ Azure CLI (`az`) installed and authenticated
- ✅ Basic tools: `jq`, `curl` (usually pre-installed)
- ✅ Access to `.ai_devops/azure` framework

### Optional Enhancements
- 🤖 Claude CLI for enhanced AI decision making
- 🐳 Docker for custom image building
- 📊 Azure Log Analytics for advanced monitoring

### Authentication Setup
```bash
# Login to Azure
az login

# Set default subscription (if you have multiple)
az account set --subscription "your-subscription-id"

# Verify authentication
az account show
```

## Agent Output

### Successful Deployment
```
🤖 Azure Cloud Agent
===================
🔵 [INFO] Checking Azure Cloud Agent prerequisites...
✅ [SUCCESS] All prerequisites met. Agent ready for operations.
🔧 [ACTION] Executing deployment using framework scripts...
✅ [SUCCESS] Container deployment completed successfully
✅ [SUCCESS] Deployment validation passed

🌐 Application Access:
   HTTP URL: http://my-app-dev-abc123.eastus.azurecontainer.io
   Health Check: http://my-app-dev-abc123.eastus.azurecontainer.io/health
   Public IP: 20.1.2.3
```

### Troubleshooting Report
```
🤖 Azure Cloud Agent - Troubleshooting
=====================================
🔵 [INFO] Container state: Terminated
🔧 [ACTION] Consulting Claude AI for decision...
✅ [SUCCESS] AI decision received

# Troubleshooting Report
**Container**: my-app
**Resource Group**: rg-containers

## AI Analysis
The container terminated due to image pull failure. The specified image 
'myapp:latest' was not found in the registry. Recommend:
1. Verify image name and tag
2. Check registry authentication
3. Ensure image exists in the specified registry

## Recommended Actions
1. Check container logs for specific error messages
2. Verify image availability and registry authentication
3. Review resource allocation and limits
```

## Advanced Usage

### Custom AI Prompts
The agent uses prompts from `configs/claude-prompts.json`. You can customize these for specific use cases:

```json
{
  "azure_deployment_prompts": {
    "custom_analysis": {
      "system_prompt": "You are a specialized Azure expert for my specific workload...",
      "user_prompt_template": "Analyze this deployment for {specific_requirements}..."
    }
  }
}
```

### Integration with CI/CD
```yaml
# GitHub Actions example
- name: Deploy with Azure Agent
  run: |
    cd .ai_devops/azure
    ./scripts/azure-agent.sh deploy ${{ github.event.repository.name }} ${{ env.IMAGE_NAME }} production
```

### Monitoring Integration
```bash
# Set up monitoring alerts
az monitor action-group create --name "azure-agent-alerts" --resource-group monitoring

# Configure log analytics queries
az monitor log-analytics query --workspace $WORKSPACE_ID --analytics-query "ContainerLog | where LogEntry contains 'error'"
```

## Troubleshooting the Agent

### Common Issues

**Agent Prerequisites Not Met**
```bash
# Check Azure authentication
az account show

# Install missing tools
sudo apt-get install jq curl  # Ubuntu/Debian
brew install jq curl          # macOS
```

**Framework Not Found**
```bash
# Verify framework location
ls -la .ai_devops/azure/

# Ensure you're in the correct directory
cd /path/to/your/project/.ai_devops/azure
```

**Permission Issues**
```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x samples/simple-web-app/*.sh
```

## Getting Help

### Built-in Help
```bash
./scripts/azure-agent.sh help
```

### Framework Documentation
- [Azure Framework README](README.md)
- [Claude Deployment Guide](docs/claude-deployment-guide.md)
- [Azure Agent Specification](../../agents/azure-cloud-agent.md)

### Testing the Agent
```bash
# Test agent functionality
./scripts/azure-agent.sh test

# Test Claude integration
./scripts/claude-integration-test.sh simulation
```

---

**🚀 The Azure Agent is ready for autonomous cloud operations!**

*Deploy, troubleshoot, and monitor Azure containers with AI-powered intelligence.*