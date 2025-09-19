#!/bin/bash

# Claude Deployment Analyzer Script
# Analyzes deployment readiness and infrastructure using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/deployment-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-deployment-analysis-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🚀 Claude Deployment Analyzer - Starting deployment readiness analysis..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
CLOUD_PROVIDER="${1:-auto}"
ENVIRONMENT="${2:-staging}"
DEPLOYMENT_TYPE="${3:-standard}"

if [[ -f "$CONFIG_FILE" ]]; then
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
    ANALYSIS_DEPTH=$(jq -r '.deployment_analysis.depth' "$CONFIG_FILE" 2>/dev/null || echo "comprehensive")
    SECURITY_LEVEL=$(jq -r '.deployment_analysis.security_level' "$CONFIG_FILE" 2>/dev/null || echo "high")
else
    echo "⚠️  Warning: Deployment config file not found, using defaults"
    CLAUDE_MAX_TURNS="3"
    ANALYSIS_DEPTH="comprehensive"
    SECURITY_LEVEL="high"
fi

echo "🎯 Analysis parameters: Provider=$CLOUD_PROVIDER, Environment=$ENVIRONMENT, Type=$DEPLOYMENT_TYPE"

# Analyze current codebase for deployment readiness
echo "📊 Analyzing codebase for deployment readiness..."

# Collect deployment-related files
find . -name "Dockerfile*" -o -name "docker-compose*.yml" > "$TEMP_DIR/docker_files.txt" 2>/dev/null || true
find . -name "*.tf" -o -name "*.tfvars" > "$TEMP_DIR/terraform_files.txt" 2>/dev/null || true
find . -name "*.json" | grep -E "(package|requirements|Pipfile|pom|build\.gradle)" > "$TEMP_DIR/dependency_files.txt" 2>/dev/null || true
find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes|helm|compose)" > "$TEMP_DIR/k8s_files.txt" 2>/dev/null || true

# Get recent changes that might affect deployment
git log --oneline -10 --grep="deploy\|release\|build\|config" > "$TEMP_DIR/recent_deployment_changes.txt" 2>/dev/null || echo "No recent deployment-related changes" > "$TEMP_DIR/recent_deployment_changes.txt"

# Get current git status and branch info
git status --porcelain > "$TEMP_DIR/git_status.txt" 2>/dev/null || true
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Collect application configuration files
find . -name "*.env*" -o -name "config.*" -o -name "settings.*" | head -10 > "$TEMP_DIR/config_files.txt" 2>/dev/null || true

# Check for CI/CD files
find . -path "*/.github/workflows/*" -o -path "*/.gitlab-ci.yml" -o -path "*/azure-pipelines.yml" > "$TEMP_DIR/cicd_files.txt" 2>/dev/null || true

# Collect resource and manifest files
DOCKERFILE_CONTENT=""
TERRAFORM_SUMMARY=""
K8S_SUMMARY=""
PACKAGE_SUMMARY=""

if [[ -s "$TEMP_DIR/docker_files.txt" ]]; then
    DOCKERFILE_CONTENT=$(head -5 "$TEMP_DIR/docker_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -20 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

if [[ -s "$TEMP_DIR/terraform_files.txt" ]]; then
    TERRAFORM_SUMMARY=$(head -5 "$TEMP_DIR/terraform_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -30 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

if [[ -s "$TEMP_DIR/k8s_files.txt" ]]; then
    K8S_SUMMARY=$(head -3 "$TEMP_DIR/k8s_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -25 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

if [[ -s "$TEMP_DIR/dependency_files.txt" ]]; then
    PACKAGE_SUMMARY=$(head -3 "$TEMP_DIR/dependency_files.txt" | while read -r file; do
        if [[ -f "$file" ]]; then
            echo "=== $file ==="
            head -15 "$file" 2>/dev/null || true
            echo ""
        fi
    done)
fi

# Load deployment analysis prompt
DEPLOYMENT_PROMPT=""
if [[ -f "$PROMPTS_DIR/deployment-analysis.txt" ]]; then
    DEPLOYMENT_PROMPT=$(cat "$PROMPTS_DIR/deployment-analysis.txt")
else
    # Fallback prompt
    DEPLOYMENT_PROMPT="You are a senior DevOps engineer and cloud architect. Analyze this application for deployment readiness. Assess infrastructure, security, scalability, and provide specific recommendations for cloud deployment."
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$DEPLOYMENT_PROMPT" | \
    sed "s/{cloud_provider}/$CLOUD_PROVIDER/g" | \
    sed "s/{environment}/$ENVIRONMENT/g" | \
    sed "s/{deployment_type}/$DEPLOYMENT_TYPE/g" | \
    sed "s/{security_level}/$SECURITY_LEVEL/g")

# Create comprehensive input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Deployment Context:
- Cloud Provider: $CLOUD_PROVIDER
- Target Environment: $ENVIRONMENT  
- Deployment Type: $DEPLOYMENT_TYPE
- Security Level: $SECURITY_LEVEL
- Analysis Depth: $ANALYSIS_DEPTH
- Current Branch: $CURRENT_BRANCH
- Commit Hash: $COMMIT_HASH

Application Overview:
$(if [[ -f "README.md" ]]; then head -30 "README.md"; else echo "No README.md found"; fi)

Infrastructure Files:
Docker Files Found: $(wc -l < "$TEMP_DIR/docker_files.txt" 2>/dev/null || echo "0")
$DOCKERFILE_CONTENT

Terraform Files Found: $(wc -l < "$TEMP_DIR/terraform_files.txt" 2>/dev/null || echo "0")  
$TERRAFORM_SUMMARY

Kubernetes/Helm Files Found: $(wc -l < "$TEMP_DIR/k8s_files.txt" 2>/dev/null || echo "0")
$K8S_SUMMARY

Dependencies and Configuration:
$PACKAGE_SUMMARY

Configuration Files:
$(if [[ -s "$TEMP_DIR/config_files.txt" ]]; then cat "$TEMP_DIR/config_files.txt" | head -10; else echo "No config files found"; fi)

CI/CD Integration:
$(if [[ -s "$TEMP_DIR/cicd_files.txt" ]]; then cat "$TEMP_DIR/cicd_files.txt"; else echo "No CI/CD files found"; fi)

Recent Deployment-Related Changes:
$(cat "$TEMP_DIR/recent_deployment_changes.txt")

Current Repository Status:
$(cat "$TEMP_DIR/git_status.txt" | head -10)

Project Context:
$(if [[ -f "CLAUDE.md" ]]; then head -50 "CLAUDE.md"; fi)
EOF

echo "🤖 Analyzing deployment readiness with Claude..."

# Analyze with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_deployment_analysis.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_deployment_analysis.json" ]]; then
    echo "❌ Error: Claude did not generate deployment analysis"
    exit 1
fi

echo "✅ Claude deployment analysis complete"

# Extract analysis from Claude's response
ANALYSIS_CONTENT=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_deployment_analysis.json")

# Parse specific sections if available
READINESS_SCORE=$(echo "$ANALYSIS_CONTENT" | grep -oE 'readiness.*[0-9]+%' | head -1 || echo "Not assessed")
SECURITY_ASSESSMENT=$(echo "$ANALYSIS_CONTENT" | sed -n '/[Ss]ecurity/,/[Rr]ecommendation/p' | head -10 || echo "See full analysis")
KEY_RECOMMENDATIONS=$(echo "$ANALYSIS_CONTENT" | grep -A 5 -i "recommend\|action\|next step" | head -15 || echo "See full analysis")

# Count deployment artifacts
DOCKER_COUNT=$(wc -l < "$TEMP_DIR/docker_files.txt" 2>/dev/null || echo "0")
TERRAFORM_COUNT=$(wc -l < "$TEMP_DIR/terraform_files.txt" 2>/dev/null || echo "0")
K8S_COUNT=$(wc -l < "$TEMP_DIR/k8s_files.txt" 2>/dev/null || echo "0")
CONFIG_COUNT=$(wc -l < "$TEMP_DIR/config_files.txt" 2>/dev/null || echo "0")

# Create deployment analysis report
cat > "$TEMP_DIR/deployment_analysis_report.md" << EOF
# Deployment Readiness Analysis Report

## Executive Summary
- **Analyzed at**: $(date)
- **Cloud Provider**: $CLOUD_PROVIDER
- **Target Environment**: $ENVIRONMENT
- **Deployment Type**: $DEPLOYMENT_TYPE
- **Repository**: $(git remote get-url origin 2>/dev/null || echo "Local repository")
- **Branch**: $CURRENT_BRANCH
- **Commit**: $COMMIT_HASH

## Deployment Artifacts Summary
- **Docker files**: $DOCKER_COUNT
- **Terraform files**: $TERRAFORM_COUNT  
- **Kubernetes/Helm files**: $K8S_COUNT
- **Configuration files**: $CONFIG_COUNT

## Readiness Assessment
$READINESS_SCORE

## Security Assessment
$SECURITY_ASSESSMENT

## Key Recommendations
$KEY_RECOMMENDATIONS

## Claude Analysis
$ANALYSIS_CONTENT

## Infrastructure Inventory
### Docker Configuration
\`\`\`
$(head -10 "$TEMP_DIR/docker_files.txt" 2>/dev/null || echo "No Docker files found")
\`\`\`

### Terraform Configuration  
\`\`\`
$(head -10 "$TEMP_DIR/terraform_files.txt" 2>/dev/null || echo "No Terraform files found")
\`\`\`

### Kubernetes Configuration
\`\`\`
$(head -10 "$TEMP_DIR/k8s_files.txt" 2>/dev/null || echo "No Kubernetes files found")
\`\`\`

### Configuration Files
\`\`\`
$(cat "$TEMP_DIR/config_files.txt" 2>/dev/null || echo "No config files found")
\`\`\`

## Recent Changes
\`\`\`
$(cat "$TEMP_DIR/recent_deployment_changes.txt")
\`\`\`

## Next Steps
1. Review Claude's specific recommendations above
2. Address any security concerns identified
3. Validate infrastructure configurations
4. Plan deployment strategy based on analysis
5. Run infrastructure validation before deployment
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../deployment_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/deployment_analysis_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_deployment_analysis.json" "$RESULTS_DIR/"

echo "📄 Deployment analysis report saved to: $RESULTS_DIR/deployment_analysis_report.md"
echo "✨ Deployment analysis complete!"

# Determine overall deployment readiness
DEPLOYMENT_READY="pending"
if echo "$ANALYSIS_CONTENT" | grep -q -i "ready.*deploy"; then
    DEPLOYMENT_READY="ready"
elif echo "$ANALYSIS_CONTENT" | grep -q -i "not ready\|block\|critical"; then
    DEPLOYMENT_READY="blocked"
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "analysis_complete=true" >> "$GITHUB_OUTPUT"
    echo "deployment_ready=$DEPLOYMENT_READY" >> "$GITHUB_OUTPUT"
    echo "docker_files=$DOCKER_COUNT" >> "$GITHUB_OUTPUT"
    echo "terraform_files=$TERRAFORM_COUNT" >> "$GITHUB_OUTPUT"
    echo "k8s_files=$K8S_COUNT" >> "$GITHUB_OUTPUT"
    echo "readiness_score=$READINESS_SCORE" >> "$GITHUB_OUTPUT"
    echo "cloud_provider=$CLOUD_PROVIDER" >> "$GITHUB_OUTPUT"
    echo "environment=$ENVIRONMENT" >> "$GITHUB_OUTPUT"
    echo "analysis_report_path=$RESULTS_DIR/deployment_analysis_report.md" >> "$GITHUB_OUTPUT"
fi