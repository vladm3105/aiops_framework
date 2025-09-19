#!/bin/bash

# Claude Security Scanner Script
# Security review for deployment artifacts using Claude Code CLI

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$CLAUDE_DIR/configs/deployment-config.json"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
TEMP_DIR="/tmp/claude-security-scan-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🔒 Claude Security Scanner - Starting security review for deployment..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude CLI not found. Please install Claude Code CLI"
    exit 1
fi

# Load configuration
SCAN_TYPE="${1:-comprehensive}"
ENVIRONMENT="${2:-production}"
COMPLIANCE_LEVEL="${3:-high}"

if [[ -f "$CONFIG_FILE" ]]; then
    CLAUDE_MAX_TURNS=$(jq -r '.claude_settings.max_turns' "$CONFIG_FILE" 2>/dev/null || echo "3")
    SECURITY_DEPTH=$(jq -r '.security_scan.depth' "$CONFIG_FILE" 2>/dev/null || echo "deep")
    VULNERABILITY_THRESHOLD=$(jq -r '.security_scan.vulnerability_threshold' "$CONFIG_FILE" 2>/dev/null || echo "medium")
else
    echo "⚠️  Warning: Deployment config file not found, using defaults"
    CLAUDE_MAX_TURNS="3"
    SECURITY_DEPTH="deep"
    VULNERABILITY_THRESHOLD="medium"
fi

echo "🎯 Security scan parameters: Type=$SCAN_TYPE, Environment=$ENVIRONMENT, Compliance=$COMPLIANCE_LEVEL"

# Run security scans with available tools
echo "🔍 Running automated security scans..."

# Python security scanning
PYTHON_SECURITY=""
if [[ -f "requirements.txt" ]] || find . -name "*.py" | head -1 | grep -q .; then
    echo "  Scanning Python dependencies..."
    
    if command -v bandit &> /dev/null && find . -name "*.py" | head -1 | grep -q .; then
        bandit -r . -f json -o "$TEMP_DIR/bandit_results.json" 2>/dev/null || true
        if [[ -f "$TEMP_DIR/bandit_results.json" ]]; then
            PYTHON_SECURITY=$(jq -r '.results[] | "- \(.test_name): \(.issue_text) in \(.filename):\(.line_number)"' "$TEMP_DIR/bandit_results.json" 2>/dev/null | head -10 || echo "Bandit scan completed")
        fi
    fi
    
    if command -v safety &> /dev/null && [[ -f "requirements.txt" ]]; then
        safety check --json > "$TEMP_DIR/safety_results.json" 2>/dev/null || true
        if [[ -f "$TEMP_DIR/safety_results.json" ]]; then
            SAFETY_RESULTS=$(jq -r '.[] | "- \(.advisory): \(.package_name) \(.installed_version)"' "$TEMP_DIR/safety_results.json" 2>/dev/null | head -10 || echo "Safety scan completed")
            PYTHON_SECURITY="$PYTHON_SECURITY\n$SAFETY_RESULTS"
        fi
    fi
    
    if [[ -z "$PYTHON_SECURITY" ]]; then
        PYTHON_SECURITY="Python files detected but security tools not available"
    fi
fi

# Node.js security scanning
NODE_SECURITY=""
if [[ -f "package.json" ]] || find . -name "*.js" -o -name "*.ts" | head -1 | grep -q .; then
    echo "  Scanning Node.js dependencies..."
    
    if command -v npm &> /dev/null && [[ -f "package.json" ]]; then
        npm audit --json > "$TEMP_DIR/npm_audit.json" 2>/dev/null || true
        if [[ -f "$TEMP_DIR/npm_audit.json" ]]; then
            NODE_SECURITY=$(jq -r '.vulnerabilities | to_entries[] | "- \(.key): \(.value.severity) severity vulnerability"' "$TEMP_DIR/npm_audit.json" 2>/dev/null | head -10 || echo "npm audit completed")
        fi
    fi
    
    if [[ -z "$NODE_SECURITY" ]]; then
        NODE_SECURITY="Node.js files detected but npm audit not available"
    fi
fi

# Docker security scanning
DOCKER_SECURITY=""
if find . -name "Dockerfile*" | head -1 | grep -q .; then
    echo "  Analyzing Docker security..."
    
    # Basic Dockerfile security checks
    DOCKER_ISSUES=""
    find . -name "Dockerfile*" | while read -r dockerfile; do
        if [[ -f "$dockerfile" ]]; then
            # Check for security issues
            if grep -q "^USER root" "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- Running as root user in $dockerfile"
            fi
            if grep -q "RUN.*sudo" "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- Using sudo in $dockerfile"
            fi
            if grep -q "ADD.*http" "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- Downloading files via ADD from internet in $dockerfile"
            fi
            if ! grep -q "^USER " "$dockerfile"; then
                DOCKER_ISSUES="$DOCKER_ISSUES\n- No USER directive specified in $dockerfile (runs as root)"
            fi
        fi
    done
    
    if [[ -n "$DOCKER_ISSUES" ]]; then
        DOCKER_SECURITY="Security issues identified:$DOCKER_ISSUES"
    else
        DOCKER_SECURITY="No obvious security issues found in Docker configuration"
    fi
fi

# Infrastructure security scanning
INFRA_SECURITY=""
if find . -name "*.tf" | head -1 | grep -q .; then
    echo "  Analyzing Terraform security..."
    
    # Basic Terraform security checks
    TERRAFORM_ISSUES=""
    find . -name "*.tf" | while read -r tffile; do
        if [[ -f "$tffile" ]]; then
            # Check for common security misconfigurations
            if grep -q "public_subnets.*0.0.0.0/0\|security_group.*0.0.0.0/0" "$tffile"; then
                TERRAFORM_ISSUES="$TERRAFORM_ISSUES\n- Public access (0.0.0.0/0) found in $tffile"
            fi
            if grep -q "skip_final_snapshot.*true" "$tffile"; then
                TERRAFORM_ISSUES="$TERRAFORM_ISSUES\n- Skip final snapshot enabled in $tffile (data loss risk)"
            fi
            if grep -q "versioning.*false\|versioning.*disabled" "$tffile"; then
                TERRAFORM_ISSUES="$TERRAFORM_ISSUES\n- Versioning disabled in $tffile"
            fi
        fi
    done
    
    if [[ -n "$TERRAFORM_ISSUES" ]]; then
        INFRA_SECURITY="Infrastructure security issues:$TERRAFORM_ISSUES"
    else
        INFRA_SECURITY="No obvious infrastructure security issues found"
    fi
fi

# Kubernetes security scanning
K8S_SECURITY=""
if find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes)" | head -1 | grep -q .; then
    echo "  Analyzing Kubernetes security..."
    
    K8S_ISSUES=""
    find . -name "*.yml" -o -name "*.yaml" | grep -E "(k8s|kubernetes)" | while read -r k8sfile; do
        if [[ -f "$k8sfile" ]]; then
            # Check for security issues
            if grep -q "privileged.*true" "$k8sfile"; then
                K8S_ISSUES="$K8S_ISSUES\n- Privileged container found in $k8sfile"
            fi
            if grep -q "runAsUser.*0\|runAsRoot.*true" "$k8sfile"; then
                K8S_ISSUES="$K8S_ISSUES\n- Running as root user in $k8sfile"
            fi
            if grep -q "hostNetwork.*true\|hostPID.*true" "$k8sfile"; then
                K8S_ISSUES="$K8S_ISSUES\n- Host network/PID access in $k8sfile"
            fi
        fi
    done
    
    if [[ -n "$K8S_ISSUES" ]]; then
        K8S_SECURITY="Kubernetes security issues:$K8S_ISSUES"
    else
        K8S_SECURITY="No obvious Kubernetes security issues found"
    fi
fi

# Scan for sensitive data exposure
echo "  Scanning for sensitive data exposure..."
SENSITIVE_DATA=""
SENSITIVE_PATTERNS=(
    "password.*="
    "secret.*="
    "api[_-]?key.*="
    "token.*="
    "private[_-]?key"
    "-----BEGIN.*PRIVATE.*KEY-----"
)

for pattern in "${SENSITIVE_PATTERNS[@]}"; do
    if git ls-files | xargs grep -l -i "$pattern" 2>/dev/null | head -1 | grep -q .; then
        FILES=$(git ls-files | xargs grep -l -i "$pattern" 2>/dev/null | head -3 | paste -sd "," -)
        SENSITIVE_DATA="$SENSITIVE_DATA\n- Potential sensitive data pattern '$pattern' found in: $FILES"
    fi
done

if [[ -z "$SENSITIVE_DATA" ]]; then
    SENSITIVE_DATA="No obvious sensitive data patterns found"
fi

# Check for environment files
ENV_FILES_SECURITY=""
if find . -name "*.env*" -o -name ".env" | head -1 | grep -q .; then
    ENV_FILES=$(find . -name "*.env*" -o -name ".env" | head -5 | paste -sd "," -)
    if git ls-files | grep -E "\.env|\.env\." | head -1 | grep -q .; then
        ENV_FILES_SECURITY="⚠️  Environment files tracked in Git: $ENV_FILES"
    else
        ENV_FILES_SECURITY="✅ Environment files found but not tracked in Git"
    fi
fi

# Load security review prompt
SECURITY_PROMPT=""
if [[ -f "$PROMPTS_DIR/security-review.txt" ]]; then
    SECURITY_PROMPT=$(cat "$PROMPTS_DIR/security-review.txt")
else
    # Fallback prompt
    SECURITY_PROMPT="You are a senior security engineer conducting a comprehensive security review for cloud deployment. Analyze the security scan results, identify vulnerabilities, assess risks, and provide specific remediation recommendations."
fi

# Substitute variables in prompt
FINAL_PROMPT=$(echo "$SECURITY_PROMPT" | \
    sed "s/{scan_type}/$SCAN_TYPE/g" | \
    sed "s/{environment}/$ENVIRONMENT/g" | \
    sed "s/{compliance_level}/$COMPLIANCE_LEVEL/g" | \
    sed "s/{security_depth}/$SECURITY_DEPTH/g")

# Create comprehensive input for Claude
cat > "$TEMP_DIR/claude_input.txt" << EOF
$FINAL_PROMPT

Security Scan Context:
- Scan Type: $SCAN_TYPE
- Environment: $ENVIRONMENT ($(if [[ "$ENVIRONMENT" == "production" ]]; then echo "HIGH SECURITY REQUIRED"; else echo "Standard security"; fi))
- Compliance Level: $COMPLIANCE_LEVEL
- Security Depth: $SECURITY_DEPTH
- Vulnerability Threshold: $VULNERABILITY_THRESHOLD

Automated Security Scan Results:

Python Security Analysis:
$(echo -e "$PYTHON_SECURITY" | head -20)

Node.js Security Analysis:
$(echo -e "$NODE_SECURITY" | head -20)

Docker Security Analysis:
$(echo -e "$DOCKER_SECURITY")

Infrastructure Security Analysis:
$(echo -e "$INFRA_SECURITY")

Kubernetes Security Analysis:
$(echo -e "$K8S_SECURITY")

Sensitive Data Exposure Check:
$(echo -e "$SENSITIVE_DATA")

Environment Files Security:
$ENV_FILES_SECURITY

Application Configuration Files:
$(find . -name "*.conf" -o -name "config.*" -o -name "settings.*" | head -10)

Network and Service Configuration:
$(find . -name "*nginx*" -o -name "*apache*" -o -name "*proxy*" | head -5)

Database Configuration:
$(find . -name "*database*" -o -name "*db*" | grep -E "\.(yml|yaml|json|conf)$" | head -5)

Project Context:
$(if [[ -f "CLAUDE.md" ]]; then head -40 "CLAUDE.md"; fi)
EOF

echo "🤖 Conducting security review with Claude..."

# Analyze security with Claude CLI
claude -p "$(cat "$TEMP_DIR/claude_input.txt")" \
    --output-format "json" \
    --max-turns "$CLAUDE_MAX_TURNS" > "$TEMP_DIR/claude_security_analysis.json"

# Check if Claude generated valid output
if [[ ! -s "$TEMP_DIR/claude_security_analysis.json" ]]; then
    echo "❌ Error: Claude did not generate security analysis"
    exit 1
fi

echo "✅ Claude security analysis complete"

# Extract analysis from Claude's response
SECURITY_ANALYSIS=$(jq -r '.content // .response // .text // .' "$TEMP_DIR/claude_security_analysis.json")

# Parse specific sections if available
HIGH_RISK_ISSUES=$(echo "$SECURITY_ANALYSIS" | grep -A 10 -i "high.*risk\|critical\|severe" | head -15 || echo "No high-risk issues identified")
REMEDIATION_STEPS=$(echo "$SECURITY_ANALYSIS" | grep -A 15 -i "remediat\|fix\|action\|step" | head -20 || echo "See full analysis for remediation")
COMPLIANCE_ASSESSMENT=$(echo "$SECURITY_ANALYSIS" | grep -A 10 -i "complianc\|regulat\|standard" | head -15 || echo "See full analysis")

# Count security findings
PYTHON_ISSUES=$(echo -e "$PYTHON_SECURITY" | grep -c "^-" 2>/dev/null || echo "0")
NODE_ISSUES=$(echo -e "$NODE_SECURITY" | grep -c "^-" 2>/dev/null || echo "0")
DOCKER_ISSUES=$(echo -e "$DOCKER_SECURITY" | grep -c "^-" 2>/dev/null || echo "0")
SENSITIVE_FINDINGS=$(echo -e "$SENSITIVE_DATA" | grep -c "^-" 2>/dev/null || echo "0")

# Create security scan report
cat > "$TEMP_DIR/security_scan_report.md" << EOF
# Security Scan Report

## Executive Summary
- **Scanned at**: $(date)
- **Scan Type**: $SCAN_TYPE
- **Environment**: $ENVIRONMENT
- **Compliance Level**: $COMPLIANCE_LEVEL
- **Overall Security Status**: $(if [[ "$HIGH_RISK_ISSUES" != "No high-risk issues identified" ]]; then echo "⚠️  Issues Found"; else echo "✅ No Critical Issues"; fi)

## Security Findings Summary
- **Python security issues**: $PYTHON_ISSUES
- **Node.js security issues**: $NODE_ISSUES
- **Docker security issues**: $DOCKER_ISSUES
- **Sensitive data findings**: $SENSITIVE_FINDINGS

## High-Risk Issues
$HIGH_RISK_ISSUES

## Compliance Assessment
$COMPLIANCE_ASSESSMENT

## Remediation Steps
$REMEDIATION_STEPS

## Detailed Security Analysis

### Python Security
$(echo -e "$PYTHON_SECURITY")

### Node.js Security
$(echo -e "$NODE_SECURITY")

### Docker Security
$(echo -e "$DOCKER_SECURITY")

### Infrastructure Security
$(echo -e "$INFRA_SECURITY")

### Kubernetes Security
$(echo -e "$K8S_SECURITY")

### Sensitive Data Exposure
$(echo -e "$SENSITIVE_DATA")

### Environment Files
$ENV_FILES_SECURITY

## Claude Security Analysis
$SECURITY_ANALYSIS

## Next Steps
1. Address all high-risk security issues immediately
2. Implement recommended security controls
3. Review and update security configurations
4. Test security fixes thoroughly
5. Consider additional security tools and monitoring

## Security Checklist
- [ ] No hardcoded secrets or passwords
- [ ] Proper authentication and authorization
- [ ] Secure communication (HTTPS/TLS)
- [ ] Input validation and sanitization
- [ ] Secure container configurations
- [ ] Network security controls
- [ ] Access controls and least privilege
- [ ] Security monitoring and logging
- [ ] Compliance requirements met
- [ ] Security testing completed
EOF

# Save outputs to shared location
RESULTS_DIR="$CLAUDE_DIR/../../../deployment_results"
mkdir -p "$RESULTS_DIR"

cp "$TEMP_DIR/security_scan_report.md" "$RESULTS_DIR/"
cp "$TEMP_DIR/claude_security_analysis.json" "$RESULTS_DIR/"

# Copy scan results if available
[[ -f "$TEMP_DIR/bandit_results.json" ]] && cp "$TEMP_DIR/bandit_results.json" "$RESULTS_DIR/"
[[ -f "$TEMP_DIR/safety_results.json" ]] && cp "$TEMP_DIR/safety_results.json" "$RESULTS_DIR/"
[[ -f "$TEMP_DIR/npm_audit.json" ]] && cp "$TEMP_DIR/npm_audit.json" "$RESULTS_DIR/"

echo "📄 Security scan report saved to: $RESULTS_DIR/security_scan_report.md"
echo "✨ Security scan complete!"

# Determine security status
SECURITY_STATUS="pass"
TOTAL_ISSUES=$((PYTHON_ISSUES + NODE_ISSUES + DOCKER_ISSUES + SENSITIVE_FINDINGS))

if echo "$SECURITY_ANALYSIS" | grep -q -i "high.*risk\|critical\|severe"; then
    SECURITY_STATUS="fail"
elif [[ $TOTAL_ISSUES -gt 5 ]] || echo "$SECURITY_ANALYSIS" | grep -q -i "medium.*risk\|warning"; then
    SECURITY_STATUS="warning"
fi

# Output summary for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "security_scan_complete=true" >> "$GITHUB_OUTPUT"
    echo "security_status=$SECURITY_STATUS" >> "$GITHUB_OUTPUT"
    echo "total_security_issues=$TOTAL_ISSUES" >> "$GITHUB_OUTPUT"
    echo "python_issues=$PYTHON_ISSUES" >> "$GITHUB_OUTPUT"
    echo "node_issues=$NODE_ISSUES" >> "$GITHUB_OUTPUT"
    echo "docker_issues=$DOCKER_ISSUES" >> "$GITHUB_OUTPUT"
    echo "sensitive_findings=$SENSITIVE_FINDINGS" >> "$GITHUB_OUTPUT"
    echo "security_report_path=$RESULTS_DIR/security_scan_report.md" >> "$GITHUB_OUTPUT"
fi

# Exit with appropriate status
if [[ "$SECURITY_STATUS" == "fail" ]]; then
    echo "❌ Security scan failed - critical issues found"
    exit 1
else
    echo "✅ Security scan completed with status: $SECURITY_STATUS"
    exit 0
fi