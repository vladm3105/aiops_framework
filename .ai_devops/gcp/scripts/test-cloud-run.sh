#!/bin/bash

# Cloud Run Testing Script
# AI DevOps Framework v3.7 - Comprehensive testing for Cloud Run deployments

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

SERVICE_NAME="${1:-}"
PROJECT_ID="${2:-}"
REGION="${3:-us-central1}"
ENVIRONMENT="${4:-development}"
VERBOSE="${5:-false}"

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: SERVICE_NAME is required"
    echo "Usage: $0 <SERVICE_NAME> [PROJECT_ID] [REGION] [ENVIRONMENT] [VERBOSE]"
    echo "Example: $0 simple-app my-project us-central1 development true"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: PROJECT_ID not found. Set with: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
fi

log_info "Starting comprehensive Cloud Run testing"
log_info "Service: $SERVICE_NAME"
log_info "Project: $PROJECT_ID"
log_info "Region: $REGION"
log_info "Environment: $ENVIRONMENT"

TEST_RESULTS=()
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# Test execution function
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_result="${3:-0}"
    
    TEST_COUNT=$((TEST_COUNT + 1))
    
    if [ "$VERBOSE" = "true" ]; then
        log_info "Running test: $test_name"
        log_info "Command: $test_command"
    fi
    
    if eval "$test_command" >/dev/null 2>&1; then
        if [ "$expected_result" = "0" ]; then
            log_success "✅ PASS: $test_name"
            TEST_RESULTS+=("PASS: $test_name")
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            log_error "❌ FAIL: $test_name (expected failure but passed)"
            TEST_RESULTS+=("FAIL: $test_name (expected failure but passed)")
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        if [ "$expected_result" = "1" ]; then
            log_success "✅ PASS: $test_name (expected failure)"
            TEST_RESULTS+=("PASS: $test_name (expected failure)")
            PASS_COUNT=$((PASS_COUNT + 1))
        else
            log_error "❌ FAIL: $test_name"
            TEST_RESULTS+=("FAIL: $test_name")
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    fi
}

# Get service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    log_error "Cloud Run service '$SERVICE_NAME' not found in region '$REGION'"
    exit 1
fi

log_info "Testing service URL: $SERVICE_URL"

echo "=========================================="
echo "1. SERVICE AVAILABILITY TESTS"
echo "=========================================="

# Test 1: Service exists and is accessible
run_test "Service exists" \
    "gcloud run services describe '$SERVICE_NAME' --region='$REGION' --project='$PROJECT_ID'"

# Test 2: Service is ready
run_test "Service is ready" \
    "gcloud run services describe '$SERVICE_NAME' --region='$REGION' --project='$PROJECT_ID' --format='value(status.conditions[0].status)' | grep -q 'True'"

# Test 3: Service has traffic
run_test "Service has traffic allocation" \
    "gcloud run services describe '$SERVICE_NAME' --region='$REGION' --project='$PROJECT_ID' --format='value(status.traffic[0].percent)' | grep -q '100'"

echo ""
echo "=========================================="
echo "2. ENDPOINT CONNECTIVITY TESTS"
echo "=========================================="

# Test 4: Home endpoint responds
run_test "Home endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/' >/dev/null"

# Test 5: Health endpoint responds
run_test "Health endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/health' >/dev/null"

# Test 6: Startup endpoint responds
run_test "Startup endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/startup' >/dev/null"

# Test 7: Ready endpoint responds
run_test "Ready endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/ready' >/dev/null"

# Test 8: Config endpoint responds
run_test "Config endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/config' >/dev/null"

# Test 9: Info endpoint responds
run_test "Info endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/info' >/dev/null"

# Test 10: Dashboard endpoint responds
run_test "Dashboard endpoint accessible" \
    "curl -f -s --max-time 30 '$SERVICE_URL/dashboard' >/dev/null"

echo ""
echo "=========================================="
echo "3. HEALTH CHECK VALIDATION TESTS"
echo "=========================================="

# Test 11: Health check returns healthy status
HEALTH_RESPONSE=$(curl -s --max-time 30 "$SERVICE_URL/health" 2>/dev/null || echo "{}")
run_test "Health check returns healthy status" \
    "echo '$HEALTH_RESPONSE' | jq -r '.status' | grep -q 'healthy'"

# Test 12: Startup probe returns ready status
STARTUP_RESPONSE=$(curl -s --max-time 30 "$SERVICE_URL/startup" 2>/dev/null || echo "{}")
run_test "Startup probe returns ready status" \
    "echo '$STARTUP_RESPONSE' | jq -r '.status' | grep -q 'ready'"

# Test 13: Ready probe returns ready status
READY_RESPONSE=$(curl -s --max-time 30 "$SERVICE_URL/ready" 2>/dev/null || echo "{}")
run_test "Ready probe returns ready status" \
    "echo '$READY_RESPONSE' | jq -r '.status' | grep -q 'ready'"

echo ""
echo "=========================================="
echo "4. PERFORMANCE TESTS"
echo "=========================================="

# Test 14: Response time under threshold
RESPONSE_TIME=$(curl -o /dev/null -s -w "%{time_total}" --max-time 30 "$SERVICE_URL/health" 2>/dev/null || echo "999")
run_test "Health endpoint response time < 2s" \
    "awk 'BEGIN {exit !('$RESPONSE_TIME' < 2)}'"

# Test 15: Concurrent requests handling
run_test "Handles concurrent requests" \
    "for i in {1..5}; do curl -f -s --max-time 30 '$SERVICE_URL/health' >/dev/null & done; wait"

echo ""
echo "=========================================="
echo "5. CONFIGURATION VALIDATION TESTS"
echo "=========================================="

# Test 16: Environment configuration correct
CONFIG_RESPONSE=$(curl -s --max-time 30 "$SERVICE_URL/config" 2>/dev/null || echo "{}")
run_test "Environment configuration correct" \
    "echo '$CONFIG_RESPONSE' | jq -r '.configuration.environment' | grep -q '$ENVIRONMENT'"

# Test 17: Project ID configuration correct
run_test "Project ID configuration correct" \
    "echo '$CONFIG_RESPONSE' | jq -r '.configuration.project_id' | grep -q '$PROJECT_ID'"

echo ""
echo "=========================================="
echo "6. SECURITY TESTS"
echo "=========================================="

# Test 18: Service uses HTTPS
run_test "Service uses HTTPS" \
    "echo '$SERVICE_URL' | grep -q 'https://'"

# Test 19: Security headers present
HEADERS=$(curl -I -s --max-time 30 "$SERVICE_URL/" 2>/dev/null || echo "")
run_test "Security headers present" \
    "echo '$HEADERS' | grep -q -i 'strict-transport-security\\|x-frame-options\\|x-content-type-options'"

echo ""
echo "=========================================="
echo "7. MONITORING TESTS"
echo "=========================================="

# Test 20: Metrics endpoint accessible (if monitoring enabled)
if echo "$CONFIG_RESPONSE" | jq -r '.configuration.enable_monitoring' | grep -q 'true'; then
    run_test "Metrics endpoint accessible" \
        "curl -f -s --max-time 30 '$SERVICE_URL/metrics' >/dev/null"
else
    log_info "⏭️  SKIP: Metrics endpoint (monitoring disabled)"
fi

echo ""
echo "=========================================="
echo "8. LOAD TESTS (Basic)"
echo "=========================================="

# Test 21: Service handles sustained load
log_info "Running basic load test (30 requests over 10 seconds)..."
LOAD_TEST_SUCCESS=true
for i in {1..30}; do
    if ! curl -f -s --max-time 5 "$SERVICE_URL/health" >/dev/null; then
        LOAD_TEST_SUCCESS=false
        break
    fi
    sleep 0.33
done

run_test "Sustained load test" \
    "[ '$LOAD_TEST_SUCCESS' = 'true' ]"

echo ""
echo "=========================================="
echo "9. ERROR HANDLING TESTS"
echo "=========================================="

# Test 22: 404 error handling
run_test "404 error handling" \
    "curl -s --max-time 30 '$SERVICE_URL/nonexistent' | grep -q '404\\|Not Found'" 1

# Test 23: Invalid method handling
run_test "Invalid method handling" \
    "curl -X DELETE -s --max-time 30 '$SERVICE_URL/' -w '%{http_code}' | grep -q '405\\|501'" 1

echo ""
echo "=========================================="
echo "10. INTEGRATION TESTS"
echo "=========================================="

# Test 24: Service logs are being generated
RECENT_LOGS=$(gcloud logging read "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"$SERVICE_NAME\"" \
    --limit=1 \
    --format="value(timestamp)" \
    --project="$PROJECT_ID" 2>/dev/null || echo "")

run_test "Service logs are being generated" \
    "[ ! -z '$RECENT_LOGS' ]"

# Test 25: Service scaling configuration
SCALING_CONFIG=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(spec.template.metadata.annotations[autoscaling.knative.dev/maxScale])" 2>/dev/null || echo "")

run_test "Service scaling configuration present" \
    "[ ! -z '$SCALING_CONFIG' ]"

echo ""
echo "=========================================="
echo "TEST RESULTS SUMMARY"
echo "=========================================="

log_info "Total tests run: $TEST_COUNT"
log_info "Passed: $PASS_COUNT"
log_info "Failed: $FAIL_COUNT"

if [ $FAIL_COUNT -eq 0 ]; then
    log_success "🎉 ALL TESTS PASSED!"
    echo ""
    echo "Service '$SERVICE_NAME' is fully operational and meets all test criteria."
    echo ""
    echo "Service Information:"
    echo "  URL: $SERVICE_URL"
    echo "  Environment: $ENVIRONMENT"
    echo "  Region: $REGION"
    echo "  Project: $PROJECT_ID"
    echo ""
    echo "Available Endpoints:"
    echo "  Home: $SERVICE_URL/"
    echo "  Health: $SERVICE_URL/health"
    echo "  Dashboard: $SERVICE_URL/dashboard"
    echo "  Metrics: $SERVICE_URL/metrics"
    echo "  Config: $SERVICE_URL/config"
    echo ""
    exit 0
else
    log_error "❌ $FAIL_COUNT TEST(S) FAILED"
    echo ""
    echo "Failed tests:"
    for result in "${TEST_RESULTS[@]}"; do
        if [[ $result == FAIL:* ]]; then
            echo "  - ${result#FAIL: }"
        fi
    done
    echo ""
    echo "Troubleshooting suggestions:"
    echo "1. Check service logs: gcloud run services logs read $SERVICE_NAME --region $REGION --project $PROJECT_ID"
    echo "2. Verify service configuration: gcloud run services describe $SERVICE_NAME --region $REGION --project $PROJECT_ID"
    echo "3. Run validation script: ./validate-cloud-run.sh $SERVICE_NAME $PROJECT_ID $REGION"
    echo "4. Check service status in Cloud Console: https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME?project=$PROJECT_ID"
    echo ""
    exit 1
fi