#!/bin/bash

# Azure Container Deployment Testing Script
# Comprehensive testing suite for Azure Container Instances deployments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 Azure Container Deployment Testing Suite"
echo "==========================================="

# Parse command line arguments
TEST_TYPE="${1:-all}"
RESOURCE_GROUP="${2:-rg-containers}"
CONTAINER_NAME="${3:-}"
ENVIRONMENT="${4:-development}"

echo "Test Type: $TEST_TYPE"
echo "Resource Group: $RESOURCE_GROUP"
echo "Environment: $ENVIRONMENT"
if [[ -n "$CONTAINER_NAME" ]]; then
    echo "Container Name: $CONTAINER_NAME"
fi

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test result logging
log_test_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    case "$result" in
        "PASS")
            echo "✅ $test_name: $message"
            TESTS_PASSED=$((TESTS_PASSED + 1))
            ;;
        "FAIL")
            echo "❌ $test_name: $message"
            TESTS_FAILED=$((TESTS_FAILED + 1))
            ;;
        "SKIP")
            echo "⏭️  $test_name: $message"
            TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
            ;;
        "WARN")
            echo "⚠️  $test_name: $message"
            ;;
    esac
}

# Check prerequisites
check_prerequisites() {
    echo ""
    echo "🔍 Checking prerequisites..."
    
    if ! command -v az &> /dev/null; then
        log_test_result "Azure CLI" "FAIL" "Azure CLI not found"
        return 1
    fi
    log_test_result "Azure CLI" "PASS" "Azure CLI available"
    
    if ! az account show > /dev/null 2>&1; then
        log_test_result "Azure Authentication" "FAIL" "Not authenticated with Azure"
        return 1
    fi
    log_test_result "Azure Authentication" "PASS" "Authenticated with Azure"
    
    if ! command -v jq &> /dev/null; then
        log_test_result "jq" "WARN" "jq not found - some tests may be limited"
    else
        log_test_result "jq" "PASS" "jq available for JSON processing"
    fi
    
    if ! command -v curl &> /dev/null; then
        log_test_result "curl" "WARN" "curl not found - HTTP tests may be limited"
    else
        log_test_result "curl" "PASS" "curl available for HTTP testing"
    fi
    
    return 0
}

# Test Azure subscription and resource group
test_azure_resources() {
    echo ""
    echo "☁️  Testing Azure resources..."
    
    # Check subscription access
    SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null)
    if [[ -n "$SUBSCRIPTION_ID" ]]; then
        log_test_result "Subscription Access" "PASS" "Subscription ID: $SUBSCRIPTION_ID"
    else
        log_test_result "Subscription Access" "FAIL" "Cannot access subscription"
        return 1
    fi
    
    # Check resource group
    if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
        LOCATION=$(az group show --name "$RESOURCE_GROUP" --query location -o tsv)
        log_test_result "Resource Group" "PASS" "Resource group '$RESOURCE_GROUP' exists in $LOCATION"
    else
        log_test_result "Resource Group" "FAIL" "Resource group '$RESOURCE_GROUP' not found"
        return 1
    fi
    
    # Check available quota
    QUOTA_INFO=$(az vm list-usage --location "$LOCATION" --query "[?name.value=='standardDSv3Family']" -o json 2>/dev/null || echo "[]")
    if [[ "$QUOTA_INFO" != "[]" ]]; then
        log_test_result "Quota Check" "PASS" "Quota information retrieved"
    else
        log_test_result "Quota Check" "WARN" "Could not retrieve quota information"
    fi
    
    return 0
}

# Test deployment scripts
test_deployment_scripts() {
    echo ""
    echo "📜 Testing deployment scripts..."
    
    # Check script existence and permissions
    local scripts=(
        "deploy-docker-container.sh"
        "cleanup-containers.sh"
        "validate-deployment.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            if [[ -x "$SCRIPT_DIR/$script" ]]; then
                log_test_result "Script $script" "PASS" "Script exists and is executable"
            else
                log_test_result "Script $script" "WARN" "Script exists but is not executable"
            fi
        else
            log_test_result "Script $script" "FAIL" "Script not found"
        fi
    done
    
    # Check configuration files
    local configs=(
        "configs/azure-deployment.json"
        "configs/container-defaults.json"
        "configs/claude-prompts.json"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$AZURE_DIR/$config" ]]; then
            if jq . "$AZURE_DIR/$config" > /dev/null 2>&1; then
                log_test_result "Config $config" "PASS" "Configuration file is valid JSON"
            else
                log_test_result "Config $config" "FAIL" "Configuration file has invalid JSON"
            fi
        else
            log_test_result "Config $config" "FAIL" "Configuration file not found"
        fi
    done
    
    return 0
}

# Test container deployment
test_container_deployment() {
    echo ""
    echo "🐳 Testing container deployment..."
    
    if [[ -z "$CONTAINER_NAME" ]]; then
        log_test_result "Container Deployment" "SKIP" "No container name provided for testing"
        return 0
    fi
    
    # Check if container exists
    if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
        log_test_result "Container Existence" "PASS" "Container '$CONTAINER_NAME' exists"
        
        # Get container details
        CONTAINER_STATE=$(az container show \
            --resource-group "$RESOURCE_GROUP" \
            --name "$CONTAINER_NAME" \
            --query instanceView.state -o tsv 2>/dev/null || echo "Unknown")
        
        case "$CONTAINER_STATE" in
            "Running")
                log_test_result "Container State" "PASS" "Container is running"
                ;;
            "Pending")
                log_test_result "Container State" "WARN" "Container is starting up"
                ;;
            "Terminated")
                log_test_result "Container State" "FAIL" "Container has terminated"
                ;;
            *)
                log_test_result "Container State" "WARN" "Container state: $CONTAINER_STATE"
                ;;
        esac
        
        # Test container connectivity
        test_container_connectivity "$RESOURCE_GROUP" "$CONTAINER_NAME"
        
        # Test container resources
        test_container_resources "$RESOURCE_GROUP" "$CONTAINER_NAME"
        
    else
        log_test_result "Container Existence" "FAIL" "Container '$CONTAINER_NAME' not found"
    fi
    
    return 0
}

# Test container connectivity
test_container_connectivity() {
    local rg="$1"
    local name="$2"
    
    echo ""
    echo "🌐 Testing container connectivity..."
    
    # Get IP and FQDN
    CONTAINER_IP=$(az container show \
        --resource-group "$rg" \
        --name "$name" \
        --query ipAddress.ip -o tsv 2>/dev/null || echo "")
    
    CONTAINER_FQDN=$(az container show \
        --resource-group "$rg" \
        --name "$name" \
        --query ipAddress.fqdn -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$CONTAINER_IP" && "$CONTAINER_IP" != "null" ]]; then
        log_test_result "IP Assignment" "PASS" "IP address: $CONTAINER_IP"
    else
        log_test_result "IP Assignment" "FAIL" "No IP address assigned"
    fi
    
    if [[ -n "$CONTAINER_FQDN" && "$CONTAINER_FQDN" != "null" ]]; then
        log_test_result "FQDN Assignment" "PASS" "FQDN: $CONTAINER_FQDN"
        
        # Test HTTP connectivity
        if command -v curl &> /dev/null; then
            if curl -f -s --max-time 10 "http://$CONTAINER_FQDN" > /dev/null 2>&1; then
                log_test_result "HTTP Connectivity" "PASS" "HTTP endpoint responding"
            else
                log_test_result "HTTP Connectivity" "FAIL" "HTTP endpoint not responding"
            fi
            
            # Test health endpoint
            if curl -f -s --max-time 5 "http://$CONTAINER_FQDN/health" > /dev/null 2>&1; then
                log_test_result "Health Endpoint" "PASS" "Health endpoint responding"
            else
                log_test_result "Health Endpoint" "WARN" "Health endpoint not responding"
            fi
            
            # Test readiness endpoint
            if curl -f -s --max-time 5 "http://$CONTAINER_FQDN/ready" > /dev/null 2>&1; then
                log_test_result "Readiness Endpoint" "PASS" "Readiness endpoint responding"
            else
                log_test_result "Readiness Endpoint" "WARN" "Readiness endpoint not responding"
            fi
        else
            log_test_result "HTTP Tests" "SKIP" "curl not available"
        fi
    else
        log_test_result "FQDN Assignment" "FAIL" "No FQDN assigned"
    fi
}

# Test container resources
test_container_resources() {
    local rg="$1"
    local name="$2"
    
    echo ""
    echo "💾 Testing container resources..."
    
    # Get resource allocation
    CPU_REQUEST=$(az container show \
        --resource-group "$rg" \
        --name "$name" \
        --query containers[0].resources.requests.cpu -o tsv 2>/dev/null || echo "")
    
    MEMORY_REQUEST=$(az container show \
        --resource-group "$rg" \
        --name "$name" \
        --query containers[0].resources.requests.memoryInGB -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$CPU_REQUEST" && "$CPU_REQUEST" != "null" ]]; then
        log_test_result "CPU Allocation" "PASS" "CPU: $CPU_REQUEST cores"
    else
        log_test_result "CPU Allocation" "FAIL" "CPU allocation not found"
    fi
    
    if [[ -n "$MEMORY_REQUEST" && "$MEMORY_REQUEST" != "null" ]]; then
        log_test_result "Memory Allocation" "PASS" "Memory: ${MEMORY_REQUEST}GB"
    else
        log_test_result "Memory Allocation" "FAIL" "Memory allocation not found"
    fi
    
    # Check restart count
    RESTART_COUNT=$(az container show \
        --resource-group "$rg" \
        --name "$name" \
        --query instanceView.restartCount -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$RESTART_COUNT" && "$RESTART_COUNT" != "null" ]]; then
        if [[ "$RESTART_COUNT" -eq 0 ]]; then
            log_test_result "Container Stability" "PASS" "No restarts (stable)"
        elif [[ "$RESTART_COUNT" -le 3 ]]; then
            log_test_result "Container Stability" "WARN" "Restart count: $RESTART_COUNT"
        else
            log_test_result "Container Stability" "FAIL" "High restart count: $RESTART_COUNT"
        fi
    else
        log_test_result "Container Stability" "WARN" "Restart count not available"
    fi
}

# Test ARM/Bicep templates
test_templates() {
    echo ""
    echo "📋 Testing ARM/Bicep templates..."
    
    local templates_dir="$AZURE_DIR/templates"
    
    # Check ARM template
    if [[ -f "$templates_dir/arm/container-instance.json" ]]; then
        if jq . "$templates_dir/arm/container-instance.json" > /dev/null 2>&1; then
            log_test_result "ARM Template" "PASS" "ARM template is valid JSON"
        else
            log_test_result "ARM Template" "FAIL" "ARM template has invalid JSON"
        fi
    else
        log_test_result "ARM Template" "FAIL" "ARM template not found"
    fi
    
    # Check Bicep templates
    local bicep_files=(
        "bicep/main.bicep"
        "bicep/container-instance.bicep"
        "bicep/container-registry.bicep"
        "bicep/modules/log-analytics.bicep"
    )
    
    for bicep_file in "${bicep_files[@]}"; do
        if [[ -f "$templates_dir/$bicep_file" ]]; then
            # Basic syntax check (if bicep CLI is available)
            if command -v az bicep &> /dev/null; then
                if az bicep build --file "$templates_dir/$bicep_file" --stdout > /dev/null 2>&1; then
                    log_test_result "Bicep $(basename "$bicep_file")" "PASS" "Bicep template compiles successfully"
                else
                    log_test_result "Bicep $(basename "$bicep_file")" "FAIL" "Bicep template compilation failed"
                fi
            else
                log_test_result "Bicep $(basename "$bicep_file")" "SKIP" "Bicep CLI not available"
            fi
        else
            log_test_result "Bicep $(basename "$bicep_file")" "FAIL" "Bicep template not found"
        fi
    done
    
    # Check parameter file
    if [[ -f "$templates_dir/deployment-parameters.json" ]]; then
        if jq . "$templates_dir/deployment-parameters.json" > /dev/null 2>&1; then
            log_test_result "Parameter File" "PASS" "Parameter file is valid JSON"
        else
            log_test_result "Parameter File" "FAIL" "Parameter file has invalid JSON"
        fi
    else
        log_test_result "Parameter File" "FAIL" "Parameter file not found"
    fi
}

# Test sample application
test_sample_application() {
    echo ""
    echo "🎨 Testing sample application..."
    
    local sample_dir="$AZURE_DIR/samples/simple-web-app"
    
    # Check Dockerfile
    if [[ -f "$sample_dir/Dockerfile" ]]; then
        log_test_result "Sample Dockerfile" "PASS" "Dockerfile exists"
        
        # Basic Dockerfile validation
        if grep -q "FROM nginx" "$sample_dir/Dockerfile"; then
            log_test_result "Dockerfile Base Image" "PASS" "Uses nginx base image"
        else
            log_test_result "Dockerfile Base Image" "WARN" "Base image validation needed"
        fi
    else
        log_test_result "Sample Dockerfile" "FAIL" "Dockerfile not found"
    fi
    
    # Check static files
    local static_files=(
        "static/index.html"
        "static/404.html"
        "static/50x.html"
    )
    
    for file in "${static_files[@]}"; do
        if [[ -f "$sample_dir/$file" ]]; then
            log_test_result "Static File $(basename "$file")" "PASS" "File exists"
        else
            log_test_result "Static File $(basename "$file")" "FAIL" "File not found"
        fi
    done
    
    # Check configuration files
    if [[ -f "$sample_dir/nginx.conf" ]]; then
        log_test_result "Nginx Config" "PASS" "Configuration file exists"
    else
        log_test_result "Nginx Config" "FAIL" "Configuration file not found"
    fi
    
    # Check health check script
    if [[ -f "$sample_dir/health-check.sh" ]]; then
        if [[ -x "$sample_dir/health-check.sh" ]]; then
            log_test_result "Health Check Script" "PASS" "Script exists and is executable"
        else
            log_test_result "Health Check Script" "WARN" "Script exists but is not executable"
        fi
    else
        log_test_result "Health Check Script" "FAIL" "Health check script not found"
    fi
    
    # Check deployment script
    if [[ -f "$sample_dir/deploy.sh" ]]; then
        if [[ -x "$sample_dir/deploy.sh" ]]; then
            log_test_result "Sample Deploy Script" "PASS" "Script exists and is executable"
        else
            log_test_result "Sample Deploy Script" "WARN" "Script exists but is not executable"
        fi
    else
        log_test_result "Sample Deploy Script" "FAIL" "Deploy script not found"
    fi
}

# Performance tests
test_performance() {
    echo ""
    echo "⚡ Running performance tests..."
    
    if [[ -z "$CONTAINER_NAME" ]]; then
        log_test_result "Performance Tests" "SKIP" "No container name provided"
        return 0
    fi
    
    # Get container FQDN for testing
    CONTAINER_FQDN=$(az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CONTAINER_NAME" \
        --query ipAddress.fqdn -o tsv 2>/dev/null || echo "")
    
    if [[ -z "$CONTAINER_FQDN" || "$CONTAINER_FQDN" == "null" ]]; then
        log_test_result "Performance Tests" "SKIP" "No FQDN available for testing"
        return 0
    fi
    
    if ! command -v curl &> /dev/null; then
        log_test_result "Performance Tests" "SKIP" "curl not available"
        return 0
    fi
    
    # Response time test
    RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' "http://$CONTAINER_FQDN" 2>/dev/null || echo "0")
    RESPONSE_TIME_MS=$(echo "$RESPONSE_TIME * 1000" | bc 2>/dev/null || echo "0")
    
    if (( $(echo "$RESPONSE_TIME_MS < 2000" | bc -l 2>/dev/null || echo 0) )); then
        log_test_result "Response Time" "PASS" "Response time: ${RESPONSE_TIME_MS}ms"
    elif (( $(echo "$RESPONSE_TIME_MS < 5000" | bc -l 2>/dev/null || echo 0) )); then
        log_test_result "Response Time" "WARN" "Response time: ${RESPONSE_TIME_MS}ms (slow)"
    else
        log_test_result "Response Time" "FAIL" "Response time: ${RESPONSE_TIME_MS}ms (too slow)"
    fi
    
    # Concurrent requests test (simple)
    local concurrent_requests=5
    local success_count=0
    
    for i in $(seq 1 $concurrent_requests); do
        if curl -f -s --max-time 10 "http://$CONTAINER_FQDN" > /dev/null 2>&1 &; then
            success_count=$((success_count + 1))
        fi
    done
    
    wait
    
    if [[ $success_count -eq $concurrent_requests ]]; then
        log_test_result "Concurrent Requests" "PASS" "All $concurrent_requests requests successful"
    elif [[ $success_count -gt 0 ]]; then
        log_test_result "Concurrent Requests" "WARN" "$success_count/$concurrent_requests requests successful"
    else
        log_test_result "Concurrent Requests" "FAIL" "No successful concurrent requests"
    fi
}

# Main test execution
main() {
    echo "Starting test execution at $(date)"
    
    # Always check prerequisites
    if ! check_prerequisites; then
        echo "❌ Prerequisites check failed. Cannot continue."
        exit 1
    fi
    
    case "$TEST_TYPE" in
        "all")
            test_azure_resources
            test_deployment_scripts
            test_templates
            test_sample_application
            test_container_deployment
            test_performance
            ;;
        "azure")
            test_azure_resources
            ;;
        "scripts")
            test_deployment_scripts
            ;;
        "templates")
            test_templates
            ;;
        "sample")
            test_sample_application
            ;;
        "container")
            test_container_deployment
            ;;
        "performance")
            test_performance
            ;;
        *)
            echo "❌ Unknown test type: $TEST_TYPE"
            echo "Available test types: all, azure, scripts, templates, sample, container, performance"
            exit 1
            ;;
    esac
    
    # Test summary
    echo ""
    echo "📊 Test Summary"
    echo "==============="
    echo "Tests Passed: $TESTS_PASSED"
    echo "Tests Failed: $TESTS_FAILED"
    echo "Tests Skipped: $TESTS_SKIPPED"
    echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo "✅ All tests passed successfully!"
        exit 0
    elif [[ $TESTS_FAILED -le 2 ]]; then
        echo "⚠️  Some tests failed. Please review the results."
        exit 1
    else
        echo "❌ Multiple test failures detected. Please investigate."
        exit 1
    fi
}

# Execute main function
main "$@"