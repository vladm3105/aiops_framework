# Getting Started with Framework Templates

## AI Agent Development Framework v3.7

This guide helps you quickly implement the AI Agent Development Framework v3.7 using the provided templates.

## 🚀 Quick Start (5 minutes)

### 1. Initialize a New Project

```bash
# Clone or copy the framework templates
git clone <framework-repo> my-aiops-project
cd my-aiops-project

# Run the initialization script
chmod +x templates/init/setup-script.sh
./templates/init/setup-script.sh my-project gcp

# This creates:
# - Complete project structure
# - Git repository with .gitignore
# - Environment configuration files
# - AI context system
# - CLAUDE.md for Claude Code integration
```

### 2. Set Up Your Environment

```bash
# Copy and configure environment variables
cp .env.template .env
# Edit .env with your actual values (GCP project, database credentials, etc.)

# Install dependencies if you have Python/Node.js project
pip install -r requirements.txt  # Python
npm install                      # Node.js
```

### 3. Configure CI/CD Pipelines

```bash
# Copy GitHub Actions workflows
mkdir -p .github/workflows
cp templates/workflows/github-actions/*.yml .github/workflows/

# Configure GitHub repository variables:
# - GCP_PROJECT_ID
# - GCP_REGION  
# - WIF_PROVIDER (Workload Identity Federation)
# - WIF_SERVICE_ACCOUNT

# Commit and push to trigger first pipeline
git add .github/workflows/
git commit -m "Add AI-powered CI/CD workflows"
git push
```

## 📚 Template Categories

### 🏗️ Project Initialization Templates (`templates/init/`)

**`project-structure.template`**

- Complete directory structure for AI-first projects
- Includes docs/, src/, infrastructure/, scripts/, .ai_context/
- Framework v3.7 compliant organization

**`setup-script.sh`**

- Automated project initialization
- Creates Git repository with comprehensive .gitignore
- Sets up environment configuration
- Initializes AI context system

**Usage:**

```bash
./templates/init/setup-script.sh [PROJECT_NAME] [CLOUD_PROVIDER]
# Example: ./templates/init/setup-script.sh my-app gcp
```

### ⚙️ CI/CD Workflow Templates (`templates/workflows/`)

#### GitHub Actions (`templates/workflows/github-actions/`)

**`ai-code-review.yml`**

- AI-powered code quality analysis
- Security vulnerability scanning
- Framework v3.7 compliance checking
- Automatic PR comments with insights

**`ai-testing.yml`**

- Intelligent test strategy generation
- AI-generated test cases
- Unit, integration, and performance testing
- Comprehensive test result analysis

**`ai-build-deploy.yml`**

- AI-optimized Docker builds
- Intelligent deployment strategy selection
- Blue-green, canary, and rolling deployments
- Automated monitoring and rollback

**Configuration Requirements:**

```yaml
# Repository Variables
GCP_PROJECT_ID: your-gcp-project
GCP_REGION: us-central1
ARTIFACT_REGISTRY: gcr.io/your-project

# Repository Secrets  
WIF_PROVIDER: projects/123/locations/global/workloadIdentityPools/pool/providers/provider
WIF_SERVICE_ACCOUNT: service-account@project.iam.gserviceaccount.com
```

#### GitLab CI (`templates/workflows/gitlab-ci/`)

- GitLab-specific CI/CD configurations
- AI-powered pipeline optimization
- Security and compliance integration

#### Azure DevOps (`templates/workflows/azure-devops/`)

- Azure DevOps pipeline templates
- AI agent integration
- Multi-stage deployment automation

### 🏭 Infrastructure Templates (`templates/infrastructure/`)

#### Terraform Modules (`templates/infrastructure/terraform/`)

**GCP Infrastructure (`gcp/main.tf`)**

- Complete GCP infrastructure setup
- GKE cluster with Workload Identity
- Cloud SQL with private networking
- Redis cache, Secret Manager
- Comprehensive monitoring and alerting
- Security-by-design configuration

**Variables Configuration (`gcp/variables.tf`)**

- 50+ configurable parameters
- Environment-specific settings
- Security and compliance options
- Cost optimization features

**Usage:**

```bash
# Copy Terraform templates
cp -r templates/infrastructure/terraform/gcp/* infrastructure/terraform/

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Deploy infrastructure
terraform init
terraform plan
terraform apply
```

#### Kubernetes Manifests (`templates/infrastructure/kubernetes/`)

- Base deployments and services
- Environment-specific overlays
- Security policies and network policies
- Monitoring and logging configurations

#### Docker Templates (`templates/infrastructure/docker/`)

- Multi-stage Dockerfile templates
- Production-optimized configurations
- Security hardening
- AI-optimized for cold starts

### 🤖 AI Agent Scripts (`templates/ai-agents/`)

**`deployment-strategy-agent.py`**

- Analyzes code changes to determine optimal deployment strategy
- Considers historical performance and risk factors
- Supports blue-green, canary, and rolling deployments
- Framework v3.7 compliant decision logging

**`code-quality-agent.py`**

- Comprehensive code quality analysis
- Security vulnerability detection
- Performance anti-pattern identification
- Framework compliance checking
- AI-powered insights and recommendations

**Usage:**

```bash
# Install dependencies
pip install -r templates/ai-agents/requirements.txt

# Analyze deployment strategy
python templates/ai-agents/deployment-strategy-agent.py \
  --analyze-changes "src/main.py,Dockerfile" \
  --environment prod \
  --output-decision deployment-decision.json

# Run code quality analysis
python templates/ai-agents/code-quality-agent.py \
  --changed-files "src/" \
  --output ai-analysis-results.json
```

### 📝 Development Templates (`templates/development/`)

**`ears-template.md`**

- EARS (Entity-Action-Response-Standard) requirements template
- Framework v3.7 compliant format
- Traceability to BDD scenarios and ADRs
- AI-assisted validation guidelines

**`bdd-scenario-template.md`**

- Behavior-Driven Development scenario templates
- Gherkin syntax with framework integration
- Test implementation guidance
- AI-powered scenario generation

**`adr-template.md`**

- Architecture Decision Record template
- Comprehensive decision analysis framework
- Options evaluation matrix
- Framework v3.7 alignment assessment

### 🔧 Configuration Templates (`templates/configurations/`)

#### GitHub Integration (`templates/configurations/github/`)

- GitHub Copilot instructions
- Environment configurations
- Security and compliance settings

#### GCP Integration (`templates/configurations/gcp/`)

- Workload Identity Federation setup
- Service account configurations
- IAM policies and permissions

#### Monitoring Templates (`templates/configurations/monitoring/`)

- Grafana dashboard configurations
- Prometheus alerting rules
- Custom metrics and SLOs

### 🛠️ IDE Integration Templates (`templates/integrations/`)

#### VS Code (`templates/integrations/vscode/`)

- Workspace settings for framework development
- Extension recommendations
- Debug configurations
- AI assistant integrations

#### Claude Code (`templates/integrations/claude/`)

- Project context templates
- AI assistant configuration
- Framework-specific prompts

## 📋 Implementation Workflow

### Phase 1: Project Setup (Day 1)

1. **Initialize Project Structure**

   ```bash
   ./templates/init/setup-script.sh my-project gcp
   ```

2. **Configure Environment**

   ```bash
   cp .env.template .env
   # Edit .env with your settings
   ```

3. **Set Up Version Control**

   ```bash
   git remote add origin <your-repo>
   git push -u origin main
   ```

### Phase 2: Development Setup (Day 1-2)

1. **Copy Development Templates**

   ```bash
   cp templates/development/*.md docs/templates/
   ```

2. **Set Up CI/CD**

   ```bash
   cp templates/workflows/github-actions/*.yml .github/workflows/
   ```

3. **Configure AI Agents**

   ```bash
   cp templates/ai-agents/*.py scripts/ai-agents/
   pip install -r templates/ai-agents/requirements.txt
   ```

### Phase 3: Infrastructure Deployment (Day 2-3)

1. **Deploy Infrastructure**

   ```bash
   cp -r templates/infrastructure/terraform/gcp/* infrastructure/terraform/
   terraform init && terraform apply
   ```

2. **Set Up Kubernetes**

   ```bash
   cp -r templates/infrastructure/kubernetes/* k8s/
   kubectl apply -f k8s/base/
   ```

### Phase 4: Operations Setup (Day 3-5)

1. **Configure Monitoring**

   ```bash
   cp -r templates/configurations/monitoring/* monitoring/
   ```

2. **Set Up IDE Integration**

   ```bash
   cp templates/integrations/vscode/settings.json .vscode/
   ```

3. **Test Framework Integration**

   ```bash
   python scripts/ai-agents/code-quality-agent.py --analyze-all
   ```

## 🔍 Template Customization

### Variable Substitution

Most templates support variable substitution using `{{ VARIABLE_NAME }}` syntax:

```yaml
# Example: ai-code-review.yml
name: AI Code Quality Review - {{ PROJECT_NAME }}
env:
  GCP_PROJECT_ID: {{ GCP_PROJECT_ID }}
  PYTHON_VERSION: {{ PYTHON_VERSION | default: 3.11 }}
```

### Configuration Files

Templates include configuration files for customization:

```yaml
# ai-agent-config.yml
quality_thresholds:
  complexity_threshold: 10
  line_length_threshold: 100
  security_threshold: high

deployment_strategies:
  dev: rolling
  staging: canary
  prod: blue-green
```

### Environment-Specific Overrides

Use environment-specific configuration:

```bash
# Development
cp templates/config/dev.yml config/
# Production  
cp templates/config/prod.yml config/
```

## 🚨 Common Issues and Solutions

### Issue: Missing Dependencies

**Problem:** AI agents fail with import errors

**Solution:**

```bash
pip install -r templates/ai-agents/requirements.txt
# Or install specific packages:
pip install openai anthropic google-cloud-aiplatform
```

### Issue: Terraform Authentication

**Problem:** GCP authentication fails

**Solution:**

```bash
# Use service account key
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json

# Or use gcloud auth
gcloud auth application-default login
```

### Issue: GitHub Actions Permissions

**Problem:** Workflow fails with permission errors

**Solution:** Configure repository secrets and variables in GitHub settings:

- Add WIF_PROVIDER and WIF_SERVICE_ACCOUNT secrets
- Add GCP_PROJECT_ID and GCP_REGION variables

### Issue: Template Variable Substitution

**Problem:** Variables not replaced in templates

**Solution:** Use a template processor or manual replacement:

```bash
# Manual replacement
sed -i 's/{{ PROJECT_NAME }}/my-project/g' file.yml

# Or use envsubst
envsubst < template.yml > actual.yml
```

## 📞 Support and Next Steps

### Getting Help

1. **Check Template Documentation**: Each template includes inline comments and usage instructions
2. **Review Framework Documentation**: Comprehensive guides in the framework docs
3. **Use AI Agents**: Let the AI agents analyze your setup and provide recommendations

### Next Steps

1. **Customize Templates**: Adapt templates to your specific requirements
2. **Integrate with Existing Systems**: Modify templates for your current infrastructure
3. **Contribute Back**: Share improvements with the framework community
4. **Monitor and Optimize**: Use AI agents for continuous improvement

### Best Practices

- Always test templates in development environments first
- Keep template customizations in version control
- Document any significant modifications
- Use framework validation to ensure compliance
- Regularly update templates with new framework versions

---

*This guide covers the essential templates for Framework v3.7 implementation. For advanced usage and customization, refer to the specific template documentation and framework guides.*
