#!/bin/bash

# Azure Cloud Agent - Autonomous Azure Operations
# Specialized agent for deployment, troubleshooting, and log analysis

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$(dirname "$(dirname "$AZURE_DIR")")/agents"

echo "🤖 Azure Cloud Agent"
echo "==================="
echo "Autonomous Azure operations with AI-powered decision making"
echo ""

# Parse command line arguments
OPERATION="${1:-help}"
CONTEXT="${2:-}"
PARAMETERS="${3:-}"

# Agent configuration
AGENT_ID="azure-cloud-agent-$(date +%s)"
WORK_DIR="/tmp/azure-agent-$AGENT_ID"
mkdir -p "$WORK_DIR"

# Cleanup function
cleanup() {
    rm -rf "$WORK_DIR"
}
trap cleanup EXIT

# Logging functions
log_info() {
    echo "🔵 [INFO] $1"
}

log_success() {
    echo "✅ [SUCCESS] $1"
}

log_warning() {
    echo "⚠️  [WARNING] $1"
}

log_error() {
    echo "❌ [ERROR] $1"
}

log_action() {
    echo "🔧 [ACTION] $1"
}

# Agent activation check
check_agent_prerequisites() {
    log_info "Checking Azure Cloud Agent prerequisites..."
    
    local issues=0
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        log_error "Azure CLI not found"
        issues=$((issues + 1))
    else
        log_success "Azure CLI available"
    fi
    
    # Check Azure authentication
    if ! az account show > /dev/null 2>&1; then
        log_error "Not authenticated with Azure"
        issues=$((issues + 1))
    else
        local subscription=$(az account show --query name -o tsv)
        log_success "Azure authenticated (Subscription: $subscription)"
    fi
    
    # Check framework components
    if [[ ! -d "$AZURE_DIR" ]]; then
        log_error "Azure framework not found at $AZURE_DIR"
        issues=$((issues + 1))
    else
        log_success "Azure framework available"
    fi
    
    # Check required tools
    local tools=("jq" "curl")
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            log_warning "$tool not found - some features may be limited"
        else
            log_success "$tool available"
        fi
    done
    
    if [[ $issues -gt 0 ]]; then
        log_error "Agent prerequisites not met. Cannot proceed."
        return 1
    fi
    
    log_success "All prerequisites met. Agent ready for operations."
    return 0
}

# AI-powered decision making
make_ai_decision() {
    local prompt_type="$1"
    local context_data="$2"
    
    log_info "Making AI-powered decision for: $prompt_type"
    
    # Load prompt template
    local prompt_file="$AZURE_DIR/configs/claude-prompts.json"
    if [[ -f "$prompt_file" ]]; then
        local prompt_template=$(jq -r ".azure_deployment_prompts.$prompt_type.user_prompt_template // empty" "$prompt_file" 2>/dev/null)
        
        if [[ -n "$prompt_template" ]]; then
            # Replace template variables with context data
            local prompt=$(echo "$prompt_template" | sed "s/\{context\}/$context_data/g")
            
            # Check if Claude CLI is available
            if command -v claude &> /dev/null; then
                log_action "Consulting Claude AI for decision..."
                local decision=$(echo "$prompt" | claude --max-tokens 500 2>/dev/null || echo "")
                
                if [[ -n "$decision" ]]; then
                    log_success "AI decision received"
                    echo "$decision" > "$WORK_DIR/ai-decision.txt"
                    echo "$decision"
                    return 0
                fi
            fi
        fi
    fi
    
    log_warning "AI decision not available, using built-in logic"
    return 1
}

# Container deployment operation
deploy_container() {
    local app_name="${1:-simple-app}"
    local image="${2:-nginx:latest}"
    local environment="${3:-development}"
    local resource_group="${4:-rg-containers}"
    local location="${5:-East US}"
    
    log_info "Starting container deployment operation"
    log_info "Application: $app_name, Image: $image, Environment: $environment"
    
    # AI analysis for deployment strategy
    local context="{\"app\":\"$app_name\",\"image\":\"$image\",\"env\":\"$environment\"}"
    make_ai_decision "deployment_strategy" "$context" > "$WORK_DIR/strategy.txt"
    
    # Execute deployment
    log_action "Executing deployment using framework scripts..."
    if "$SCRIPT_DIR/deploy-docker-container.sh" "$app_name" "$image" "$environment" "$resource_group" "$location"; then
        log_success "Container deployment completed successfully"
        
        # Post-deployment validation
        log_action "Running post-deployment validation..."
        if "$SCRIPT_DIR/validate-deployment.sh" "$resource_group" "$app_name"; then
            log_success "Deployment validation passed"
            
            # Get deployment details
            local fqdn=$(az container show --resource-group "$resource_group" --name "$app_name" --query ipAddress.fqdn -o tsv 2>/dev/null || echo "")
            local ip=$(az container show --resource-group "$resource_group" --name "$app_name" --query ipAddress.ip -o tsv 2>/dev/null || echo "")
            
            # Generate deployment report
            cat > "$WORK_DIR/deployment-report.json" << EOF
{
  "operation_id": "$AGENT_ID",
  "status": "success",
  "deployment": {
    "app_name": "$app_name",
    "image": "$image",
    "environment": "$environment",
    "resource_group": "$resource_group",
    "location": "$location"
  },
  "results": {
    "fqdn": "$fqdn",
    "ip": "$ip",
    "http_url": "http://$fqdn",
    "health_url": "http://$fqdn/health"
  },
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
            
            log_success "Deployment report generated: $WORK_DIR/deployment-report.json"
            
            if [[ -n "$fqdn" ]]; then
                echo ""
                echo "🌐 Application Access:"
                echo "   HTTP URL: http://$fqdn"
                echo "   Health Check: http://$fqdn/health"
                echo "   Public IP: $ip"
            fi
            
            return 0
        else
            log_error "Deployment validation failed"
            return 1
        fi
    else
        log_error "Container deployment failed"
        return 1
    fi
}

# Sample application deployment
deploy_sample() {
    log_info "Deploying sample web application"
    
    if [[ -d "$AZURE_DIR/samples/simple-web-app" ]]; then
        cd "$AZURE_DIR/samples/simple-web-app"
        
        log_action "Using sample application deployment script..."
        if ./deploy.sh; then
            log_success "Sample application deployed successfully"
            return 0
        else
            log_error "Sample application deployment failed"
            return 1
        fi
    else
        log_error "Sample application not found"
        return 1
    fi
}

# Troubleshooting operation
troubleshoot_deployment() {
    local resource_group="${1:-rg-containers}"
    local container_name="${2:-}"
    
    if [[ -z "$container_name" ]]; then
        log_error "Container name required for troubleshooting"
        return 1
    fi
    
    log_info "Starting troubleshooting operation for $container_name"
    
    # Collect diagnostic data
    log_action "Collecting diagnostic information..."
    
    # Container status
    local container_state=$(az container show --resource-group "$resource_group" --name "$container_name" --query instanceView.state -o tsv 2>/dev/null || echo "Unknown")
    log_info "Container state: $container_state"
    
    # Container events
    local events=$(az container show --resource-group "$resource_group" --name "$container_name" --query instanceView.events -o json 2>/dev/null || echo "[]")
    echo "$events" > "$WORK_DIR/events.json"
    
    # Container logs
    local logs=$(az container logs --resource-group "$resource_group" --name "$container_name" --tail 50 2>/dev/null || echo "No logs available")
    echo "$logs" > "$WORK_DIR/logs.txt"
    
    # AI-powered troubleshooting
    local context="{\"state\":\"$container_state\",\"events\":$(echo "$events" | jq -c .),\"logs\":\"$(echo "$logs" | head -10 | tr '\n' ' ')\"}"
    make_ai_decision "troubleshooting" "$context" > "$WORK_DIR/ai-diagnosis.txt"
    
    # Generate troubleshooting report
    cat > "$WORK_DIR/troubleshooting-report.md" << EOF
# Troubleshooting Report
**Container**: $container_name  
**Resource Group**: $resource_group  
**Timestamp**: $(date)

## Container Status
- **State**: $container_state
- **Events**: $(echo "$events" | jq length) events recorded

## Recent Logs
\`\`\`
$(echo "$logs" | head -20)
\`\`\`

## AI Analysis
$(cat "$WORK_DIR/ai-diagnosis.txt" 2>/dev/null || echo "AI analysis not available")

## Recommended Actions
1. Check container logs for specific error messages
2. Verify image availability and registry authentication
3. Review resource allocation and limits
4. Test network connectivity and DNS resolution
5. Validate environment variables and configuration

## Useful Commands
\`\`\`bash
# View full logs
az container logs --resource-group $resource_group --name $container_name

# Restart container
az container restart --resource-group $resource_group --name $container_name

# Check resource usage
az container show --resource-group $resource_group --name $container_name --query containers[0].resources
\`\`\`
EOF
    
    log_success "Troubleshooting report generated: $WORK_DIR/troubleshooting-report.md"
    cat "$WORK_DIR/troubleshooting-report.md"
    
    return 0
}

# Log analysis operation
analyze_logs() {
    local resource_group="${1:-rg-containers}"
    local container_name="${2:-}"
    local lines="${3:-100}"
    
    if [[ -z "$container_name" ]]; then
        log_error "Container name required for log analysis"
        return 1
    fi
    
    log_info "Starting log analysis for $container_name (last $lines lines)"
    
    # Collect logs
    log_action "Collecting container logs..."
    local logs=$(az container logs --resource-group "$resource_group" --name "$container_name" --tail "$lines" 2>/dev/null || echo "")
    
    if [[ -z "$logs" ]]; then
        log_warning "No logs available for analysis"
        return 1
    fi
    
    echo "$logs" > "$WORK_DIR/full-logs.txt"
    
    # Basic log analysis
    local error_count=$(echo "$logs" | grep -i error | wc -l)
    local warning_count=$(echo "$logs" | grep -i warning | wc -l)
    local total_lines=$(echo "$logs" | wc -l)
    
    # AI-powered log analysis
    local context="Container logs for analysis: $(echo "$logs" | head -20 | tr '\n' ' ')"
    make_ai_decision "troubleshooting" "$context" > "$WORK_DIR/log-analysis.txt"
    
    # Generate analysis report
    cat > "$WORK_DIR/log-analysis-report.md" << EOF
# Log Analysis Report
**Container**: $container_name  
**Resource Group**: $resource_group  
**Lines Analyzed**: $total_lines  
**Timestamp**: $(date)

## Summary Statistics
- **Total Lines**: $total_lines
- **Error Count**: $error_count
- **Warning Count**: $warning_count
- **Error Rate**: $(echo "scale=2; $error_count * 100 / $total_lines" | bc 2>/dev/null || echo "N/A")%

## Error Patterns
\`\`\`
$(echo "$logs" | grep -i error | head -10 || echo "No errors found")
\`\`\`

## Warning Patterns
\`\`\`
$(echo "$logs" | grep -i warning | head -10 || echo "No warnings found")
\`\`\`

## AI Analysis
$(cat "$WORK_DIR/log-analysis.txt" 2>/dev/null || echo "AI analysis not available")

## Recommendations
1. Monitor error patterns and implement error handling
2. Review warning messages for potential issues
3. Set up log aggregation and alerting
4. Implement structured logging for better analysis
5. Configure log retention and archival policies
EOF
    
    log_success "Log analysis report generated: $WORK_DIR/log-analysis-report.md"
    cat "$WORK_DIR/log-analysis-report.md"
    
    return 0
}

# Monitoring operation
monitor_deployment() {
    local resource_group="${1:-rg-containers}"
    local container_name="${2:-}"
    
    if [[ -z "$container_name" ]]; then
        log_error "Container name required for monitoring"
        return 1
    fi
    
    log_info "Starting monitoring operation for $container_name"
    
    # Get container details
    local container_details=$(az container show --resource-group "$resource_group" --name "$container_name" 2>/dev/null || echo "{}")
    local state=$(echo "$container_details" | jq -r '.instanceView.state // "Unknown"')
    local restart_count=$(echo "$container_details" | jq -r '.instanceView.restartCount // 0')
    local cpu=$(echo "$container_details" | jq -r '.containers[0].resources.requests.cpu // "Unknown"')
    local memory=$(echo "$container_details" | jq -r '.containers[0].resources.requests.memoryInGB // "Unknown"')
    local ip=$(echo "$container_details" | jq -r '.ipAddress.ip // "Not assigned"')
    local fqdn=$(echo "$container_details" | jq -r '.ipAddress.fqdn // "Not assigned"')
    
    # Health check
    local health_status="Unknown"
    if [[ "$fqdn" != "Not assigned" ]]; then
        if curl -f -s --max-time 5 "http://$fqdn/health" > /dev/null 2>&1; then
            health_status="Healthy"
        else
            health_status="Unhealthy"
        fi
    fi
    
    # Generate monitoring report
    cat > "$WORK_DIR/monitoring-report.json" << EOF
{
  "container": "$container_name",
  "resource_group": "$resource_group",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "status": {
    "state": "$state",
    "health": "$health_status",
    "restart_count": $restart_count
  },
  "resources": {
    "cpu": "$cpu",
    "memory": "$memory"
  },
  "network": {
    "ip": "$ip",
    "fqdn": "$fqdn"
  },
  "urls": {
    "http": "http://$fqdn",
    "health": "http://$fqdn/health"
  }
}
EOF
    
    log_success "Monitoring report generated: $WORK_DIR/monitoring-report.json"
    
    echo ""
    echo "📊 Container Status:"
    echo "   State: $state"
    echo "   Health: $health_status"
    echo "   Restart Count: $restart_count"
    echo "   Resources: ${cpu} CPU, ${memory}GB Memory"
    echo "   Network: $ip ($fqdn)"
    
    return 0
}

# Testing operation
test_deployment() {
    local resource_group="${1:-rg-containers}"
    local container_name="${2:-}"
    
    log_info "Starting comprehensive testing operation"
    
    if [[ -n "$container_name" ]]; then
        log_action "Running deployment tests with container validation..."
        "$SCRIPT_DIR/test-deployment.sh" all "$resource_group" "$container_name"
    else
        log_action "Running framework validation tests..."
        "$SCRIPT_DIR/test-deployment.sh" all "$resource_group"
    fi
    
    # Claude integration test
    log_action "Running Claude integration tests..."
    "$SCRIPT_DIR/claude-integration-test.sh" simulation
    
    return $?
}

# Agent operation dispatcher
dispatch_operation() {
    local operation="$1"
    shift
    
    case "$operation" in
        "deploy")
            deploy_container "$@"
            ;;
        "deploy-sample")
            deploy_sample "$@"
            ;;
        "troubleshoot")
            troubleshoot_deployment "$@"
            ;;
        "analyze-logs")
            analyze_logs "$@"
            ;;
        "monitor")
            monitor_deployment "$@"
            ;;
        "test")
            test_deployment "$@"
            ;;
        "validate")
            local rg="${1:-rg-containers}"
            local name="${2:-simple-app}"
            "$SCRIPT_DIR/validate-deployment.sh" "$rg" "$name"
            ;;
        "cleanup")
            local rg="${1:-rg-containers}"
            local name="${2:-}"
            if [[ -n "$name" ]]; then
                "$SCRIPT_DIR/cleanup-containers.sh" delete "$rg" "$name"
            else
                "$SCRIPT_DIR/cleanup-containers.sh" list "$rg"
            fi
            ;;
        "help"|*)
            show_help
            ;;
    esac
}

# Help function
show_help() {
    cat << EOF
🤖 Azure Cloud Agent - Autonomous Azure Operations

USAGE:
    ./azure-agent.sh <operation> [parameters...]

OPERATIONS:
    deploy <name> <image> <env> <rg> <location>    Deploy container to Azure
    deploy-sample                                  Deploy sample web application
    troubleshoot <resource-group> <container>      Troubleshoot deployment issues
    analyze-logs <resource-group> <container>      Analyze container logs
    monitor <resource-group> <container>           Monitor container status
    test [resource-group] [container]              Run comprehensive tests
    validate <resource-group> <container>          Validate deployment
    cleanup <resource-group> [container]           Clean up resources
    help                                           Show this help

EXAMPLES:
    # Deploy simple nginx container
    ./azure-agent.sh deploy my-app nginx:latest development

    # Deploy sample application
    ./azure-agent.sh deploy-sample

    # Troubleshoot a deployment
    ./azure-agent.sh troubleshoot rg-containers my-app

    # Analyze container logs
    ./azure-agent.sh analyze-logs rg-containers my-app

    # Monitor container status
    ./azure-agent.sh monitor rg-containers my-app

    # Run comprehensive tests
    ./azure-agent.sh test rg-containers my-app

    # Validate deployment
    ./azure-agent.sh validate rg-containers my-app

    # Clean up container
    ./azure-agent.sh cleanup rg-containers my-app

FEATURES:
    ✅ AI-powered decision making using Claude
    ✅ Autonomous deployment and troubleshooting
    ✅ Comprehensive testing and validation
    ✅ Log analysis and monitoring
    ✅ Integration with .ai_devops/azure framework
    ✅ Detailed reporting and documentation

REQUIREMENTS:
    - Azure CLI authenticated (az login)
    - .ai_devops/azure framework available
    - Basic tools: jq, curl
    - Optional: Claude CLI for AI decisions

The agent uses the existing .ai_devops/azure framework and can operate
autonomously with minimal human intervention.
EOF
}

# Main execution
main() {
    log_info "Azure Cloud Agent starting (ID: $AGENT_ID)"
    
    # Check prerequisites
    if ! check_agent_prerequisites; then
        exit 1
    fi
    
    echo ""
    
    # Dispatch operation
    dispatch_operation "$OPERATION" "$CONTEXT" "$PARAMETERS"
    local exit_code=$?
    
    echo ""
    if [[ $exit_code -eq 0 ]]; then
        log_success "Agent operation completed successfully"
        
        # Show work directory contents
        if [[ -n "$(ls -A "$WORK_DIR" 2>/dev/null)" ]]; then
            echo ""
            log_info "Generated artifacts in: $WORK_DIR"
            ls -la "$WORK_DIR" 2>/dev/null || true
        fi
    else
        log_error "Agent operation failed with exit code: $exit_code"
    fi
    
    return $exit_code
}

# Execute main function
main "$@"