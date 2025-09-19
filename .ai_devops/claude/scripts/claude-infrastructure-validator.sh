#!/bin/bash

# Claude Infrastructure Validator Script
# Validates infrastructure configurations using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/deployment-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-infra-validation-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🔧 Claude Infrastructure Validator - Starting infrastructure validation..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
CLOUD_PROVIDER="${1:-auto}"
VALIDATION_TYPE="${2:-comprehensive}"
ENVIRONMENT="${3:-staging}"

if [[ -f "$CONFIG_FILE" ]]; then
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
    VALIDATION_DEPTH=$(jq -r '.infrastructure_validation.depth' "$CONFIG_FILE" 2>/dev/null || echo "thorough")
    COMPLIANCE_CHECKS=$(jq -r '.infrastructure_validation.compliance_checks' "$CONFIG_FILE" 2>/dev/null || echo "true")
else
    echo "⚠️  Warning: Deployment config file not found, using defaults"
    CLAUDE_MAX_TURNS="3"
    VALIDATION_DEPTH="thorough"
    COMPLIANCE_CHECKS="true"
fi

echo "🎯 Validation parameters: Provider=$CLOUD_PROVIDER, Type=$VALIDATION_TYPE, Environment=$ENVIRONMENT"

# Validate Terraform configurations
echo "🏗️  Validating Terraform configurations..."
TERRAFORM_VALIDATION=""
if find . -name "*.tf" -type f | head -1 | grep -q .; then
    # Check Terraform syntax
    if command -v terraform &> /dev/null; then
        echo "  Running terraform init and validate..."
        terraform init -backend=false > "$TEMP_DIR/terraform_init.log" 2>&1 || true
        terraform validate > "$TEMP_DIR/terraform_validate.log" 2>&1 || true
        TERRAFORM_VALIDATION=$(cat "$TEMP_DIR/terraform_validate.log" 2>/dev/null || echo "Terraform validation unavailable")
    else
        TERRAFORM_VALIDATION="Terraform CLI not available - static analysis only"
    fi
    
    # Collect all Terraform files for analysis
    find . -name "*.tf" -type f > "$TEMP_DIR/terraform_files.txt"
    TERRAFORM_CONTENT=$(head -5 "$TEMP_DIR/terraform_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            cat "$file"
            echo ""
        fi
    done)
else
    TERRAFORM_VALIDATION="No Terraform files found"
    TERRAFORM_CONTENT="No Terraform configuration detected"
fi

# Validate Docker configurations
echo "🐳 Validating Docker configurations..."
DOCKER_VALIDATION=""
if find . -name "Dockerfile*" -type f | head -1 | grep -q .; then
    find . -name "Dockerfile*" -type f > "$TEMP_DIR/docker_files.txt"
    
    # Basic Dockerfile validation
    DOCKER_ISSUES=""
    while read -r dockerfile; do
        if [[ -f "$dockerfile" ]]; then
            # Check for common issues
            if ! grep -q "^FROM " "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- Missing FROM instruction in $dockerfile"
            fi
            if grep -q "^USER root" "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- Running as root user in $dockerfile (security concern)"
            fi
            if ! grep -q "^COPY\|^ADD" "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- No file copying instructions in $dockerfile"
            fi
        fi
    done < "$TEMP_DIR/docker_files.txt"
    
    DOCKER_VALIDATION="Docker files found: $(wc -l < "$TEMP_DIR/docker_files.txt")"
    if [[ -n "$DOCKER_ISSUES" ]]; then
        DOCKER_VALIDATION="$DOCKER_VALIDATION\nIssues identified:$DOCKER_ISSUES"
    fi
    
    # Collect Docker content
    DOCKER_CONTENT=$(head -3 "$TEMP_DIR/docker_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            cat "$file"
            echo ""
        fi
    done)
else
    DOCKER_VALIDATION="No Docker files found"
    DOCKER_CONTENT="No Docker configuration detected"
fi

# Validate Kubernetes configurations
echo "☸️  Validating Kubernetes configurations..."
K8S_VALIDATION=""
if find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes|helm)" | head -1 | grep -q .; then
    find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes|helm)" > "$TEMP_DIR/k8s_files.txt"
    
    # Basic YAML syntax validation
    K8S_ISSUES=""
    while read -r yamlfile; do
        if [[ -f "$yamlfile" ]]; then
            if command -v yamllint &> /dev/null; then
                if ! yamllint "$yamlfile" > /dev/null 2>&1; then
                    K8S_ISSUES="$K8S_ISSUES\n- YAML syntax issues in $yamlfile"
                fi
            fi
        fi
    done < "$TEMP_DIR/k8s_files.txt"
    
    K8S_VALIDATION="Kubernetes files found: $(wc -l < "$TEMP_DIR/k8s_files.txt")"
    if [[ -n "$K8S_ISSUES" ]]; then
        K8S_VALIDATION="$K8S_VALIDATION\nIssues identified:$K8S_ISSUES"
    fi
    
    # Collect K8s content
    K8S_CONTENT=$(head -3 "$TEMP_DIR/k8s_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            cat "$file" | head -50
            echo ""
        fi
    done)
else
    K8S_VALIDATION="No Kubernetes files found"
    K8S_CONTENT="No Kubernetes configuration detected"
fi

# Validate cloud provider specific configurations
echo "☁️  Validating cloud provider configurations..."
CLOUD_CONFIG_VALIDATION=""

case $CLOUD_PROVIDER in
    "gcp"|"auto")
        # Check for GCP-specific files
        if find . -name "*.tf" -exec grep -l "google\|gcp" {} \; | head -1 | grep -q .; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nGCP Terraform configuration detected"
        fi
        if [[ -f "cloudbuild.yaml" ]] || [[ -f ".gcloudignore" ]]; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nGCP Cloud Build configuration detected"
        fi
        ;;
    "azure"|"auto")
        # Check for Azure-specific files
        if find . -name "*.tf" -exec grep -l "azurerm\|azure" {} \; | head -1 | grep -q .; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nAzure Terraform configuration detected"
        fi
        if [[ -f "azure-pipelines.yml" ]] || find . -name "*.json" -exec grep -l "Microsoft.Resources" {} \; | head -1 | grep -q .; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nAzure Resource Manager templates detected"
        fi
        ;;
    "aws"|"auto")
        # Check for AWS-specific files
        if find . -name "*.tf" -exec grep -l "aws" {} \; | head -1 | grep -q .; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nAWS Terraform configuration detected"
        fi
        if [[ -f "buildspec.yml" ]] || find . -name "*cloudformation*" | head -1 | grep -q .; then
            CLOUD_CONFIG_VALIDATION="$CLOUD_CONFIG_VALIDATION\nAWS CodeBuild/CloudFormation configuration detected"
        fi
        ;;
esac

if [[ -z "$CLOUD_CONFIG_VALIDATION" ]]; then
    CLOUD_CONFIG_VALIDATION="No specific cloud provider configurations detected"
fi

# Load infrastructure validation prompt
VALIDATION_PROMPT=""
if [[ -f "$PROMPTS_DIR/infrastructure-validation.txt" ]]; then
    VALIDATION_PROMPT=$(cat "$PROMPTS_DIR/infrastructure-validation.txt")
else
    # Fallback prompt
    VALIDATION_PROMPT="You are a senior infrastructure engineer and cloud architect. Validate these infrastructure configurations for best practices, security, scalability, and compliance. Identify issues and provide specific recommendations for improvement."
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$VALIDATION_PROMPT" | \
    sed "s/{cloud_provider}/$CLOUD_PROVIDER/g" | \
    sed "s/{validation_type}/$VALIDATION_TYPE/g" | \
    sed "s/{environment}/$ENVIRONMENT/g" | \
    sed "s/{validation_depth}/$VALIDATION_DEPTH/g")

# Create comprehensive input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Infrastructure Validation Context:
- Cloud Provider: $CLOUD_PROVIDER
- Validation Type: $VALIDATION_TYPE
- Environment: $ENVIRONMENT
- Validation Depth: $VALIDATION_DEPTH
- Compliance Checks: $COMPLIANCE_CHECKS

Terraform Configuration Analysis:
$TERRAFORM_VALIDATION
$TERRAFORM_CONTENT

Docker Configuration Analysis:
$DOCKER_VALIDATION
$DOCKER_CONTENT

Kubernetes Configuration Analysis:
$K8S_VALIDATION
$K8S_CONTENT

Cloud Provider Specific Configurations:
$CLOUD_CONFIG_VALIDATION

Security Considerations:
- Environment: $ENVIRONMENT
- Compliance requirements: $(if [[ "$COMPLIANCE_CHECKS" == "true" ]]; then echo "Required"; else echo "Optional"; fi)

Project Context:
$(if [[ -f "CLAUDE.md" ]]; then head -30 "CLAUDE.md"; fi)

Additional Infrastructure Files:
$(find . -name "*.env*" -o -name "*.conf" -o -name "*config*" | grep -v "node_modules\|\.git" | head -10)
EOF

echo "🤖 Validating infrastructure with Claude..."

# Validate with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_validation.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_validation.json" ]]; then
    echo "❌ Error: Claude did not generate infrastructure validation"
    exit 1
fi

echo "✅ Claude infrastructure validation complete"

# Extract validation from Claude's response
VALIDATION_CONTENT=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_validation.json")

# Parse specific sections if available
CRITICAL_ISSUES=$(echo "$VALIDATION_CONTENT" | grep -A 10 -i "critical\|blocking\|error" | head -15 || echo "No critical issues identified")
SECURITY_CONCERNS=$(echo "$VALIDATION_CONTENT" | grep -A 10 -i "security\|vulnerability" | head -15 || echo "No security concerns identified")
RECOMMENDATIONS=$(echo "$VALIDATION_CONTENT" | grep -A 15 -i "recommend\|improve\|fix" | head -20 || echo "See full validation report")

# Count infrastructure files
TERRAFORM_FILES=$(find . -name "*.tf" -type f | wc -l)
DOCKER_FILES=$(find . -name "Dockerfile*" -type f | wc -l)
K8S_FILES=$(find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes|helm)" | wc -l)

# Create infrastructure validation report
cat > "$TEMP_DIR/infrastructure_validation_report.md" << EOF
# Infrastructure Validation Report

## Summary
- **Validated at**: $(date)
- **Cloud Provider**: $CLOUD_PROVIDER
- **Validation Type**: $VALIDATION_TYPE
- **Environment**: $ENVIRONMENT
- **Compliance Checks**: $COMPLIANCE_CHECKS

## Infrastructure Inventory
- **Terraform files**: $TERRAFORM_FILES
- **Docker files**: $DOCKER_FILES
- **Kubernetes files**: $K8S_FILES

## Validation Results

### Critical Issues
$CRITICAL_ISSUES

### Security Concerns
$SECURITY_CONCERNS

### Key Recommendations
$RECOMMENDATIONS

## Detailed Analysis

### Terraform Validation
$TERRAFORM_VALIDATION

### Docker Validation  
$DOCKER_VALIDATION

### Kubernetes Validation
$K8S_VALIDATION

### Cloud Provider Configuration
$CLOUD_CONFIG_VALIDATION

## Claude Infrastructure Analysis
$VALIDATION_CONTENT

## Next Steps
1. Address all critical issues before deployment
2. Implement security recommendations
3. Review and test configuration changes
4. Validate with cloud provider tools
5. Run security scan on infrastructure
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../deployment_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/infrastructure_validation_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_validation.json" "$RESULTS_DIR/"

echo "📄 Infrastructure validation report saved to: $RESULTS_DIR/infrastructure_validation_report.md"
echo "✨ Infrastructure validation complete!"

# Determine validation status
VALIDATION_STATUS="pass"
if echo "$VALIDATION_CONTENT" | grep -q -i "critical\|blocking\|error\|fail"; then
    VALIDATION_STATUS="fail"
elif echo "$VALIDATION_CONTENT" | grep -q -i "warning\|concern\|issue"; then
    VALIDATION_STATUS="warning"
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "validation_complete=true" >> "$GITHUB_OUTPUT"
    echo "validation_status=$VALIDATION_STATUS" >> "$GITHUB_OUTPUT"
    echo "terraform_files=$TERRAFORM_FILES" >> "$GITHUB_OUTPUT"
    echo "docker_files=$DOCKER_FILES" >> "$GITHUB_OUTPUT"
    echo "k8s_files=$K8S_FILES" >> "$GITHUB_OUTPUT"
    echo "cloud_provider=$CLOUD_PROVIDER" >> "$GITHUB_OUTPUT"
    echo "validation_report_path=$RESULTS_DIR/infrastructure_validation_report.md" >> "$GITHUB_OUTPUT"
fi

# Exit with appropriate status
if [[ "$VALIDATION_STATUS" == "fail" ]]; then
    echo "❌ Infrastructure validation failed - check report for critical issues"
    exit 1
else
    echo "✅ Infrastructure validation completed with status: $VALIDATION_STATUS"
    exit 0
fi