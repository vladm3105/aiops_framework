#!/bin/bash

# Claude Deployment Strategy Script
# Generate deployment strategies and rollback plans using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/deployment-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-deployment-strategy-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "📋 Claude Deployment Strategy - Generating deployment strategy and rollback plan..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
CLOUD_PROVIDER="${1:-auto}"
DEPLOYMENT_TYPE="${2:-standard}"
ENVIRONMENT="${3:-staging}"
STRATEGY_TYPE="${4:-blue-green}"

if [[ -f "$CONFIG_FILE" ]]; then
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
    RISK_TOLERANCE=$(jq -r '.deployment_strategy.risk_tolerance' "$CONFIG_FILE" 2>/dev/null || echo "low")
    DOWNTIME_TOLERANCE=$(jq -r '.deployment_strategy.downtime_tolerance' "$CONFIG_FILE" 2>/dev/null || echo "zero")
else
    echo "⚠️  Warning: Deployment config file not found, using defaults"
    CLAUDE_MAX_TURNS="3"
    RISK_TOLERANCE="low"
    DOWNTIME_TOLERANCE="zero"
fi

echo "🎯 Strategy parameters: Provider=$CLOUD_PROVIDER, Type=$DEPLOYMENT_TYPE, Environment=$ENVIRONMENT, Strategy=$STRATEGY_TYPE"

# Gather deployment context
echo "📊 Gathering deployment context..."

# Analyze application architecture
ARCHITECTURE_INFO=""
if [[ -f "docker-compose.yml" ]]; then
    ARCHITECTURE_INFO="$ARCHITECTURE_INFO\nMulti-container application (docker-compose detected)"
    SERVICES=$(grep "^  [a-zA-Z]" docker-compose.yml | sed 's/://g' | xargs | tr ' ' ',' || echo "unknown")
    ARCHITECTURE_INFO="$ARCHITECTURE_INFO\nServices: $SERVICES"
fi

if find . -name "*.tf" | head -1 | grep -q .; then
    ARCHITECTURE_INFO="$ARCHITECTURE_INFO\nInfrastructure as Code (Terraform detected)"
fi

if find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes)" | head -1 | grep -q .; then
    ARCHITECTURE_INFO="$ARCHITECTURE_INFO\nKubernetes deployment detected"
    K8S_RESOURCES=$(find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes)" | xargs grep "^kind:" | cut -d: -f2 | sort | uniq | xargs | tr ' ' ',' || echo "unknown")
    ARCHITECTURE_INFO="$ARCHITECTURE_INFO\nKubernetes resources: $K8S_RESOURCES"
fi

if [[ -z "$ARCHITECTURE_INFO" ]]; then
    ARCHITECTURE_INFO="Simple application architecture (no orchestration detected)"
fi

# Analyze dependencies
DEPENDENCY_INFO=""
if [[ -f "requirements.txt" ]]; then
    DEP_COUNT=$(wc -l < requirements.txt)
    DEPENDENCY_INFO="$DEPENDENCY_INFO\nPython dependencies: $DEP_COUNT packages"
fi

if [[ -f "package.json" ]]; then
    DEP_COUNT=$(jq '.dependencies | length' package.json 2>/dev/null || echo "unknown")
    DEPENDENCY_INFO="$DEPENDENCY_INFO\nNode.js dependencies: $DEP_COUNT packages"
fi

if [[ -f "go.mod" ]]; then
    DEPENDENCY_INFO="$DEPENDENCY_INFO\nGo module detected"
fi

# Analyze database dependencies
DATABASE_INFO=""
if grep -r -i "database\|postgres\|mysql\|redis\|mongodb" . --include="*.yml" --include="*.yaml" --include="*.json" --include="*.env*" 2>/dev/null | head -3 | grep -q .; then
    DATABASE_INFO="Database dependencies detected"
    DB_TYPES=$(grep -r -i "postgres\|mysql\|redis\|mongodb" . --include="*.yml" --include="*.yaml" --include="*.json" 2>/dev/null | grep -oiE "postgres|mysql|redis|mongodb" | sort | uniq | xargs | tr ' ' ',' || echo "unknown")
    DATABASE_INFO="$DATABASE_INFO (Types: $DB_TYPES)"
fi

# Check for migration scripts
MIGRATION_INFO=""
if find . -name "*migration*" -o -name "*migrate*" | head -1 | grep -q .; then
    MIGRATION_COUNT=$(find . -name "*migration*" -o -name "*migrate*" | wc -l)
    MIGRATION_INFO="Database migrations detected ($MIGRATION_COUNT files)"
fi

# Analyze external service dependencies
EXTERNAL_DEPS=""
if grep -r -E "http://|https://|api\.|service\." . --include="*.yml" --include="*.yaml" --include="*.json" --include="*.env*" 2>/dev/null | head -5 | grep -q .; then
    EXTERNAL_DEPS="External service dependencies detected"
fi

# Check for health checks and monitoring
HEALTH_CHECK_INFO=""
if grep -r -E "health|/health|healthcheck" . --include="*.yml" --include="*.yaml" --include="*.json" --include="*.py" --include="*.js" --include="*.go" 2>/dev/null | head -1 | grep -q .; then
    HEALTH_CHECK_INFO="Health check endpoints detected"
fi

# Analyze current deployment setup
CURRENT_DEPLOYMENT=""
if [[ -f ".github/workflows/deploy.yml" ]] || find .github/workflows -name "*deploy*" 2>/dev/null | head -1 | grep -q .; then
    CURRENT_DEPLOYMENT="$CURRENT_DEPLOYMENT\nGitHub Actions deployment workflow exists"
fi

if [[ -f "Dockerfile" ]]; then
    CURRENT_DEPLOYMENT="$CURRENT_DEPLOYMENT\nContainer-based deployment (Docker)"
fi

# Get environment-specific information
ENV_CONFIG=""
case $ENVIRONMENT in
    "production")
        ENV_CONFIG="High availability and zero-downtime requirements"
        ;;
    "staging")
        ENV_CONFIG="Staging environment - testing and validation focus"
        ;;
    "development")
        ENV_CONFIG="Development environment - rapid deployment and testing"
        ;;
    *)
        ENV_CONFIG="Custom environment deployment"
        ;;
esac

# Load deployment strategy prompt
STRATEGY_PROMPT=""
if [[ -f "$PROMPTS_DIR/deployment-strategy.txt" ]]; then
    STRATEGY_PROMPT=$(cat "$PROMPTS_DIR/deployment-strategy.txt")
else
    # Fallback prompt
    STRATEGY_PROMPT="You are a senior DevOps engineer and deployment specialist. Create a comprehensive deployment strategy including step-by-step deployment plan, rollback procedures, monitoring setup, and risk mitigation strategies."
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$STRATEGY_PROMPT" | \
    sed "s/{cloud_provider}/$CLOUD_PROVIDER/g" | \
    sed "s/{deployment_type}/$DEPLOYMENT_TYPE/g" | \
    sed "s/{environment}/$ENVIRONMENT/g" | \
    sed "s/{strategy_type}/$STRATEGY_TYPE/g" | \
    sed "s/{risk_tolerance}/$RISK_TOLERANCE/g" | \
    sed "s/{downtime_tolerance}/$DOWNTIME_TOLERANCE/g")

# Create comprehensive input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Deployment Strategy Context:
- Cloud Provider: $CLOUD_PROVIDER
- Deployment Type: $DEPLOYMENT_TYPE
- Environment: $ENVIRONMENT
- Strategy Type: $STRATEGY_TYPE
- Risk Tolerance: $RISK_TOLERANCE
- Downtime Tolerance: $DOWNTIME_TOLERANCE

Application Architecture:
$(echo -e "$ARCHITECTURE_INFO")

Dependency Analysis:
$(echo -e "$DEPENDENCY_INFO")

Database Information:
$DATABASE_INFO
$MIGRATION_INFO

External Dependencies:
$EXTERNAL_DEPS

Monitoring and Health Checks:
$HEALTH_CHECK_INFO

Current Deployment Setup:
$(echo -e "$CURRENT_DEPLOYMENT")

Environment Configuration:
$ENV_CONFIG

Infrastructure Files Present:
- Dockerfile: $(if [[ -f "Dockerfile" ]]; then echo "Yes"; else echo "No"; fi)
- Docker Compose: $(if [[ -f "docker-compose.yml" ]]; then echo "Yes"; else echo "No"; fi)
- Terraform: $(if find . -name "*.tf" | head -1 | grep -q .; then echo "Yes"; else echo "No"; fi)
- Kubernetes: $(if find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes)" | head -1 | grep -q .; then echo "Yes"; else echo "No"; fi)

Recent Changes Impact:
$(git log --oneline -5 --grep="deploy\|release\|breaking" 2>/dev/null || echo "No recent deployment-related changes")

Project Context:
$(if [[ -f "CLAUDE.md" ]]; then head -40 "CLAUDE.md"; fi)

Deployment History (if available):
$(git log --oneline --grep="deploy\|release" -10 2>/dev/null | head -5 || echo "No deployment history available")
EOF

echo "🤖 Generating deployment strategy with Claude..."

# Generate strategy with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_strategy.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_strategy.json" ]]; then
    echo "❌ Error: Claude did not generate deployment strategy"
    exit 1
fi

echo "✅ Claude deployment strategy generation complete"

# Extract strategy from Claude's response
STRATEGY_CONTENT=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_strategy.json")

# Parse specific sections if available
DEPLOYMENT_STEPS=$(echo "$STRATEGY_CONTENT" | sed -n '/[Dd]eployment [Ss]teps\|[Pp]rocedure/,/[Rr]ollback\|[Mm]onitoring/p' | head -20 || echo "See full strategy")
ROLLBACK_PLAN=$(echo "$STRATEGY_CONTENT" | sed -n '/[Rr]ollback\|[Rr]ecovery/,/[Mm]onitoring\|[Tt]esting/p' | head -15 || echo "See full strategy")
RISK_MITIGATION=$(echo "$STRATEGY_CONTENT" | grep -A 10 -i "risk\|mitigation\|contingency" | head -15 || echo "See full strategy")

# Create timestamp and deployment info
DEPLOYMENT_ID="deploy-$(date +%Y%m%d-%H%M%S)"
CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Create deployment strategy report
cat > "$TEMP_DIR/deployment_strategy_report.md" << EOF
# Deployment Strategy Report

## Deployment Overview
- **Generated at**: $(date)
- **Deployment ID**: $DEPLOYMENT_ID
- **Cloud Provider**: $CLOUD_PROVIDER
- **Environment**: $ENVIRONMENT
- **Strategy Type**: $STRATEGY_TYPE
- **Commit Hash**: $CURRENT_COMMIT

## Deployment Parameters
- **Risk Tolerance**: $RISK_TOLERANCE
- **Downtime Tolerance**: $DOWNTIME_TOLERANCE
- **Deployment Type**: $DEPLOYMENT_TYPE

## Application Analysis
### Architecture
$(echo -e "$ARCHITECTURE_INFO")

### Dependencies
$(echo -e "$DEPENDENCY_INFO")

### Database & Migrations
$DATABASE_INFO
$MIGRATION_INFO

### External Dependencies
$EXTERNAL_DEPS

## Deployment Strategy

### Pre-deployment Checklist
- [ ] All tests passing
- [ ] Security scan completed
- [ ] Infrastructure validated
- [ ] Backup procedures verified
- [ ] Monitoring and alerting configured
- [ ] Rollback plan tested
- [ ] Team notifications sent

### Deployment Steps
$DEPLOYMENT_STEPS

### Rollback Plan
$ROLLBACK_PLAN

### Risk Mitigation
$RISK_MITIGATION

## Claude Strategy Analysis
$STRATEGY_CONTENT

## Post-Deployment Validation
1. Health check endpoints responding
2. Application metrics within normal ranges
3. Database connections functional
4. External service integrations working
5. User functionality verified
6. Performance metrics acceptable
7. Security controls active
8. Monitoring and alerting functional

## Emergency Contacts
- DevOps Team: [Configure in deployment-config.json]
- On-call Engineer: [Configure in deployment-config.json]
- Security Team: [Configure in deployment-config.json]

## Deployment Commands
\`\`\`bash
# Example deployment commands (customize based on strategy)
# These will be generated based on your specific setup

# Pre-deployment
./scripts/pre-deployment-checks.sh

# Deploy
$(if [[ "$STRATEGY_TYPE" == "blue-green" ]]; then
    echo "# Blue-green deployment"
    echo "# 1. Deploy to green environment"
    echo "# 2. Test green environment"
    echo "# 3. Switch traffic to green"
    echo "# 4. Monitor and validate"
elif [[ "$STRATEGY_TYPE" == "rolling" ]]; then
    echo "# Rolling deployment"
    echo "# 1. Deploy to subset of instances"
    echo "# 2. Validate partial deployment"
    echo "# 3. Continue rolling update"
    echo "# 4. Complete deployment"
else
    echo "# Standard deployment"
    echo "# Follow generated deployment steps above"
fi)

# Post-deployment
./scripts/post-deployment-validation.sh
\`\`\`

## Monitoring and Alerts
- Application health: $(if [[ -n "$HEALTH_CHECK_INFO" ]]; then echo "Configured"; else echo "Configure health check endpoints"; fi)
- Infrastructure monitoring: Configure based on cloud provider
- Performance metrics: Monitor response times and throughput
- Error rates: Set up error tracking and alerting
- Security monitoring: Enable security event monitoring

---
*Deployment strategy generated by Claude Code Deployment Framework*
EOF

# Create rollback script template
cat > "$TEMP_DIR/rollback-script.sh" << 'EOF'
#!/bin/bash

# Auto-generated Rollback Script
# Generated by Claude Deployment Strategy

set -e

DEPLOYMENT_ID="${1:-latest}"
ROLLBACK_REASON="${2:-manual-rollback}"

echo "🔄 Starting rollback for deployment: $DEPLOYMENT_ID"
echo "📝 Rollback reason: $ROLLBACK_REASON"

# Add rollback steps here based on deployment strategy
# This template should be customized based on your specific deployment approach

echo "✅ Rollback completed successfully"
echo "📊 Verify application is functioning properly"
EOF

chmod +x "$TEMP_DIR/rollback-script.sh"

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../deployment_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/deployment_strategy_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_strategy.json" "$RESULTS_DIR/"
cp "$TEMP_DIR/rollback-script.sh" "$RESULTS_DIR/"

echo "📄 Deployment strategy report saved to: $RESULTS_DIR/deployment_strategy_report.md"
echo "🔄 Rollback script template saved to: $RESULTS_DIR/rollback-script.sh"
echo "✨ Deployment strategy generation complete!"

# Determine strategy complexity
STRATEGY_COMPLEXITY="standard"
if echo "$STRATEGY_CONTENT" | grep -q -i "complex\|advanced\|multi-stage"; then
    STRATEGY_COMPLEXITY="complex"
elif echo "$STRATEGY_CONTENT" | grep -q -i "simple\|straightforward\|basic"; then
    STRATEGY_COMPLEXITY="simple"
fi

# Count deployment steps
DEPLOYMENT_STEP_COUNT=$(echo "$DEPLOYMENT_STEPS" | grep -c "^[0-9]\|^-\|^\*" 2>/dev/null || echo "0")

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "strategy_complete=true" >> "$GITHUB_OUTPUT"
    echo "deployment_id=$DEPLOYMENT_ID" >> "$GITHUB_OUTPUT"
    echo "strategy_complexity=$STRATEGY_COMPLEXITY" >> "$GITHUB_OUTPUT"
    echo "deployment_steps=$DEPLOYMENT_STEP_COUNT" >> "$GITHUB_OUTPUT"
    echo "cloud_provider=$CLOUD_PROVIDER" >> "$GITHUB_OUTPUT"
    echo "environment=$ENVIRONMENT" >> "$GITHUB_OUTPUT"
    echo "strategy_type=$STRATEGY_TYPE" >> "$GITHUB_OUTPUT"
    echo "strategy_report_path=$RESULTS_DIR/deployment_strategy_report.md" >> "$GITHUB_OUTPUT"
    echo "rollback_script_path=$RESULTS_DIR/rollback-script.sh" >> "$GITHUB_OUTPUT"
fi