#!/bin/bash
# Project Initialization Script
# AI Agent Development Framework v3.7
#
# This script initializes a new project with the AI Agent Development Framework v3.7
# Usage: ./setup-script.sh [PROJECT_NAME] [CLOUD_PROVIDER]

set -e  # Exit on any error

# Default values
DEFAULT_PROJECT_NAME="aiops-project"
DEFAULT_CLOUD_PROVIDER="gcp"
DEFAULT_FRAMEWORK_VERSION="v3.7"

# Parse command line arguments
PROJECT_NAME="${1:-$DEFAULT_PROJECT_NAME}"
CLOUD_PROVIDER="${2:-$DEFAULT_CLOUD_PROVIDER}"
FRAMEWORK_VERSION="${3:-$DEFAULT_FRAMEWORK_VERSION}"

echo "🤖 AI Agent Development Framework $FRAMEWORK_VERSION Initialization"
echo "================================================"
echo "Project Name: $PROJECT_NAME"
echo "Cloud Provider: $CLOUD_PROVIDER"
echo "Framework Version: $FRAMEWORK_VERSION"
echo "================================================"

# Validate requirements
command -v git >/dev/null 2>&1 || { echo "❌ Git is required but not installed. Aborting." >&2; exit 1; }
command -v python3 >/dev/null 2>&1 || { echo "❌ Python 3 is required but not installed. Aborting." >&2; exit 1; }

# Create project directory structure
echo "📁 Creating project directory structure..."
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create directory structure
mkdir -p .github/workflows .github/environments
mkdir -p docs/{adr,ears,bdd,specs,prd,validation}
mkdir -p src/{tests/unit,tests/integration,tests/performance}
mkdir -p infrastructure/{terraform/{modules,environments},kubernetes/{base,overlays},docker}
mkdir -p scripts/{ai-agents,setup,deployment}
mkdir -p .ai_context

echo "✅ Directory structure created"

# Initialize Git repository
echo "🔧 Initializing Git repository..."
git init
git branch -M main

# Create .gitignore
cat > .gitignore << 'EOF'
# AI Agent Development Framework v3.7 - Git Ignore File

# Operating System Files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
*.swp
*.swo
*~

# IDE and Editor Files
.vscode/settings.json
.vscode/launch.json
.vscode/tasks.json
.idea/
*.sublime-project
*.sublime-workspace

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Virtual Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# Cloud and Infrastructure
.terraform/
*.tfstate
*.tfstate.*
.terraform.lock.hcl
terraform.tfvars
terraform.tfvars.json
*.tfplan
*.tfout

# Secrets and Configuration
.secrets/
.env.local
.env.development.local
.env.test.local
.env.production.local
config/secrets.yml
**/secrets/
**/*key*
**/*secret*
**/*token*
**/*credential*
**/*password*

# Framework-Specific
.ai_context/current_session_notes.md
.ai_context/temp_context.md
scripts/ai-agents/.cache/
deployment/.secrets/
docs/validation/temp_*
docs/specs/draft_*

# AI Assistant Configuration Files
AI_ASSISTANT.md
GEMINI.md
EOF

echo "✅ Git repository initialized with comprehensive .gitignore"

# Create environment template
cat > .env.template << EOF
# Project Configuration
PROJECT_NAME=$PROJECT_NAME
PROJECT_VERSION=1.0.0
FRAMEWORK_VERSION=$FRAMEWORK_VERSION

# Cloud Provider Configuration
CLOUD_PROVIDER=$CLOUD_PROVIDER
$(if [ "$CLOUD_PROVIDER" = "gcp" ]; then
    echo "GCP_PROJECT_ID=your-gcp-project-id"
    echo "GCP_REGION=us-central1"
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
    echo "AWS_ACCOUNT_ID=your-aws-account-id"
    echo "AWS_REGION=us-west-2"
elif [ "$CLOUD_PROVIDER" = "azure" ]; then
    echo "AZURE_SUBSCRIPTION_ID=your-azure-subscription-id"
    echo "AZURE_REGION=westus2"
fi)

# AI Agent Configuration
AI_PROVIDER=openai
AI_MODEL=gpt-4

# Development Environment
ENVIRONMENT=development
DEBUG=true

# Database Configuration (update with actual values)
DATABASE_URL=postgresql://user:password@localhost:5432/$(echo $PROJECT_NAME | tr '-' '_')
REDIS_URL=redis://localhost:6379

# Monitoring Configuration
MONITORING_ENABLED=true
LOG_LEVEL=INFO
EOF

cp .env.template .env
echo "✅ Environment configuration files created"

# Create basic README
cat > README.md << EOF
# $PROJECT_NAME

## AI Agent Development Framework v$FRAMEWORK_VERSION

This project is built using the AI Agent Development Framework v$FRAMEWORK_VERSION, providing AI-first development practices with comprehensive lifecycle automation.

### Quick Start

1. **Setup Environment**: Copy \`.env.template\` to \`.env\` and configure your values
2. **Install Dependencies**: Run \`scripts/setup/install-dependencies.sh\`
3. **Initialize Framework**: Follow the framework initialization guide
4. **Start Development**: Begin with the development phase documentation

### Framework Phases

- **Init Phase**: Project initialization and setup (current)
- **Development Phase**: AI-accelerated development with BDD and TDD
- **Deployment Phase**: AI-autonomous deployment with zero-downtime strategies  
- **Operations Phase**: AI-driven monitoring and operational excellence

### Directory Structure

- \`docs/\`: Documentation including ADRs, requirements, and specifications
- \`src/\`: Source code and tests
- \`infrastructure/\`: Terraform, Kubernetes, and Docker configurations
- \`scripts/\`: AI agents and automation scripts
- \`.ai_context/\`: AI context and framework progress tracking

### Getting Started

See the framework documentation for detailed guidance on each development phase.

### Framework Compliance

This project follows Framework v$FRAMEWORK_VERSION standards for:
- ✅ AI-first development methodology
- ✅ Zero-downtime deployment strategies
- ✅ Comprehensive testing automation
- ✅ Security-by-design principles
- ✅ Operational excellence practices

### Support

Refer to the AI Agent Development Framework v$FRAMEWORK_VERSION documentation for guidance and best practices.
EOF

echo "✅ README.md created"

# Create AI assistant configuration file
cat > AI_ASSISTANT.md << EOF
# AI Assistant Configuration

This file provides guidance to AI assistants when working with code in this repository.

## Project Overview

This is a **$PROJECT_NAME** project built with the AI Agent Development Framework v$FRAMEWORK_VERSION. The project follows AI-first development practices with comprehensive automation across all lifecycle phases.

## Framework Structure

This project implements the four-phase framework lifecycle:
- **Init Phase**: Project initialization and setup
- **Development Phase**: AI-accelerated development with BDD/TDD
- **Deployment Phase**: AI-autonomous deployment automation
- **Operations Phase**: AI-driven monitoring and optimization

## AI Context System

Always consult these files for project state and context:
- \`.ai_context/framework_progress.md\` - Master progress tracking
- \`.ai_context/current_context.md\` - Current working context
- \`.ai_context/team_patterns.md\` - Development patterns
- \`.ai_context/domain_context.md\` - Project-specific knowledge

## Development Commands

### Setup and Initialization
\`\`\`bash
# Install dependencies
scripts/setup/install-dependencies.sh

# Setup development environment
scripts/setup/setup-environments.sh

# Initialize cloud resources
scripts/deployment/init-infrastructure.sh
\`\`\`

### Testing and Quality
\`\`\`bash
# Run comprehensive tests
pytest src/tests/ --cov=src

# AI-powered code quality check
python scripts/ai-agents/code-quality-agent.py --analyze-all

# Generate BDD scenarios
python scripts/ai-agents/bdd-generator.py --feature-analysis
\`\`\`

### Deployment
\`\`\`bash
# Deploy to development environment
scripts/deployment/deploy.sh development

# Deploy with AI strategy selection
python scripts/ai-agents/deployment-agent.py --auto-strategy
\`\`\`

## Framework Compliance

This project maintains compliance with Framework v$FRAMEWORK_VERSION:
- File naming: Use snake_case for Python, kebab-case for configs
- Documentation: Maintain ADRs, EARS requirements, and BDD scenarios
- AI integration: Use AI agents for automation and decision-making
- Testing: Maintain 95%+ unit, 85%+ integration, 75%+ E2E coverage

## Cloud Platform: $CLOUD_PROVIDER

Project is configured for **$CLOUD_PROVIDER** deployment with:
$(if [ "$CLOUD_PROVIDER" = "gcp" ]; then
    echo "- Google Kubernetes Engine (GKE) for container orchestration"
    echo "- Cloud Run for serverless deployments"
    echo "- Cloud SQL for managed databases"
    echo "- Cloud Monitoring for observability"
elif [ "$CLOUD_PROVIDER" = "aws" ]; then
    echo "- Amazon EKS for container orchestration"
    echo "- AWS Lambda for serverless functions"
    echo "- Amazon RDS for managed databases"
    echo "- CloudWatch for monitoring"
elif [ "$CLOUD_PROVIDER" = "azure" ]; then
    echo "- Azure Kubernetes Service (AKS) for containers"
    echo "- Azure Functions for serverless"
    echo "- Azure Database for PostgreSQL"
    echo "- Azure Monitor for observability"
fi)

## Best Practices

- Always update \`.ai_context/current_context.md\` when working on features
- Use AI agents for repetitive tasks and analysis
- Follow framework validation checkpoints
- Maintain comprehensive documentation for all changes
- Use semantic versioning for releases

This project is designed for systematic, AI-first software development with comprehensive lifecycle coverage.
EOF

echo "✅ AI_ASSISTANT.md created for AI assistant integration"

# Create AI context files
cat > .ai_context/framework_progress.md << EOF
# Framework Progress Tracking
## AI Agent Development Framework v$FRAMEWORK_VERSION

**Project**: $PROJECT_NAME  
**Initialized**: $(date)  
**Framework Version**: $FRAMEWORK_VERSION  
**Current Phase**: Init (Phase -1 to 0)  

## Phase Status

### ✅ Init Phase (Phase -1 to 0) - IN PROGRESS
- [x] Project structure created
- [x] Git repository initialized
- [x] Basic configuration files created
- [x] AI context system setup
- [ ] Cloud provider configuration
- [ ] CI/CD pipeline setup
- [ ] Team onboarding completed

### ⏳ Development Phase (Phase 1-6) - PENDING
- [ ] Requirements analysis (EARS format)
- [ ] BDD scenario creation
- [ ] Architecture decisions (ADRs)
- [ ] Technical specifications
- [ ] TDD implementation
- [ ] Comprehensive testing

### ⏳ Deployment Phase (Phase 7) - PENDING
- [ ] Infrastructure provisioning
- [ ] CI/CD pipeline configuration
- [ ] Security validation
- [ ] Zero-downtime deployment setup

### ⏳ Operations Phase (Phase 8) - PENDING
- [ ] Monitoring and observability
- [ ] AI-autonomous operations
- [ ] Performance optimization
- [ ] Incident response procedures

## Next Steps

1. Complete cloud provider configuration
2. Setup CI/CD pipelines using templates
3. Initialize development environment
4. Begin Development Phase (Phase 1)

## Framework Compliance Status

- **Structure Compliance**: ✅ 100%
- **Documentation Standards**: ✅ 100%  
- **AI Integration**: ⏳ In Progress
- **Security Standards**: ⏳ Pending
- **Testing Framework**: ⏳ Pending

## Notes

Project initialized with Framework v$FRAMEWORK_VERSION template structure. Ready to proceed with cloud configuration and CI/CD setup.
EOF

echo "✅ AI context framework progress tracking created"

# Create basic AI agent requirements
cat > scripts/ai-agents/requirements.txt << EOF
# AI Agent Dependencies for Framework v$FRAMEWORK_VERSION
openai>=1.0.0
anthropic>=0.7.0
google-cloud-aiplatform>=1.38.0
requests>=2.31.0
pyyaml>=6.0
click>=8.1.0
jinja2>=3.1.0
python-dotenv>=1.0.0
structlog>=23.1.0
tenacity>=8.2.0
jsonschema>=4.17.0
pydantic>=2.0.0
EOF

echo "✅ AI agent dependencies file created"

# Create initial commit
git add .
git commit -m "🚀 Initial commit: AI Agent Development Framework v$FRAMEWORK_VERSION project initialization

- Project structure created following Framework v$FRAMEWORK_VERSION
- Git repository initialized with comprehensive .gitignore
- Environment configuration template created
- AI context system initialized
- AI_ASSISTANT.md created for AI assistant integration
- Basic documentation and README established
- AI agent dependencies configured

Ready for Development Phase initialization."

echo ""
echo "🎉 Project '$PROJECT_NAME' successfully initialized!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure your .env file with actual values"
echo "2. Setup your $CLOUD_PROVIDER cloud resources"
echo "3. Install dependencies: scripts/setup/install-dependencies.sh"
echo "4. Setup CI/CD: Copy workflow templates from framework"
echo "5. Begin Development Phase following framework methodology"
echo ""
echo "📚 Framework Documentation: Refer to AI Agent Development Framework v$FRAMEWORK_VERSION"
echo "🤖 AI Context: Check .ai_context/framework_progress.md for current status"
echo ""
echo "Happy coding with AI-first development! 🚀"