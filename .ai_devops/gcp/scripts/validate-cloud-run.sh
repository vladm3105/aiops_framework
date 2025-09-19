#!/bin/bash

# GCP Cloud Run Deployment Validation Script
# Validates Google Cloud Run service deployments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCP_DIR="$(dirname "$SCRIPT_DIR")"

echo "✅ GCP Cloud Run Deployment Validation"
echo "======================================"

# Parse command line arguments
SERVICE_NAME="${1:-}"
REGION="${2:-us-central1}"
PROJECT_ID="${3:-}"

if [[ -z "$SERVICE_NAME" ]]; then
    echo "❌ Service name required"
    echo "Usage: $0 <service-name> [region] [project-id]"
    exit 1
fi

echo "Service Name: $SERVICE_NAME"
echo "Region: $REGION"

# Get project ID if not provided
if [[ -z "$PROJECT_ID" ]]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    if [[ -z "$PROJECT_ID" ]]; then
        echo "❌ No project specified and no default project set"
        exit 1
    fi
fi

echo "Project ID: $PROJECT_ID"

# Check prerequisites
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud CLI not found"
    exit 1
fi

if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1 > /dev/null; then
    echo "❌ Not authenticated with Google Cloud"
    exit 1
fi

# Validation results
VALIDATION_PASSED=0
VALIDATION_FAILED=0

# Function to report test result
report_test() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    if [[ "$result" == "PASS" ]]; then
        echo "✅ $test_name: $message"
        VALIDATION_PASSED=$((VALIDATION_PASSED + 1))
    else
        echo "❌ $test_name: $message"
        VALIDATION_FAILED=$((VALIDATION_FAILED + 1))
    fi
}

echo ""
echo "🔍 Running validation tests..."

# Test 1: Service exists
echo "1. Checking if Cloud Run service exists..."
if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
    report_test "Service Existence" "PASS" "Service '$SERVICE_NAME' exists"
else
    report_test "Service Existence" "FAIL" "Service '$SERVICE_NAME' not found"
    exit 1
fi

# Test 2: Service state
echo "2. Checking service state..."
SERVICE_STATE=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.conditions[0].type)" 2>/dev/null || echo "Unknown")

case "$SERVICE_STATE" in
    "Ready")
        report_test "Service State" "PASS" "Service is ready"
        ;;
    "Unknown"|"")
        report_test "Service State" "FAIL" "Service state unknown"
        ;;
    *)
        report_test "Service State" "FAIL" "Service state: $SERVICE_STATE"
        ;;
esac

# Test 3: Service URL assignment
echo "3. Checking service URL assignment..."
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)" 2>/dev/null || echo "")

if [[ -n "$SERVICE_URL" ]]; then
    report_test "URL Assignment" "PASS" "Service URL: $SERVICE_URL"
else
    report_test "URL Assignment" "FAIL" "No service URL assigned"
fi

# Test 4: Image configuration
echo "4. Checking image configuration..."
IMAGE_NAME=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(spec.template.spec.template.spec.containers[0].image)" 2>/dev/null || echo "")

if [[ -n "$IMAGE_NAME" ]]; then
    report_test "Image Configuration" "PASS" "Image: $IMAGE_NAME"
else
    report_test "Image Configuration" "FAIL" "No image configured"
fi

# Test 5: Resource allocation
echo "5. Checking resource allocation..."
CPU_LIMIT=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(spec.template.spec.template.spec.containers[0].resources.limits.cpu)" 2>/dev/null || echo "")

MEMORY_LIMIT=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(spec.template.spec.template.spec.containers[0].resources.limits.memory)" 2>/dev/null || echo "")

if [[ -n "$CPU_LIMIT" && -n "$MEMORY_LIMIT" ]]; then
    report_test "Resource Allocation" "PASS" "CPU: $CPU_LIMIT, Memory: $MEMORY_LIMIT"
else
    report_test "Resource Allocation" "FAIL" "Resource allocation not properly configured"
fi

# Test 6: HTTP connectivity (if URL is available)
if [[ -n "$SERVICE_URL" ]]; then
    echo "6. Testing HTTP connectivity..."
    
    if curl -f -s --max-time 10 "$SERVICE_URL" > /dev/null 2>&1; then
        report_test "HTTP Connectivity" "PASS" "Service endpoint responding"
    else
        report_test "HTTP Connectivity" "FAIL" "Service endpoint not responding"
    fi
else
    echo "6. Skipping HTTP connectivity test (no URL available)"
fi

# Test 7: Health endpoint (if available)
if [[ -n "$SERVICE_URL" ]]; then
    echo "7. Testing health endpoint..."
    
    if curl -f -s --max-time 5 "$SERVICE_URL/health" > /dev/null 2>&1; then
        report_test "Health Endpoint" "PASS" "Health endpoint responding"
    else
        report_test "Health Endpoint" "WARN" "Health endpoint not available (may be normal)"
    fi
else
    echo "7. Skipping health endpoint test (no URL available)"
fi

# Test 8: Environment variables
echo "8. Checking environment variables..."
ENV_VARS=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(spec.template.spec.template.spec.containers[0].env[].name)" 2>/dev/null || echo "")

if [[ -n "$ENV_VARS" ]]; then
    ENV_COUNT=$(echo "$ENV_VARS" | wc -w)
    report_test "Environment Variables" "PASS" "Environment variables set: $ENV_COUNT"
else
    report_test "Environment Variables" "INFO" "No custom environment variables"
fi

# Test 9: IAM configuration
echo "9. Checking IAM configuration..."
IAM_POLICY=$(gcloud run services get-iam-policy "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(bindings[0].role)" 2>/dev/null || echo "")

if [[ -n "$IAM_POLICY" ]]; then
    if echo "$IAM_POLICY" | grep -q "allUsers"; then
        report_test "IAM Configuration" "PASS" "Service allows unauthenticated access"
    else
        report_test "IAM Configuration" "PASS" "Service has authenticated access only"
    fi
else
    report_test "IAM Configuration" "WARN" "IAM policy not found"
fi

# Test 10: Revision analysis
echo "10. Checking service revisions..."
REVISIONS=$(gcloud run revisions list \
    --service="$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(metadata.name)" 2>/dev/null || echo "")

if [[ -n "$REVISIONS" ]]; then
    REVISION_COUNT=$(echo "$REVISIONS" | wc -w)
    LATEST_REVISION=$(echo "$REVISIONS" | head -n1)
    
    # Check if latest revision is receiving traffic
    TRAFFIC_PERCENT=$(gcloud run services describe "$SERVICE_NAME" \
        --region="$REGION" \
        --project="$PROJECT_ID" \
        --format="value(status.traffic[0].percent)" 2>/dev/null || echo "0")
    
    if [[ "$TRAFFIC_PERCENT" == "100" ]]; then
        report_test "Revision Status" "PASS" "Latest revision receiving 100% traffic"
    else
        report_test "Revision Status" "WARN" "Traffic split detected: $TRAFFIC_PERCENT% to latest"
    fi
else
    report_test "Revision Status" "FAIL" "No revisions found"
fi

# Summary
echo ""
echo "📊 Validation Summary"
echo "==================="
echo "Tests Passed: $VALIDATION_PASSED"
echo "Tests Failed: $VALIDATION_FAILED"
echo "Total Tests: $((VALIDATION_PASSED + VALIDATION_FAILED))"

if [[ $VALIDATION_FAILED -eq 0 ]]; then
    echo "✅ All validations passed! Cloud Run service is healthy."
    OVERALL_STATUS="HEALTHY"
elif [[ $VALIDATION_FAILED -le 2 ]]; then
    echo "⚠️  Minor issues detected. Service may need attention."
    OVERALL_STATUS="WARNING"
else
    echo "❌ Significant issues detected. Service needs investigation."
    OVERALL_STATUS="UNHEALTHY"
fi

# Service information summary
echo ""
echo "📋 Service Information"
echo "===================="
echo "Name: $SERVICE_NAME"
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "State: $SERVICE_STATE"
echo "URL: ${SERVICE_URL:-'Not assigned'}"
echo "Image: ${IMAGE_NAME:-'Unknown'}"
echo "CPU: ${CPU_LIMIT:-'Unknown'}"
echo "Memory: ${MEMORY_LIMIT:-'Unknown'}"

if [[ -n "$SERVICE_URL" ]]; then
    echo ""
    echo "🌐 Access URLs:"
    echo "Service: $SERVICE_URL"
    echo "Health: $SERVICE_URL/health"
fi

echo ""
echo "🔧 Useful Commands:"
echo "View logs: gcloud run services logs read --service='$SERVICE_NAME' --region='$REGION'"
echo "Update: gcloud run services update '$SERVICE_NAME' --region='$REGION'"
echo "Delete: gcloud run services delete '$SERVICE_NAME' --region='$REGION' --quiet"

# Output for automation
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "validation_status=$OVERALL_STATUS" >> "$GITHUB_OUTPUT"
    echo "tests_passed=$VALIDATION_PASSED" >> "$GITHUB_OUTPUT"
    echo "tests_failed=$VALIDATION_FAILED" >> "$GITHUB_OUTPUT"
    echo "service_state=$SERVICE_STATE" >> "$GITHUB_OUTPUT"
    echo "service_url=$SERVICE_URL" >> "$GITHUB_OUTPUT"
fi

# Exit with appropriate code
if [[ "$OVERALL_STATUS" == "UNHEALTHY" ]]; then
    exit 1
else
    exit 0
fi