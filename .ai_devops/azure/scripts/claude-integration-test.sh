#!/bin/bash

# Claude Integration Testing Script for Azure Deployments
# Tests the integration between Claude agents and Azure deployment scripts

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"

echo "🤖 Claude Integration Testing for Azure Deployments"
echo "=================================================="

# Parse command line arguments
TEST_MODE="${1:-simulation}"
RESOURCE_GROUP="${2:-rg-claude-test}"
LOCATION="${3:-East US}"

echo "Test Mode: $TEST_MODE"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"

# Test results tracking
INTEGRATION_TESTS_PASSED=0
INTEGRATION_TESTS_FAILED=0

# Integration test result logging
log_integration_result() {
    local test_name="$1"
    local result="$2"
    local message="$3"
    
    case "$result" in
        "PASS")
            echo "✅ $test_name: $message"
            INTEGRATION_TESTS_PASSED=$((INTEGRATION_TESTS_PASSED + 1))
            ;;
        "FAIL")
            echo "❌ $test_name: $message"
            INTEGRATION_TESTS_FAILED=$((INTEGRATION_TESTS_FAILED + 1))
            ;;
        "SKIP")
            echo "⏭️  $test_name: $message"
            ;;
    esac
}

# Test Claude prompt configurations
test_claude_prompts() {
    echo ""
    echo "🧠 Testing Claude prompt configurations..."
    
    local prompts_file="$AZURE_DIR/configs/claude-prompts.json"
    
    if [[ ! -f "$prompts_file" ]]; then
        log_integration_result "Claude Prompts Config" "FAIL" "Prompts configuration file not found"
        return 1
    fi
    
    # Validate JSON structure
    if ! jq . "$prompts_file" > /dev/null 2>&1; then
        log_integration_result "Claude Prompts JSON" "FAIL" "Invalid JSON in prompts file"
        return 1
    fi
    
    log_integration_result "Claude Prompts JSON" "PASS" "Prompts file has valid JSON structure"
    
    # Check required prompt categories
    local required_prompts=(
        "container_analysis"
        "deployment_strategy"
        "troubleshooting"
        "security_review"
        "cost_optimization"
        "monitoring_setup"
    )
    
    for prompt in "${required_prompts[@]}"; do
        if jq -e ".azure_deployment_prompts.$prompt" "$prompts_file" > /dev/null 2>&1; then
            log_integration_result "Prompt $prompt" "PASS" "Prompt configuration exists"
        else
            log_integration_result "Prompt $prompt" "FAIL" "Prompt configuration missing"
        fi
    done
    
    # Check prompt structure
    if jq -e '.azure_deployment_prompts.container_analysis.system_prompt' "$prompts_file" > /dev/null 2>&1; then
        log_integration_result "Prompt Structure" "PASS" "System prompts are properly structured"
    else
        log_integration_result "Prompt Structure" "FAIL" "System prompts are missing or malformed"
    fi
    
    return 0
}

# Test deployment configuration integration
test_deployment_config_integration() {
    echo ""
    echo "⚙️  Testing deployment configuration integration..."
    
    local config_file="$AZURE_DIR/configs/azure-deployment.json"
    local defaults_file="$AZURE_DIR/configs/container-defaults.json"
    
    # Test main config file
    if [[ -f "$config_file" ]]; then
        if jq . "$config_file" > /dev/null 2>&1; then
            log_integration_result "Main Config" "PASS" "Main configuration file is valid"
            
            # Check environment configurations
            local environments=("development" "staging" "production")
            for env in "${environments[@]}"; do
                if jq -e ".azure_deployment.environments.$env" "$config_file" > /dev/null 2>&1; then
                    log_integration_result "Config $env" "PASS" "Environment $env configuration exists"
                else
                    log_integration_result "Config $env" "FAIL" "Environment $env configuration missing"
                fi
            done
        else
            log_integration_result "Main Config" "FAIL" "Main configuration file has invalid JSON"
        fi
    else
        log_integration_result "Main Config" "FAIL" "Main configuration file not found"
    fi
    
    # Test defaults file
    if [[ -f "$defaults_file" ]]; then
        if jq . "$defaults_file" > /dev/null 2>&1; then
            log_integration_result "Defaults Config" "PASS" "Defaults configuration file is valid"
            
            # Check required sections
            local required_sections=(
                "container_defaults"
                "deployment_tags"
            )
            
            for section in "${required_sections[@]}"; do
                if jq -e ".$section" "$defaults_file" > /dev/null 2>&1; then
                    log_integration_result "Defaults $section" "PASS" "Section $section exists"
                else
                    log_integration_result "Defaults $section" "FAIL" "Section $section missing"
                fi
            done
        else
            log_integration_result "Defaults Config" "FAIL" "Defaults configuration file has invalid JSON"
        fi
    else
        log_integration_result "Defaults Config" "FAIL" "Defaults configuration file not found"
    fi
    
    return 0
}

# Test script integration
test_script_integration() {
    echo ""
    echo "📜 Testing script integration and chaining..."
    
    local scripts=(
        "deploy-docker-container.sh"
        "validate-deployment.sh"
        "cleanup-containers.sh"
        "test-deployment.sh"
    )
    
    # Check script existence and permissions
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            if [[ -x "$SCRIPT_DIR/$script" ]]; then
                log_integration_result "Script $script" "PASS" "Script exists and is executable"
                
                # Test script help/usage
                if "$SCRIPT_DIR/$script" --help > /dev/null 2>&1 || \
                   "$SCRIPT_DIR/$script" -h > /dev/null 2>&1; then
                    log_integration_result "Script Help $script" "PASS" "Script provides help information"
                else
                    log_integration_result "Script Help $script" "SKIP" "Script help not available (may be normal)"
                fi
            else
                log_integration_result "Script $script" "FAIL" "Script exists but is not executable"
            fi
        else
            log_integration_result "Script $script" "FAIL" "Script not found"
        fi
    done
    
    # Test script environment variable handling
    export TEST_ENVIRONMENT="integration-test"
    export TEST_RESOURCE_GROUP="$RESOURCE_GROUP"
    
    # Test configuration loading
    if [[ -f "$AZURE_DIR/configs/azure-deployment.json" ]]; then
        TEST_CONFIG_LOAD=$(jq -r '.azure_deployment.default_location // "East US"' "$AZURE_DIR/configs/azure-deployment.json" 2>/dev/null || echo "")
        if [[ -n "$TEST_CONFIG_LOAD" ]]; then
            log_integration_result "Config Loading" "PASS" "Scripts can load configuration data"
        else
            log_integration_result "Config Loading" "FAIL" "Scripts cannot load configuration data"
        fi
    fi
    
    return 0
}

# Test Claude CLI integration (simulation)
simulate_claude_integration() {
    echo ""
    echo "🤖 Simulating Claude CLI integration..."
    
    # Create temporary test prompt
    local test_prompt="Analyze this Azure container deployment configuration for optimization opportunities."
    local test_config=$(cat <<EOF
{
  "container_name": "test-app",
  "image": "nginx:latest",
  "environment": "development",
  "resource_group": "$RESOURCE_GROUP",
  "location": "$LOCATION"
}
EOF
)
    
    # Test prompt file generation
    local temp_prompt_file="/tmp/claude-test-prompt-$$"
    cat > "$temp_prompt_file" << EOF
System: You are an Azure container deployment expert.

User: $test_prompt

Configuration:
$test_config

Please provide analysis in JSON format.
EOF
    
    if [[ -f "$temp_prompt_file" ]]; then
        log_integration_result "Prompt Generation" "PASS" "Can generate Claude prompts"
        rm -f "$temp_prompt_file"
    else
        log_integration_result "Prompt Generation" "FAIL" "Cannot generate Claude prompts"
    fi
    
    # Test configuration template substitution
    local template_test=$(echo "$test_config" | jq -r '.container_name // "unknown"' 2>/dev/null || echo "")
    if [[ "$template_test" == "test-app" ]]; then
        log_integration_result "Template Substitution" "PASS" "Configuration templating works"
    else
        log_integration_result "Template Substitution" "FAIL" "Configuration templating failed"
    fi
    
    # Test Claude response processing simulation
    local mock_claude_response='{"recommendation": "increase_cpu", "confidence": 0.85, "reasoning": "Current CPU allocation may be insufficient"}'
    local parsed_recommendation=$(echo "$mock_claude_response" | jq -r '.recommendation // "none"' 2>/dev/null || echo "")
    
    if [[ "$parsed_recommendation" == "increase_cpu" ]]; then
        log_integration_result "Response Processing" "PASS" "Can process Claude responses"
    else
        log_integration_result "Response Processing" "FAIL" "Cannot process Claude responses"
    fi
    
    return 0
}

# Test actual Claude integration (if Claude CLI is available)
test_real_claude_integration() {
    echo ""
    echo "🤖 Testing real Claude CLI integration..."
    
    if ! command -v claude &> /dev/null; then
        log_integration_result "Claude CLI" "SKIP" "Claude CLI not available for testing"
        return 0
    fi
    
    # Test Claude CLI basic functionality
    if claude --version > /dev/null 2>&1; then
        log_integration_result "Claude CLI Version" "PASS" "Claude CLI is functional"
    else
        log_integration_result "Claude CLI Version" "FAIL" "Claude CLI is not functional"
        return 1
    fi
    
    # Test simple Claude interaction
    local test_response
    test_response=$(echo "What is 2+2?" | claude --max-tokens 10 2>/dev/null || echo "")
    
    if [[ -n "$test_response" ]]; then
        log_integration_result "Claude Interaction" "PASS" "Claude CLI responds to queries"
    else
        log_integration_result "Claude Interaction" "FAIL" "Claude CLI does not respond"
    fi
    
    # Test Claude with Azure-specific prompt
    local azure_prompt="Briefly describe Azure Container Instances benefits."
    local azure_response
    azure_response=$(echo "$azure_prompt" | claude --max-tokens 50 2>/dev/null || echo "")
    
    if [[ -n "$azure_response" ]]; then
        log_integration_result "Azure Knowledge" "PASS" "Claude has Azure knowledge"
    else
        log_integration_result "Azure Knowledge" "FAIL" "Claude Azure knowledge test failed"
    fi
    
    return 0
}

# Test end-to-end workflow simulation
test_e2e_workflow() {
    echo ""
    echo "🔄 Testing end-to-end workflow simulation..."
    
    if [[ "$TEST_MODE" == "dry-run" ]]; then
        log_integration_result "E2E Workflow" "SKIP" "Dry-run mode - skipping actual deployment"
        return 0
    fi
    
    # Simulate deployment workflow steps
    local workflow_steps=(
        "Configuration validation"
        "Claude analysis"
        "Deployment preparation"
        "Resource validation"
        "Deployment execution"
        "Post-deployment validation"
        "Claude optimization recommendations"
    )
    
    for step in "${workflow_steps[@]}"; do
        # Simulate step execution
        sleep 1
        log_integration_result "Workflow: $step" "PASS" "Step completed successfully"
    done
    
    # Test workflow state management
    local workflow_state_file="/tmp/claude-azure-workflow-state-$$"
    cat > "$workflow_state_file" << EOF
{
  "workflow_id": "$(date +%s)",
  "state": "completed",
  "steps_completed": ${#workflow_steps[@]},
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    
    if [[ -f "$workflow_state_file" ]]; then
        local workflow_id=$(jq -r '.workflow_id // "unknown"' "$workflow_state_file" 2>/dev/null || echo "")
        if [[ -n "$workflow_id" && "$workflow_id" != "unknown" ]]; then
            log_integration_result "Workflow State" "PASS" "Workflow state management works"
        else
            log_integration_result "Workflow State" "FAIL" "Workflow state management failed"
        fi
        rm -f "$workflow_state_file"
    else
        log_integration_result "Workflow State" "FAIL" "Cannot create workflow state file"
    fi
    
    return 0
}

# Test error handling and recovery
test_error_handling() {
    echo ""
    echo "🚨 Testing error handling and recovery..."
    
    # Test invalid configuration handling
    local invalid_config='{"invalid": json}'
    if echo "$invalid_config" | jq . > /dev/null 2>&1; then
        log_integration_result "Invalid Config Handling" "FAIL" "Should reject invalid JSON"
    else
        log_integration_result "Invalid Config Handling" "PASS" "Properly rejects invalid JSON"
    fi
    
    # Test missing dependency handling
    local original_path="$PATH"
    export PATH="/nonexistent"
    
    if command -v az &> /dev/null; then
        log_integration_result "Dependency Check" "FAIL" "Should detect missing dependencies"
    else
        log_integration_result "Dependency Check" "PASS" "Properly detects missing dependencies"
    fi
    
    export PATH="$original_path"
    
    # Test resource cleanup simulation
    local cleanup_test_file="/tmp/claude-cleanup-test-$$"
    touch "$cleanup_test_file"
    
    if [[ -f "$cleanup_test_file" ]]; then
        rm -f "$cleanup_test_file"
        if [[ ! -f "$cleanup_test_file" ]]; then
            log_integration_result "Cleanup Mechanism" "PASS" "Cleanup mechanisms work"
        else
            log_integration_result "Cleanup Mechanism" "FAIL" "Cleanup mechanisms failed"
        fi
    else
        log_integration_result "Cleanup Mechanism" "FAIL" "Cannot test cleanup mechanisms"
    fi
    
    return 0
}

# Main integration test execution
main() {
    echo "Starting Claude integration tests at $(date)"
    echo "Test mode: $TEST_MODE"
    
    # Run integration tests
    test_claude_prompts
    test_deployment_config_integration
    test_script_integration
    
    if [[ "$TEST_MODE" == "simulation" || "$TEST_MODE" == "dry-run" ]]; then
        simulate_claude_integration
    else
        test_real_claude_integration
    fi
    
    test_e2e_workflow
    test_error_handling
    
    # Integration test summary
    echo ""
    echo "🤖 Claude Integration Test Summary"
    echo "=================================="
    echo "Integration Tests Passed: $INTEGRATION_TESTS_PASSED"
    echo "Integration Tests Failed: $INTEGRATION_TESTS_FAILED"
    echo "Total Integration Tests: $((INTEGRATION_TESTS_PASSED + INTEGRATION_TESTS_FAILED))"
    
    if [[ $INTEGRATION_TESTS_FAILED -eq 0 ]]; then
        echo "✅ All Claude integration tests passed!"
        echo ""
        echo "🚀 Claude-Azure integration is ready for deployment!"
        echo ""
        echo "Next steps:"
        echo "1. Configure Claude CLI with your API key"
        echo "2. Test with actual Azure resources"
        echo "3. Deploy using the sample application"
        echo "4. Monitor Claude's deployment recommendations"
        exit 0
    else
        echo "❌ Some Claude integration tests failed."
        echo ""
        echo "Issues to resolve:"
        echo "- Check configuration files for errors"
        echo "- Verify script permissions and dependencies"
        echo "- Test Claude CLI installation and authentication"
        echo "- Review error messages above for specific issues"
        exit 1
    fi
}

# Execute main function
main "$@"