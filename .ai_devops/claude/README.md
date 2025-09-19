# Claude Code Testing & Deployment Framework

A comprehensive AI-powered framework that uses Claude Code CLI for automated testing and cloud deployment with GitHub workflows and self-hosted runners.

## Overview

This framework provides automated capabilities using Claude AI to:

### 🧪 Testing Capabilities
- **Generate comprehensive unit tests** for code changes
- **Analyze test coverage** and identify gaps
- **Execute tests** and analyze failures with AI insights
- **Review test quality** and provide improvement recommendations
- **Post detailed PR comments** with actionable feedback

### 🚀 Deployment Capabilities
- **AI-powered deployment analysis** and readiness assessment
- **Infrastructure validation** with best practices review
- **Security scanning** and vulnerability assessment
- **Deployment strategy generation** with rollback plans
- **Multi-cloud support** (GCP, Azure) with cloud-specific optimizations
- **Standalone Azure framework** for simple Docker container deployments

## 🚀 Quick Start

### Prerequisites
- Self-hosted GitHub runners with Claude Code CLI installed
- `ANTHROPIC_API_KEY` configured in GitHub repository secrets
- Cloud provider CLI tools (gcloud for GCP, az CLI for Azure)
- Cloud provider authentication configured in secrets
- Basic testing frameworks installed (pytest, jest, etc.)

### Setup
1. Copy the `.ai_devops/claude/` directory to your repository
2. **NEW**: Copy the `.ai_devops/azure/` directory for standalone Azure deployments
3. Copy the workflow files to `.github/workflows/`:
   - `claude-unit-testing.yml` for testing
   - `claude-gcp-deployment.yml` for GCP deployments
   - `claude-azure-deployment.yml` for Azure deployments
4. Configure required secrets:
   - `ANTHROPIC_API_KEY` for Claude Code access
   - Cloud provider credentials (see Cloud Setup section)
5. Customize configurations in `configs/` for your project needs

### Basic Usage
- **Testing**: Automatically runs on pull requests to analyze changes and provide testing feedback
- **Deployment**: Triggered on pushes to main/release branches or manually with workflow dispatch
- **Multi-cloud**: Choose between GCP and Azure deployment workflows based on your infrastructure
- **Standalone Azure**: Deploy Docker containers directly using `.ai_devops/azure/scripts/` without GitHub Actions

## 📁 Framework Structure

```
.ai_devops/
├── claude/                            # Main Claude framework
│   ├── scripts/                           # Core framework scripts
│   │   ├── claude-test-generator.sh           # Generate tests with Claude
│   │   ├── claude-test-analyzer.sh            # Analyze coverage gaps
│   │   ├── claude-test-executor.sh            # Execute tests and analyze failures
│   │   ├── claude-test-reviewer.sh            # Review test quality
│   │   ├── generate-pr-comment.sh             # Generate PR feedback
│   │   ├── claude-deployment-analyzer.sh      # AI deployment analysis
│   │   ├── claude-infrastructure-validator.sh # Infrastructure validation
│   │   ├── claude-security-scanner.sh         # Security vulnerability scanning
│   │   └── claude-deployment-strategy.sh      # Deployment strategy generation
│   ├── prompts/                           # Claude prompt templates
│   ├── configs/                           # Configuration files
│   ├── templates/                         # Report templates
│   └── README.md                          # Main framework documentation
└── azure/                             # NEW: Standalone Azure framework
    ├── scripts/                           # Azure deployment scripts
    │   ├── deploy-docker-container.sh        # Simple container deployment
    │   ├── validate-deployment.sh            # Deployment validation
    │   ├── cleanup-containers.sh             # Container management
    │   ├── test-deployment.sh               # Comprehensive testing
    │   └── claude-integration-test.sh        # Claude integration tests
    ├── configs/                           # Azure-specific configurations
    │   ├── azure-deployment.json            # Main Azure config
    │   ├── container-defaults.json          # Container defaults
    │   └── claude-prompts.json              # Claude AI prompts
    ├── samples/                           # Sample applications
    │   └── simple-web-app/                  # Ready-to-deploy web app
    │       ├── Dockerfile                   # Container definition
    │       ├── nginx.conf                   # Web server config
    │       ├── health-check.sh              # Health monitoring
    │       ├── deploy.sh                    # One-command deployment
    │       └── static/                      # Web content
    ├── templates/                         # Infrastructure as Code
    │   ├── arm/                            # ARM templates
    │   ├── bicep/                          # Bicep templates
    │   └── deployment-parameters.json      # Parameter files
    ├── docs/                             # Azure framework documentation
    │   └── claude-deployment-guide.md      # Claude agent guide
    └── README.md                         # Azure framework documentation
```

## ⚙️ Configuration

### Main Configuration (`configs/testing-config.json`)

```json
{
  "test_frameworks": ["pytest", "unittest"],
  "coverage_targets": {
    "unit": 95,
    "integration": 85,
    "e2e": 75
  },
  "claude_settings": {
    "max_turns": 3,
    "output_format": "json",
    "model": "claude-3-5-sonnet-20241022"
  },
  "quality_thresholds": {
    "min_quality_score": 60,
    "required_test_patterns": ["happy_path", "edge_cases", "error_handling"]
  }
}
```

### Claude Settings (`configs/claude-settings.json`)

Advanced configuration for Claude CLI behavior, performance optimization, and integration settings.

## 🔧 Core Components

### 1. Test Generation (`claude-test-generator.sh`)
- Analyzes git diff to identify changed files
- Uses Claude to generate comprehensive unit tests
- Supports multiple programming languages and frameworks
- Creates detailed generation reports

**Key Features:**
- Smart diff analysis and context preparation
- Framework-specific test generation
- Comprehensive scenario coverage (happy path, edge cases, errors)
- Integration with project conventions

### 2. Coverage Analysis (`claude-test-analyzer.sh`)
- Discovers source and test files automatically
- Generates coverage reports using available tools
- Uses Claude to identify testing gaps and improvement opportunities
- Provides strategic recommendations for coverage improvement

**Key Features:**
- Multi-language support (Python, JavaScript, TypeScript)
- Integration with coverage tools (coverage.py, jest)
- AI-powered gap analysis
- Risk-based prioritization

### 3. Test Execution (`claude-test-executor.sh`)
- Runs tests using appropriate frameworks
- Captures and analyzes test failures
- Uses Claude to provide failure analysis and fix suggestions
- Generates execution reports with metrics

**Key Features:**
- Multi-framework test execution
- Intelligent failure analysis
- Performance metrics tracking
- Detailed error reporting

### 4. Quality Review (`claude-test-reviewer.sh`)
- Reviews test code for quality and best practices
- Evaluates test organization and maintainability
- Provides specific improvement recommendations
- Calculates quality scores and metrics

**Key Features:**
- Comprehensive quality assessment
- Best practices compliance checking
- Maintainability analysis
- Actionable improvement suggestions

## 🎯 Testing Workflow

### Automatic Trigger (Pull Requests)
1. **Validation**: Check Claude CLI setup and configuration
2. **Generation**: Analyze changes and generate tests with Claude
3. **Analysis**: Evaluate test coverage and identify gaps
4. **Execution**: Run tests and analyze any failures
5. **Review**: Assess test quality and provide recommendations
6. **Feedback**: Generate comprehensive PR comment with results
7. **Quality Gates**: Evaluate against configured thresholds

### Manual Trigger
You can manually trigger the workflow with custom parameters:
- Force full analysis regardless of changes
- Override coverage targets
- Specify custom test frameworks

## 📊 Reporting and Feedback

### PR Comments
Automated PR comments include:
- Overall status and key metrics
- Test coverage vs targets
- Test execution results
- Quality assessment scores
- Specific recommendations
- Detailed reports (expandable)

### Detailed Reports
Generated reports include:
- **Generation Report**: Details about generated tests
- **Coverage Analysis**: Comprehensive coverage assessment
- **Execution Report**: Test results and failure analysis
- **Quality Review**: Test quality assessment and recommendations

### Artifacts
All reports and analysis results are saved as GitHub Actions artifacts for further review and historical tracking.

## 🔍 Advanced Features

### Prompt Engineering
The framework uses sophisticated prompts for:
- **Context-aware test generation** following project conventions
- **Strategic coverage analysis** with risk-based prioritization
- **Intelligent failure diagnosis** with specific fix recommendations
- **Comprehensive quality review** against industry best practices

### Performance Optimization
- **Parallel execution** of independent analysis steps
- **Token usage optimization** through intelligent context management
- **Caching strategies** for repeated analysis scenarios
- **Efficient resource utilization** on self-hosted runners

### Integration Capabilities
- **Multi-language support** (Python, JavaScript, TypeScript, etc.)
- **Framework flexibility** (pytest, jest, unittest, etc.)
- **Tool integration** (coverage tools, linters, security scanners)
- **Workflow coordination** with existing CI/CD pipelines

## 🛠️ Customization

### Adding New Languages
1. Update `file_patterns` in `testing-config.json`
2. Add language-specific logic to scripts
3. Update prompts to include language-specific patterns
4. Test with sample code in the new language

### Custom Prompts
1. Edit prompt files in `prompts/` directory
2. Use placeholders for dynamic content (e.g., `{test_framework}`)
3. Test prompts with representative code samples
4. Version control prompt changes for consistency

### Integration with Existing Workflows
1. Coordinate with existing security scans and code reviews
2. Configure quality gates based on team requirements
3. Customize reporting formats for team preferences
4. Set up notifications and alerting as needed

## 🚀 Cloud Deployment Workflows

### GCP Deployment Setup

#### Required Secrets
```
ANTHROPIC_API_KEY          # Claude Code API access
GCP_SERVICE_ACCOUNT_KEY    # GCP service account JSON (base64 encoded)
GCP_PROJECT_ID             # Your GCP project ID
```

#### Optional Variables
```
GCP_REGION                 # Default: us-central1
AZURE_RESOURCE_GROUP       # Default: rg-myapp
```

#### Workflow Features
- **AI-Powered Analysis**: Deployment readiness assessment
- **Infrastructure Validation**: Terraform and GKE configuration review
- **Security Scanning**: Comprehensive security assessment
- **Strategy Generation**: Blue-green, rolling, and canary deployment strategies
- **Post-Deployment Validation**: Health checks and performance monitoring

#### Supported Services
- Google Compute Engine (GCE)
- Google Kubernetes Engine (GKE)
- Cloud Run
- Cloud Storage
- Cloud SQL
- VPC and networking
- Cloud Monitoring and Logging

### Azure Deployment Setup

#### Required Secrets
```
ANTHROPIC_API_KEY          # Claude Code API access
AZURE_SUBSCRIPTION_ID      # Azure subscription ID
AZURE_TENANT_ID            # Azure AD tenant ID
AZURE_CLIENT_ID            # Service principal client ID
AZURE_CLIENT_SECRET        # Service principal client secret
```

#### Optional Variables
```
AZURE_LOCATION             # Default: East US
AZURE_RESOURCE_GROUP       # Default: rg-myapp
```

#### Workflow Features
- **AI-Powered Analysis**: Application and infrastructure readiness
- **Infrastructure Validation**: ARM/Bicep template validation
- **Security Assessment**: Azure-specific security scanning
- **Multi-Service Support**: VMs, AKS, Container Instances, App Services
- **Cost Optimization**: Budget monitoring and recommendations

#### Supported Services
- Virtual Machines
- Azure Kubernetes Service (AKS)
- Container Instances
- App Service
- Storage Accounts
- SQL Database
- Virtual Networks
- Application Gateway
- Key Vault
- Application Insights

### Deployment Workflow Triggers

#### Automatic Triggers
- **Push to main/release branches**: Triggers deployment to staging
- **Closed PR to main**: Triggers production deployment validation

#### Manual Triggers
- **Workflow Dispatch**: Manual deployment with environment selection
- **Environment Selection**: Choose development, staging, or production
- **Deployment Type**: Standard, blue-green, rolling, or canary
- **Force Deployment**: Override validation failures (use with caution)

### Deployment Strategies

#### Blue-Green Deployment
- Deploys to parallel environment
- Validates new version thoroughly
- Switches traffic atomically
- Enables instant rollback

#### Rolling Deployment
- Gradual instance replacement
- Maintains service availability
- Configurable batch sizes
- Automatic rollback on failure

#### Standard Deployment
- Traditional deployment approach
- Maintenance window support
- Comprehensive backup procedures
- Step-by-step validation

### AI-Powered Deployment Features

#### Pre-Deployment Analysis
- **Readiness Assessment**: AI evaluates deployment readiness
- **Dependency Analysis**: Reviews external service dependencies
- **Risk Assessment**: Identifies potential deployment risks
- **Resource Planning**: Validates compute and storage requirements

#### Infrastructure Validation
- **Configuration Review**: Validates IaC templates and configurations
- **Security Assessment**: Reviews security configurations and policies
- **Best Practices**: Ensures cloud provider best practices compliance
- **Cost Analysis**: Evaluates deployment costs and optimization opportunities

#### Deployment Strategy Generation
- **Automated Planning**: AI generates deployment procedures
- **Rollback Planning**: Creates comprehensive rollback procedures
- **Monitoring Setup**: Configures health checks and alerting
- **Documentation**: Generates deployment documentation

## 🔐 Security Considerations

- **API Key Management**: Secure storage of Anthropic API keys
- **Output Sanitization**: Automatic redaction of sensitive information
- **Access Control**: Proper permissions for self-hosted runners
- **Audit Trail**: Comprehensive logging of all AI interactions

## 📈 Metrics and Monitoring

### Key Metrics Tracked
- Test coverage percentages by type
- Test execution success rates
- Quality scores and trends
- Framework performance metrics
- AI analysis effectiveness

### Success Criteria
- 95%+ unit test coverage for new code
- 85%+ integration test coverage
- <15 minute total workflow execution time
- <5% false positive test failures
- High-quality generated tests following project conventions

## 🚨 Troubleshooting

### Common Issues

**Claude CLI Connection Issues**
- Verify `ANTHROPIC_API_KEY` is correctly configured
- Check Claude CLI installation and version
- Test connection with simple query

**Test Framework Issues**
- Ensure testing dependencies are installed
- Check framework configuration in `testing-config.json`
- Verify test discovery patterns

**Performance Issues**
- Adjust `max_turns` and token limits in configuration
- Optimize prompt complexity and context size
- Consider parallel execution settings

**Quality Gate Failures**
- Review coverage targets and adjust if needed
- Check test quality thresholds
- Analyze specific failures in detailed reports

### Debug Mode
Enable verbose logging by setting `verbose: true` in `claude-settings.json` and checking workflow logs for detailed execution information.

## 🤝 Contributing

### Adding Features
1. Update relevant scripts and configurations
2. Add appropriate tests and documentation
3. Update this README with new capabilities
4. Test thoroughly with representative code samples

### Reporting Issues
1. Check existing documentation and troubleshooting guide
2. Provide reproduction steps and workflow logs
3. Include relevant configuration and environment details
4. Test with minimal reproduction case

## 📚 Additional Resources

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Self-hosted Runners Setup](https://docs.github.com/en/actions/hosting-your-own-runners)

## 📋 Changelog

### v2.0.0 (Current)
- **NEW**: AI-powered cloud deployment workflows for GCP and Azure
- **NEW**: Comprehensive deployment analysis and readiness assessment
- **NEW**: Infrastructure validation with best practices review
- **NEW**: Security scanning and vulnerability assessment
- **NEW**: Automated deployment strategy generation with rollback plans
- **NEW**: Multi-cloud support with cloud-specific optimizations
- **NEW**: Blue-green, rolling, and canary deployment strategies
- **NEW**: Post-deployment validation and health checks
- **ENHANCED**: Extended configuration system for deployment settings
- **ENHANCED**: Advanced prompt templates for deployment scenarios

### v1.0.0
- Initial release with comprehensive testing framework
- Support for Python, JavaScript, and TypeScript
- Integration with pytest, jest, and unittest
- AI-powered test generation, analysis, and review
- GitHub Actions workflow with self-hosted runners
- Detailed reporting and PR feedback

---

**Framework developed for AI-first software development with comprehensive lifecycle coverage while maintaining human strategic oversight.**