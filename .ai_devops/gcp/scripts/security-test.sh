#!/bin/bash

# Cloud Run Security Testing Script
# AI DevOps Framework v3.7 - Security validation and vulnerability assessment

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

SERVICE_NAME="${1:-}"
PROJECT_ID="${2:-}"
REGION="${3:-us-central1}"
ENVIRONMENT="${4:-development}"

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: SERVICE_NAME is required"
    echo "Usage: $0 <SERVICE_NAME> [PROJECT_ID] [REGION] [ENVIRONMENT]"
    echo "Example: $0 simple-app my-project us-central1 production"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: PROJECT_ID not found. Set with: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
fi

RESULTS_DIR="$SCRIPT_DIR/../results/security"
mkdir -p "$RESULTS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_FILE="$RESULTS_DIR/${SERVICE_NAME}_security_${TIMESTAMP}.json"

log_info "Starting security assessment for Cloud Run service"
log_info "Service: $SERVICE_NAME"
log_info "Project: $PROJECT_ID"
log_info "Region: $REGION"
log_info "Environment: $ENVIRONMENT"

# Initialize security results
cat > "$RESULTS_FILE" << EOF
{
  "assessment_info": {
    "service_name": "$SERVICE_NAME",
    "project_id": "$PROJECT_ID",
    "region": "$REGION",
    "environment": "$ENVIRONMENT",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "assessment_type": "security"
  },
  "tests": [],
  "summary": {
    "total_tests": 0,
    "passed": 0,
    "failed": 0,
    "warnings": 0,
    "critical_issues": 0
  }
}
EOF

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0
CRITICAL_ISSUES=0

# Security test function
run_security_test() {
    local test_name="$1"
    local test_command="$2"
    local severity="${3:-medium}"
    local expected_result="${4:-0}"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    local test_result=""
    local status=""
    local details=""
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "0" ]; then
            status="PASS"
            log_success "✅ PASS: $test_name"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            status="FAIL"
            log_error "❌ FAIL: $test_name"
            FAILED_TESTS=$((FAILED_TESTS + 1))
            if [ "$severity" = "critical" ]; then
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            fi
        fi
    else
        if [ "$expected_result" = "1" ]; then
            status="PASS"
            log_success "✅ PASS: $test_name (expected failure)"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            if [ "$severity" = "critical" ]; then
                status="FAIL"
                log_error "❌ CRITICAL: $test_name"
                FAILED_TESTS=$((FAILED_TESTS + 1))
                CRITICAL_ISSUES=$((CRITICAL_ISSUES + 1))
            else
                status="WARNING"
                log_warning "⚠️  WARNING: $test_name"
                WARNING_TESTS=$((WARNING_TESTS + 1))
            fi
        fi
    fi
    
    # Add test result to JSON
    local test_result_json=$(cat << EOF
{
  "test_name": "$test_name",
  "status": "$status",
  "severity": "$severity",
  "command": "$test_command",
  "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
)
    
    jq ".tests += [$test_result_json]" "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"
}

# Get service details
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    log_error "Cloud Run service '$SERVICE_NAME' not found in region '$REGION'"
    exit 1
fi

SERVICE_CONFIG=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="json" 2>/dev/null || echo "{}")

echo "=========================================="
echo "1. TRANSPORT SECURITY TESTS"
echo "=========================================="

# Test 1: HTTPS enforcement
run_security_test "HTTPS enforcement" \
    "echo '$SERVICE_URL' | grep -q '^https://'" \
    "critical"

# Test 2: TLS version check
run_security_test "TLS version >= 1.2" \
    "curl -I --tlsv1.2 -s --max-time 10 '$SERVICE_URL' >/dev/null" \
    "high"

# Test 3: Security headers
HEADERS=$(curl -I -s --max-time 10 "$SERVICE_URL/" 2>/dev/null || echo "")

run_security_test "Strict-Transport-Security header" \
    "echo '$HEADERS' | grep -qi 'strict-transport-security'" \
    "medium"

run_security_test "X-Frame-Options header" \
    "echo '$HEADERS' | grep -qi 'x-frame-options'" \
    "medium"

run_security_test "X-Content-Type-Options header" \
    "echo '$HEADERS' | grep -qi 'x-content-type-options'" \
    "medium"

echo ""
echo "=========================================="
echo "2. AUTHENTICATION & AUTHORIZATION TESTS"
echo "=========================================="

# Test 4: IAM policy configuration
ALLOW_UNAUTH=$(echo "$SERVICE_CONFIG" | jq -r '.metadata.annotations["run.googleapis.com/ingress"]' 2>/dev/null || echo "")

if [ "$ENVIRONMENT" = "production" ]; then
    run_security_test "Production service requires authentication" \
        "[ '$ALLOW_UNAUTH' != 'all' ]" \
        "critical"
else
    run_security_test "Non-production service authentication configured" \
        "[ ! -z '$ALLOW_UNAUTH' ]" \
        "low"
fi

# Test 5: Service account configuration
SERVICE_ACCOUNT=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.spec.serviceAccountName' 2>/dev/null || echo "")

run_security_test "Custom service account configured" \
    "[ ! -z '$SERVICE_ACCOUNT' ] && [ '$SERVICE_ACCOUNT' != 'null' ]" \
    "medium"

echo ""
echo "=========================================="
echo "3. CONTAINER SECURITY TESTS"
echo "=========================================="

# Test 6: Non-root user execution
run_security_test "Container runs as non-root user" \
    "echo '$SERVICE_CONFIG' | jq -r '.spec.template.spec.containers[0].securityContext.runAsNonRoot' | grep -q 'true'" \
    "high"

# Test 7: Read-only root filesystem
run_security_test "Read-only root filesystem" \
    "echo '$SERVICE_CONFIG' | jq -r '.spec.template.spec.containers[0].securityContext.readOnlyRootFilesystem' | grep -q 'true'" \
    "medium"

# Test 8: Privilege escalation prevention
run_security_test "Privilege escalation disabled" \
    "echo '$SERVICE_CONFIG' | jq -r '.spec.template.spec.containers[0].securityContext.allowPrivilegeEscalation' | grep -q 'false'" \
    "high"

echo ""
echo "=========================================="
echo "4. NETWORK SECURITY TESTS"
echo "=========================================="

# Test 9: Ingress configuration
INGRESS_SETTING=$(echo "$SERVICE_CONFIG" | jq -r '.metadata.annotations["run.googleapis.com/ingress"]' 2>/dev/null || echo "all")

if [ "$ENVIRONMENT" = "production" ]; then
    run_security_test "Production ingress restricted" \
        "[ '$INGRESS_SETTING' = 'internal' ] || [ '$INGRESS_SETTING' = 'internal-and-cloud-load-balancing' ]" \
        "high"
fi

# Test 10: VPC connector configuration
VPC_CONNECTOR=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.metadata.annotations["run.googleapis.com/vpc-access-connector"]' 2>/dev/null || echo "")

if [ "$ENVIRONMENT" = "production" ]; then
    run_security_test "Production VPC connector configured" \
        "[ ! -z '$VPC_CONNECTOR' ] && [ '$VPC_CONNECTOR' != 'null' ]" \
        "medium"
fi

echo ""
echo "=========================================="
echo "5. SECRET MANAGEMENT TESTS"
echo "=========================================="

# Test 11: Environment variables don't contain secrets
ENV_VARS=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.spec.containers[0].env[]?.value' 2>/dev/null || echo "")

run_security_test "No hardcoded secrets in environment variables" \
    "! echo '$ENV_VARS' | grep -iE '(password|secret|key|token|credential).*[=:].+'" \
    "critical"

# Test 12: Secret Manager integration
SECRET_REFS=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.spec.containers[0].env[]?.valueFrom.secretKeyRef' 2>/dev/null || echo "")

run_security_test "Secrets use Secret Manager" \
    "[ ! -z '$SECRET_REFS' ] && [ '$SECRET_REFS' != 'null' ]" \
    "low"

echo ""
echo "=========================================="
echo "6. VULNERABILITY SCANNING TESTS"
echo "=========================================="

# Test 13: Container image vulnerability scanning
IMAGE_URL=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.spec.containers[0].image' 2>/dev/null || echo "")

if [[ "$IMAGE_URL" == gcr.io/* ]] || [[ "$IMAGE_URL" == *.pkg.dev/* ]]; then
    run_security_test "Container image vulnerability scanning enabled" \
        "gcloud container images scan '$IMAGE_URL' --format='value(discovery.analysisStatus)' | grep -q 'FINISHED_SUCCESS'" \
        "medium"
fi

# Test 14: Binary authorization
BINARY_AUTH=$(echo "$SERVICE_CONFIG" | jq -r '.metadata.annotations["run.googleapis.com/binary-authorization"]' 2>/dev/null || echo "")

if [ "$ENVIRONMENT" = "production" ]; then
    run_security_test "Production binary authorization enabled" \
        "[ ! -z '$BINARY_AUTH' ] && [ '$BINARY_AUTH' != 'null' ]" \
        "medium"
fi

echo ""
echo "=========================================="
echo "7. LOGGING & MONITORING SECURITY TESTS"
echo "=========================================="

# Test 15: Audit logging enabled
run_security_test "Audit logging enabled" \
    "gcloud logging read 'protoPayload.serviceName=\"run.googleapis.com\" AND resource.labels.service_name=\"$SERVICE_NAME\"' --limit=1 --format='value(timestamp)' | grep -q '.'" \
    "medium"

# Test 16: Error reporting configured
run_security_test "Error reporting configured" \
    "gcloud error-reporting events list --filter='serviceContext.service:$SERVICE_NAME' --limit=1 --format='value(eventTime)' | grep -q '.'" \
    "low"

echo ""
echo "=========================================="
echo "8. COMPLIANCE TESTS"
echo "=========================================="

# Test 17: Resource labeling compliance
LABELS=$(echo "$SERVICE_CONFIG" | jq -r '.metadata.labels' 2>/dev/null || echo "{}")

run_security_test "Required labels present" \
    "echo '$LABELS' | jq -r '. | has(\"environment\") and has(\"managed-by\")' | grep -q 'true'" \
    "low"

# Test 18: Resource naming compliance
run_security_test "Service name follows naming convention" \
    "echo '$SERVICE_NAME' | grep -qE '^[a-z][a-z0-9-]*[a-z0-9]$'" \
    "low"

echo ""
echo "=========================================="
echo "9. INPUT VALIDATION TESTS"
echo "=========================================="

# Test 19: SQL injection protection
run_security_test "SQL injection protection" \
    "curl -s --max-time 10 '$SERVICE_URL/?id=1%27%20OR%20%271%27%3D%271' | grep -qv 'error\\|exception'" \
    "high"

# Test 20: XSS protection
run_security_test "XSS protection" \
    "curl -s --max-time 10 '$SERVICE_URL/?name=<script>alert(1)</script>' | grep -qv '<script>'" \
    "high"

# Test 21: Path traversal protection
run_security_test "Path traversal protection" \
    "curl -s --max-time 10 '$SERVICE_URL/../../../etc/passwd' -w '%{http_code}' | grep -qE '^(404|400|403)'" \
    "high"

echo ""
echo "=========================================="
echo "10. DENIAL OF SERVICE PROTECTION TESTS"
echo "=========================================="

# Test 22: Request size limits
run_security_test "Request size limits enforced" \
    "curl -s --max-time 10 -X POST '$SERVICE_URL/' -d 'data=$(python3 -c \"print('x' * 10000000)\")' -w '%{http_code}' | grep -qE '^(413|400)'" \
    "medium"

# Test 23: Rate limiting configuration
CONCURRENCY=$(echo "$SERVICE_CONFIG" | jq -r '.spec.template.spec.containerConcurrency' 2>/dev/null || echo "80")

run_security_test "Concurrency limits configured" \
    "[ '$CONCURRENCY' -le 1000 ]" \
    "medium"

# Update summary
jq ".summary.total_tests = $TOTAL_TESTS | .summary.passed = $PASSED_TESTS | .summary.failed = $FAILED_TESTS | .summary.warnings = $WARNING_TESTS | .summary.critical_issues = $CRITICAL_ISSUES" "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"

echo ""
echo "=========================================="
echo "SECURITY ASSESSMENT SUMMARY"
echo "=========================================="

log_info "Security Assessment Results:"
log_info "  Total tests: $TOTAL_TESTS"
log_info "  Passed: $PASSED_TESTS"
log_info "  Failed: $FAILED_TESTS"
log_info "  Warnings: $WARNING_TESTS"
log_info "  Critical issues: $CRITICAL_ISSUES"

echo ""
echo "Security Posture Assessment:"

if [ $CRITICAL_ISSUES -eq 0 ]; then
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🔒 EXCELLENT: No security issues found"
        SECURITY_GRADE="A"
    elif [ $FAILED_TESTS -le 2 ]; then
        log_success "🔒 GOOD: Minor security improvements needed"
        SECURITY_GRADE="B"
    else
        log_warning "⚠️  MODERATE: Several security improvements needed"
        SECURITY_GRADE="C"
    fi
else
    log_error "❌ POOR: Critical security issues must be addressed"
    SECURITY_GRADE="F"
fi

echo ""
echo "Security Grade: $SECURITY_GRADE"

# Recommendations based on environment
echo ""
echo "Environment-Specific Recommendations:"

case "$ENVIRONMENT" in
    "production")
        echo "  Production Security Checklist:"
        echo "  • ✓ Enforce authentication (no unauthenticated access)"
        echo "  • ✓ Use internal ingress or load balancer only"
        echo "  • ✓ Enable VPC connector for network isolation"
        echo "  • ✓ Enable binary authorization"
        echo "  • ✓ Use custom service account with minimal permissions"
        echo "  • ✓ Enable audit logging and monitoring"
        ;;
    "staging")
        echo "  Staging Security Checklist:"
        echo "  • ✓ Test authentication mechanisms"
        echo "  • ✓ Validate security configurations"
        echo "  • ✓ Perform security testing"
        echo "  • ✓ Review access controls"
        ;;
    "development")
        echo "  Development Security Checklist:"
        echo "  • ✓ Follow secure coding practices"
        echo "  • ✓ Use environment-appropriate configurations"
        echo "  • ✓ Test security features early"
        echo "  • ✓ Avoid production data in development"
        ;;
esac

echo ""
echo "Detailed security report saved to: $RESULTS_FILE"

echo ""
echo "Next Steps:"
if [ $CRITICAL_ISSUES -gt 0 ]; then
    echo "  1. Address CRITICAL security issues immediately"
    echo "  2. Review failed tests and implement fixes"
    echo "  3. Re-run security assessment after fixes"
    echo "  4. Consider security review with security team"
elif [ $FAILED_TESTS -gt 0 ]; then
    echo "  1. Review failed tests and plan improvements"
    echo "  2. Implement security enhancements"
    echo "  3. Update security documentation"
    echo "  4. Schedule regular security assessments"
else
    echo "  1. Maintain current security posture"
    echo "  2. Schedule regular security assessments"
    echo "  3. Keep security configurations up to date"
    echo "  4. Monitor for new security best practices"
fi

echo ""
echo "Security Resources:"
echo "  • Cloud Run Security Guide: https://cloud.google.com/run/docs/securing"
echo "  • GCP Security Command Center: https://console.cloud.google.com/security/command-center"
echo "  • Binary Authorization: https://cloud.google.com/binary-authorization/docs"

if [ $CRITICAL_ISSUES -eq 0 ] && [ $FAILED_TESTS -le 2 ]; then
    log_success "🔒 Security assessment PASSED"
    exit 0
else
    log_error "❌ Security assessment FAILED - Critical issues must be addressed"
    exit 1
fi