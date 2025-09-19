#!/bin/bash

# Azure Container Deployment Validation Script
# Validates Azure Container Instance deployments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"

echo "✅ Azure Container Deployment Validation"
echo "======================================="

# Parse command line arguments
RESOURCE_GROUP="${1:-rg-containers}"
CONTAINER_NAME="${2:-}"

if [[ -z "$CONTAINER_NAME" ]]; then
    echo "❌ Container name required"
    echo "Usage: $0 <resource-group> <container-name>"
    exit 1
fi

echo "Resource Group: $RESOURCE_GROUP"
echo "Container Name: $CONTAINER_NAME"

# Check prerequisites
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found"
    exit 1
fi

if ! az account show > /dev/null 2>&1; then
    echo "❌ Not authenticated with Azure"
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

# Test 1: Container exists
echo "1. Checking if container exists..."
if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
    report_test "Container Existence" "PASS" "Container '$CONTAINER_NAME' exists"
else
    report_test "Container Existence" "FAIL" "Container '$CONTAINER_NAME' not found"
    exit 1
fi

# Test 2: Container state
echo "2. Checking container state..."
CONTAINER_STATE=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query instanceView.state -o tsv)

if [[ "$CONTAINER_STATE" == "Running" ]]; then
    report_test "Container State" "PASS" "Container is running"
elif [[ "$CONTAINER_STATE" == "Pending" ]]; then
    report_test "Container State" "WARN" "Container is starting up"
else
    report_test "Container State" "FAIL" "Container state: $CONTAINER_STATE"
fi

# Test 3: IP address assignment
echo "3. Checking IP address assignment..."
CONTAINER_IP=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query ipAddress.ip -o tsv)

if [[ -n "$CONTAINER_IP" && "$CONTAINER_IP" != "null" ]]; then
    report_test "IP Assignment" "PASS" "IP address: $CONTAINER_IP"
else
    report_test "IP Assignment" "FAIL" "No IP address assigned"
fi

# Test 4: FQDN assignment
echo "4. Checking FQDN assignment..."
CONTAINER_FQDN=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query ipAddress.fqdn -o tsv)

if [[ -n "$CONTAINER_FQDN" && "$CONTAINER_FQDN" != "null" ]]; then
    report_test "FQDN Assignment" "PASS" "FQDN: $CONTAINER_FQDN"
else
    report_test "FQDN Assignment" "FAIL" "No FQDN assigned"
fi

# Test 5: Port configuration
echo "5. Checking port configuration..."
PORTS=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query ipAddress.ports -o json)

if [[ -n "$PORTS" && "$PORTS" != "null" ]]; then
    PORT_COUNT=$(echo "$PORTS" | jq length)
    report_test "Port Configuration" "PASS" "Ports configured: $PORT_COUNT"
else
    report_test "Port Configuration" "FAIL" "No ports configured"
fi

# Test 6: HTTP connectivity (if FQDN is available)
if [[ -n "$CONTAINER_FQDN" && "$CONTAINER_FQDN" != "null" ]]; then
    echo "6. Testing HTTP connectivity..."
    
    # Check if port 80 is configured
    HTTP_PORT_CONFIGURED=$(echo "$PORTS" | jq '.[] | select(.port == 80)' | wc -l)
    
    if [[ "$HTTP_PORT_CONFIGURED" -gt 0 ]]; then
        if curl -f -s --max-time 10 "http://$CONTAINER_FQDN" > /dev/null 2>&1; then
            report_test "HTTP Connectivity" "PASS" "HTTP endpoint responding"
        else
            report_test "HTTP Connectivity" "FAIL" "HTTP endpoint not responding"
        fi
    else
        report_test "HTTP Connectivity" "SKIP" "Port 80 not configured"
    fi
else
    echo "6. Skipping HTTP connectivity test (no FQDN)"
fi

# Test 7: Resource allocation
echo "7. Checking resource allocation..."
CPU_REQUEST=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query containers[0].resources.requests.cpu -o tsv)

MEMORY_REQUEST=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query containers[0].resources.requests.memoryInGB -o tsv)

if [[ -n "$CPU_REQUEST" && -n "$MEMORY_REQUEST" ]]; then
    report_test "Resource Allocation" "PASS" "CPU: ${CPU_REQUEST}, Memory: ${MEMORY_REQUEST}GB"
else
    report_test "Resource Allocation" "FAIL" "Resource allocation not properly configured"
fi

# Test 8: Container logs
echo "8. Checking container logs..."
LOGS=$(az container logs \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --tail 5 2>/dev/null || echo "")

if [[ -n "$LOGS" ]]; then
    report_test "Container Logs" "PASS" "Logs available (recent entries found)"
    echo "   Recent log entries:"
    echo "$LOGS" | sed 's/^/   | /'
else
    report_test "Container Logs" "WARN" "No recent log entries found"
fi

# Test 9: Environment variables
echo "9. Checking environment variables..."
ENV_VARS=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query containers[0].environmentVariables -o json)

if [[ -n "$ENV_VARS" && "$ENV_VARS" != "null" && "$ENV_VARS" != "[]" ]]; then
    ENV_COUNT=$(echo "$ENV_VARS" | jq length)
    report_test "Environment Variables" "PASS" "Environment variables set: $ENV_COUNT"
else
    report_test "Environment Variables" "INFO" "No custom environment variables"
fi

# Test 10: Restart count
echo "10. Checking restart count..."
RESTART_COUNT=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query instanceView.restartCount -o tsv)

if [[ "$RESTART_COUNT" == "0" ]]; then
    report_test "Restart Count" "PASS" "No restarts (stable container)"
elif [[ "$RESTART_COUNT" -le 3 ]]; then
    report_test "Restart Count" "WARN" "Restart count: $RESTART_COUNT (may indicate issues)"
else
    report_test "Restart Count" "FAIL" "High restart count: $RESTART_COUNT (likely issues)"
fi

# Summary
echo ""
echo "📊 Validation Summary"
echo "==================="
echo "Tests Passed: $VALIDATION_PASSED"
echo "Tests Failed: $VALIDATION_FAILED"
echo "Total Tests: $((VALIDATION_PASSED + VALIDATION_FAILED))"

if [[ $VALIDATION_FAILED -eq 0 ]]; then
    echo "✅ All validations passed! Deployment is healthy."
    OVERALL_STATUS="HEALTHY"
elif [[ $VALIDATION_FAILED -le 2 ]]; then
    echo "⚠️  Minor issues detected. Deployment may need attention."
    OVERALL_STATUS="WARNING"
else
    echo "❌ Significant issues detected. Deployment needs investigation."
    OVERALL_STATUS="UNHEALTHY"
fi

# Container information summary
echo ""
echo "📋 Container Information"
echo "======================"
echo "Name: $CONTAINER_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "State: $CONTAINER_STATE"
echo "IP Address: ${CONTAINER_IP:-'Not assigned'}"
echo "FQDN: ${CONTAINER_FQDN:-'Not assigned'}"
echo "CPU: ${CPU_REQUEST:-'Unknown'}"
echo "Memory: ${MEMORY_REQUEST:-'Unknown'}GB"
echo "Restart Count: ${RESTART_COUNT:-'Unknown'}"

if [[ -n "$CONTAINER_FQDN" && "$CONTAINER_FQDN" != "null" ]]; then
    echo ""
    echo "🌐 Access URLs:"
    echo "HTTP: http://$CONTAINER_FQDN"
    echo "HTTPS: https://$CONTAINER_FQDN"
fi

echo ""
echo "🔧 Useful Commands:"
echo "View logs: az container logs --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
echo "Restart: az container restart --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
echo "Delete: az container delete --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME' --yes"

# Output for automation
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "validation_status=$OVERALL_STATUS" >> "$GITHUB_OUTPUT"
    echo "tests_passed=$VALIDATION_PASSED" >> "$GITHUB_OUTPUT"
    echo "tests_failed=$VALIDATION_FAILED" >> "$GITHUB_OUTPUT"
    echo "container_state=$CONTAINER_STATE" >> "$GITHUB_OUTPUT"
    echo "container_ip=$CONTAINER_IP" >> "$GITHUB_OUTPUT"
    echo "container_fqdn=$CONTAINER_FQDN" >> "$GITHUB_OUTPUT"
fi

# Exit with appropriate code
if [[ "$OVERALL_STATUS" == "UNHEALTHY" ]]; then
    exit 1
else
    exit 0
fi