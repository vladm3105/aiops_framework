# Claude Code Deployment Setup Guide

This guide provides step-by-step instructions for setting up Claude Code deployment workflows for GCP and Azure.

## Prerequisites

### General Requirements
- ✅ Self-hosted GitHub runners
- ✅ Claude Code CLI installed on runners
- ✅ Git configured on runners
- ✅ Basic utilities: curl, jq, bc, grep, find

### Cloud Provider Requirements

#### For GCP Deployments
- ✅ Google Cloud SDK (`gcloud`) installed
- ✅ Terraform (optional, for IaC validation)
- ✅ Docker (for container deployments)

#### For Azure Deployments
- ✅ Azure CLI (`az`) installed
- ✅ Terraform (optional, for IaC validation)
- ✅ Docker (for container deployments)

## Step 1: Framework Installation

### 1.1 Copy Framework Files
```bash
# Copy the entire Claude framework to your repository
cp -r .ai_devops/claude/ /path/to/your/repo/.ai_devops/
```

### 1.2 Copy Workflow Files
```bash
# Copy deployment workflows
cp .github/workflows/claude-gcp-deployment.yml /path/to/your/repo/.github/workflows/
cp .github/workflows/claude-azure-deployment.yml /path/to/your/repo/.github/workflows/
cp .github/workflows/claude-unit-testing.yml /path/to/your/repo/.github/workflows/
```

### 1.3 Copy Azure Standalone Framework (New Feature)
```bash
# Copy the standalone Azure deployment framework
cp -r .ai_devops/azure/ /path/to/your/repo/.ai_devops/

# This includes:
# - Azure-specific deployment scripts
# - Simple Docker container deployment tools
# - Sample web application
# - ARM/Bicep templates
# - Claude integration prompts
# - Comprehensive testing suite
```

### 1.4 Set Executable Permissions
```bash
chmod +x .ai_devops/claude/scripts/*.sh
chmod +x .ai_devops/azure/scripts/*.sh
chmod +x .ai_devops/azure/samples/simple-web-app/*.sh
```

## Step 2: GitHub Secrets Configuration

### 2.1 Common Secrets (Required for All)
Navigate to your GitHub repository → Settings → Secrets and variables → Actions

```
ANTHROPIC_API_KEY
├── Description: Claude Code API access key
├── Value: Your Anthropic API key
└── Required for: All workflows
```

### 2.2 GCP-Specific Secrets

#### Service Account Setup
1. Create a GCP service account:
```bash
gcloud iam service-accounts create claude-deployment \
    --description="Service account for Claude deployment workflows" \
    --display-name="Claude Deployment"
```

2. Grant necessary permissions:
```bash
PROJECT_ID="your-project-id"
SERVICE_ACCOUNT="claude-deployment@${PROJECT_ID}.iam.gserviceaccount.com"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/editor"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:${SERVICE_ACCOUNT}" \
    --role="roles/iam.serviceAccountUser"
```

3. Create and download service account key:
```bash
gcloud iam service-accounts keys create claude-deployment-key.json \
    --iam-account="$SERVICE_ACCOUNT"

# Convert to base64 for GitHub secrets
base64 -i claude-deployment-key.json
```

#### GitHub Secrets for GCP
```
GCP_SERVICE_ACCOUNT_KEY
├── Description: Base64-encoded service account JSON
├── Value: Output from base64 command above
└── Required for: GCP deployment workflow

GCP_PROJECT_ID
├── Description: Your GCP project ID
├── Value: your-project-id
└── Required for: GCP deployment workflow
```

#### Optional GCP Variables
```
GCP_REGION
├── Description: Default GCP region
├── Value: us-central1 (or your preferred region)
└── Required for: GCP deployment workflow (optional)
```

### 2.3 Azure-Specific Secrets

#### Service Principal Setup
1. Create Azure service principal:
```bash
az ad sp create-for-rbac \
    --name "claude-deployment" \
    --role contributor \
    --scopes /subscriptions/YOUR-SUBSCRIPTION-ID \
    --sdk-auth
```

2. Note the output values for GitHub secrets

#### GitHub Secrets for Azure
```
AZURE_SUBSCRIPTION_ID
├── Description: Azure subscription ID
├── Value: Your subscription ID
└── Required for: Azure deployment workflow

AZURE_TENANT_ID
├── Description: Azure AD tenant ID
├── Value: Your tenant ID
└── Required for: Azure deployment workflow

AZURE_CLIENT_ID
├── Description: Service principal client ID
├── Value: Client ID from service principal creation
└── Required for: Azure deployment workflow

AZURE_CLIENT_SECRET
├── Description: Service principal client secret
├── Value: Client secret from service principal creation
└── Required for: Azure deployment workflow
```

#### Optional Azure Variables
```
AZURE_LOCATION
├── Description: Default Azure region
├── Value: East US (or your preferred region)
└── Required for: Azure deployment workflow (optional)

AZURE_RESOURCE_GROUP
├── Description: Default resource group name
├── Value: rg-myapp (or your preferred name)
└── Required for: Azure deployment workflow (optional)
```

## Step 3: Configuration Customization

### 3.1 Main Deployment Configuration
Edit `.ai_devops/claude/configs/deployment-config.json`:

```json
{
  "deployment_settings": {
    "default_cloud_provider": "gcp",  // or "azure"
    "default_environment": "staging",
    "risk_tolerance": "low",          // low/medium/high
    "downtime_tolerance": "zero"      // zero/minimal/scheduled
  },
  "environments": {
    "production": {
      "security_level": "critical",
      "approval_required": true,
      "change_management": true
    }
  }
}
```

### 3.2 Cloud-Specific Configuration

#### GCP Configuration
Edit `.ai_devops/claude/configs/gcp-deployment-config.json`:

```json
{
  "gcp_deployment": {
    "default_project": "your-project-id",
    "default_region": "us-central1",
    "default_zone": "us-central1-a"
  }
}
```

#### Azure Configuration
Edit `.ai_devops/claude/configs/azure-deployment-config.json`:

```json
{
  "azure_deployment": {
    "default_subscription_id": "your-subscription-id",
    "default_resource_group": "rg-your-app",
    "default_location": "East US"
  }
}
```

## Step 4: Self-Hosted Runner Setup

### 4.1 Runner Requirements
Ensure your self-hosted runners have:

```bash
# Check Claude CLI
claude --version

# Check cloud CLIs
gcloud version  # For GCP
az version      # For Azure

# Check required tools
terraform version  # Optional
docker version     # For container deployments
jq --version
```

### 4.2 Runner Permissions
Ensure runners can:
- Access GitHub repository
- Execute shell scripts
- Create temporary files
- Access network for API calls

### 4.3 Environment Variables
Set on runners or in workflow environment:
```bash
export ANTHROPIC_API_KEY="your-api-key"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/service-account.json"  # For GCP
```

## Step 5: Test the Setup

### 5.1 Test Claude CLI Connection
```bash
claude -p "Hello, this is a test" --max-turns 1
```

### 5.2 Test Cloud Provider Authentication

#### Test GCP
```bash
gcloud auth list
gcloud projects list
```

#### Test Azure
```bash
az account show
az group list
```

### 5.3 Run Test Deployment
1. Create a test branch
2. Push changes to trigger workflow
3. Monitor workflow execution in GitHub Actions
4. Check deployment results and logs

## Step 6: Production Deployment

### 6.1 Environment Protection Rules
1. Go to Settings → Environments
2. Create environment: `production`
3. Configure protection rules:
   - Required reviewers
   - Wait timer
   - Required status checks

### 6.2 Branch Protection
1. Go to Settings → Branches
2. Add rule for `main` branch:
   - Require status checks
   - Require branches to be up to date
   - Include Claude testing workflow

### 6.3 Monitoring Setup
- Configure cloud provider monitoring
- Set up alerting for deployment failures
- Monitor cost and resource usage

## Common Issues and Solutions

### Issue: "Claude CLI not found"
**Solution:**
```bash
# Install Claude CLI on runners
npm install -g @anthropic/claude-cli
# or
pip install claude-cli
```

### Issue: "Permission denied" for cloud resources
**Solution:**
- Verify service account/principal permissions
- Check subscription/project access
- Validate secret configuration

### Issue: "Deployment timeout"
**Solution:**
- Increase workflow timeout limits
- Check cloud provider quotas
- Verify network connectivity

### Issue: "Terraform validation failed"
**Solution:**
- Install Terraform on runners
- Verify Terraform syntax
- Check provider authentication

## Security Best Practices

### Secret Management
- ✅ Use GitHub secrets for all credentials
- ✅ Rotate service account keys regularly
- ✅ Use least privilege access
- ✅ Monitor secret usage

### Network Security
- ✅ Use private networks where possible
- ✅ Configure firewall rules appropriately
- ✅ Enable audit logging
- ✅ Monitor access patterns

### Deployment Security
- ✅ Require approvals for production
- ✅ Use signed commits
- ✅ Validate infrastructure changes
- ✅ Scan for vulnerabilities

## Support and Troubleshooting

### Debug Mode
Enable verbose logging:
```json
// In claude-settings.json
{
  "claude_cli": {
    "verbose": true
  }
}
```

### Log Analysis
Check workflow logs for:
- Claude API response codes
- Cloud provider authentication
- Resource creation/update status
- Health check results

### Getting Help
1. Check workflow run logs
2. Review Claude deployment reports
3. Verify configuration files
4. Test individual components

## Azure Standalone Framework (New Feature)

### Overview
The Azure standalone framework (`.ai_devops/azure/`) provides Claude agents with dedicated tools for simple Docker container deployments to Azure Container Instances, independent of the comprehensive GitHub workflows.

### Key Features
- **Standalone Deployment**: Deploy containers without GitHub Actions
- **Claude Agent Optimized**: Written specifically for AI agent interaction
- **Sample Application**: Ready-to-deploy web application with health checks
- **Infrastructure as Code**: ARM and Bicep templates included
- **Comprehensive Testing**: Built-in validation and testing scripts

### Quick Start with Azure Framework
```bash
# 1. Navigate to Azure framework
cd .ai_devops/azure

# 2. Deploy sample application
cd samples/simple-web-app
./deploy.sh

# 3. Deploy custom container
cd ../../
./scripts/deploy-docker-container.sh my-app nginx:latest production rg-prod "West US"

# 4. Validate deployment
./scripts/validate-deployment.sh rg-prod my-app

# 5. Run comprehensive tests
./scripts/test-deployment.sh all rg-prod my-app

# 6. Test Claude integration
./scripts/claude-integration-test.sh simulation
```

### Azure Framework Configuration
Edit `.ai_devops/azure/configs/azure-deployment.json`:
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

### Claude Integration
The Azure framework includes specialized prompts for Claude agents:

```bash
# Available prompt categories in configs/claude-prompts.json:
# - container_analysis: Optimization recommendations
# - deployment_strategy: Step-by-step deployment plans
# - troubleshooting: Diagnostic guidance
# - security_review: Security assessments
# - cost_optimization: Cost reduction strategies
# - monitoring_setup: Observability configuration
```

### Infrastructure as Code
Deploy using templates:
```bash
# Bicep deployment
az deployment group create \
  --resource-group myRG \
  --template-file templates/bicep/main.bicep \
  --parameters baseName=myapp environment=production

# ARM deployment
az deployment group create \
  --resource-group myRG \
  --template-file templates/arm/container-instance.json \
  --parameters containerName=myapp
```

### Testing and Validation
```bash
# Run all tests
./scripts/test-deployment.sh all

# Test specific components
./scripts/test-deployment.sh azure      # Azure connectivity
./scripts/test-deployment.sh scripts   # Deployment scripts
./scripts/test-deployment.sh templates # ARM/Bicep templates
./scripts/test-deployment.sh container # Container deployment
./scripts/test-deployment.sh performance # Performance tests

# Claude integration tests
./scripts/claude-integration-test.sh simulation # Simulation mode
./scripts/claude-integration-test.sh real      # With actual Claude CLI
```

### Sample Application Features
The included sample web application (`samples/simple-web-app/`) provides:
- Nginx-based web server with security headers
- Health check endpoints (`/health`, `/ready`)
- Custom error pages (404, 5xx)
- Docker health checks and monitoring
- Azure Container Registry integration
- One-command deployment script

---

For additional support, refer to the main [README.md](README.md) and official documentation:
- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [GCP Documentation](https://cloud.google.com/docs)
- [Azure Documentation](https://docs.microsoft.com/azure)
- [Azure Framework README](.ai_devops/azure/README.md)
- [Claude Deployment Guide](.ai_devops/azure/docs/claude-deployment-guide.md)