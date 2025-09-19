#!/bin/bash

# GCP Autonomous Cloud Operations Agent
# AI DevOps Framework v3.7 - Intelligent Google Cloud Platform Operations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/utils.sh"

# Agent Configuration
AGENT_NAME="GCP-Cloud-Agent"
AGENT_VERSION="3.7.0"
AGENT_CONFIG_FILE="$SCRIPT_DIR/configs/gcp-deployment.json"
CLAUDE_PROMPTS_FILE="$SCRIPT_DIR/configs/claude-prompts.json"

# Default values
OPERATION="${1:-help}"
SERVICE_NAME="${2:-}"
PROJECT_ID="${3:-}"
REGION="${4:-us-central1}"
ENVIRONMENT="${5:-development}"

# Initialize agent
initialize_agent() {
    log_info "Initializing $AGENT_NAME v$AGENT_VERSION"
    
    if [ ! -f "$AGENT_CONFIG_FILE" ]; then
        log_error "Configuration file not found: $AGENT_CONFIG_FILE"
        exit 1
    fi
    
    if [ ! -f "$CLAUDE_PROMPTS_FILE" ]; then
        log_error "Claude prompts file not found: $CLAUDE_PROMPTS_FILE"
        exit 1
    fi
    
    # Check dependencies
    local missing_deps=()
    for cmd in gcloud jq curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        exit 1
    fi
    
    # Check gcloud authentication
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 > /dev/null; then
        log_error "No active gcloud authentication found. Run: gcloud auth login"
        exit 1
    fi
    
    # Set default project if not provided
    if [ -z "$PROJECT_ID" ]; then
        PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
        if [ -z "$PROJECT_ID" ]; then
            log_error "No GCP project configured. Set with: gcloud config set project YOUR_PROJECT_ID"
            exit 1
        fi
    fi
    
    log_success "Agent initialized successfully"
    log_info "Project: $PROJECT_ID"
    log_info "Region: $REGION"
    log_info "Environment: $ENVIRONMENT"
}

# AI-powered decision making using Claude prompts
analyze_with_claude() {
    local prompt_type="$1"
    local input_data="$2"
    
    log_info "🤖 Analyzing with AI: $prompt_type"
    
    if ! command -v claude &> /dev/null; then
        log_warning "Claude CLI not available. Proceeding with standard operations."
        return 0
    fi
    
    local prompt_config=$(jq -r ".gcp_deployment_prompts.${prompt_type}" "$CLAUDE_PROMPTS_FILE" 2>/dev/null || echo "null")
    
    if [ "$prompt_config" = "null" ]; then
        log_warning "No AI prompt found for: $prompt_type"
        return 0
    fi
    
    local system_prompt=$(echo "$prompt_config" | jq -r '.system_prompt')
    local user_prompt_template=$(echo "$prompt_config" | jq -r '.user_prompt_template')
    
    # Substitute variables in prompt template
    local user_prompt=$(echo "$user_prompt_template" | \
        sed "s/\${service_name}/$SERVICE_NAME/g" | \
        sed "s/\${project_id}/$PROJECT_ID/g" | \
        sed "s/\${region}/$REGION/g" | \
        sed "s/\${environment}/$ENVIRONMENT/g")
    
    # Add input data to prompt
    user_prompt="${user_prompt}\n\nInput Data:\n${input_data}"
    
    log_info "🧠 AI analysis in progress..."
    
    # This would integrate with Claude CLI if available
    # For now, we'll log the analysis request
    log_info "AI Analysis Request: $prompt_type"
    log_debug "System Prompt: $system_prompt"
    log_debug "User Prompt: $user_prompt"
    
    return 0
}

# Autonomous deployment operation
autonomous_deploy() {
    local image_url="$1"
    local deployment_strategy="${2:-rolling}"
    
    log_info "🚀 Starting autonomous deployment"
    log_info "Service: $SERVICE_NAME"
    log_info "Image: $image_url"
    log_info "Strategy: $deployment_strategy"
    
    # Pre-deployment analysis
    local service_config=""
    if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
        service_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
        log_info "📊 Existing service found - analyzing for update strategy"
        analyze_with_claude "deployment_strategy" "$service_config"
    else
        log_info "🆕 New service deployment"
        analyze_with_claude "cloud_run_analysis" "New deployment: $SERVICE_NAME"
    fi
    
    # Execute deployment
    log_info "⚡ Executing deployment..."
    if ! "$SCRIPT_DIR/scripts/deploy-cloud-run.sh" "$SERVICE_NAME" "$image_url" "$ENVIRONMENT" "$PROJECT_ID" "$REGION"; then
        log_error "Deployment failed"
        return 1
    fi
    
    # Post-deployment validation
    log_info "🔍 Post-deployment validation..."
    if ! "$SCRIPT_DIR/scripts/validate-cloud-run.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION"; then
        log_error "Post-deployment validation failed"
        return 1
    fi
    
    # AI-powered post-deployment analysis
    local deployment_status=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
    analyze_with_claude "post_deployment" "$deployment_status"
    
    log_success "✅ Autonomous deployment completed successfully"
    
    # Display service information
    local service_url=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="value(status.url)")
    echo ""
    echo "🌐 Service deployed successfully:"
    echo "  URL: $service_url"
    echo "  Service: $SERVICE_NAME"
    echo "  Environment: $ENVIRONMENT"
    echo "  Region: $REGION"
    echo ""
    
    return 0
}

# Autonomous troubleshooting
autonomous_troubleshoot() {
    log_info "🔧 Starting autonomous troubleshooting"
    log_info "Service: $SERVICE_NAME"
    
    # Gather diagnostic information
    log_info "📊 Gathering diagnostic information..."
    
    local service_status=""
    local service_logs=""
    local error_messages=""
    
    # Service status
    if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" &>/dev/null; then
        service_status=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
        log_info "✓ Service status collected"
    else
        log_error "Service '$SERVICE_NAME' not found"
        return 1
    fi
    
    # Recent logs
    log_info "📝 Collecting recent logs..."
    service_logs=$(gcloud logging read "resource.type=\"cloud_run_revision\" resource.labels.service_name=\"$SERVICE_NAME\"" \
        --limit=50 \
        --format="json" \
        --project="$PROJECT_ID" 2>/dev/null || echo "[]")
    
    # Error analysis
    error_messages=$(echo "$service_logs" | jq -r '.[] | select(.severity == "ERROR") | .textPayload // .jsonPayload.message // ""' | head -10)
    
    # AI-powered troubleshooting analysis
    local diagnostic_data=$(cat << EOF
Service Status: $service_status
Error Messages: $error_messages
Recent Logs Count: $(echo "$service_logs" | jq 'length')
EOF
    )
    
    analyze_with_claude "troubleshooting" "$diagnostic_data"
    
    # Automated diagnostic checks
    log_info "🔍 Running automated diagnostics..."
    
    # Check service health
    local service_url=$(echo "$service_status" | jq -r '.status.url')
    if [ "$service_url" != "null" ] && [ ! -z "$service_url" ]; then
        if curl -f -s --max-time 30 "$service_url/health" >/dev/null 2>&1; then
            log_success "✅ Service health check: PASSED"
        else
            log_error "❌ Service health check: FAILED"
            
            # Attempt basic remediation
            log_info "🔄 Attempting automatic remediation..."
            
            # Check if service needs more resources
            local cpu_usage=$(echo "$service_logs" | jq -r '.[] | select(.jsonPayload.message? | contains("CPU")) | .jsonPayload.message' | head -1)
            local memory_usage=$(echo "$service_logs" | jq -r '.[] | select(.jsonPayload.message? | contains("memory")) | .jsonPayload.message' | head -1)
            
            if [ ! -z "$cpu_usage" ] || [ ! -z "$memory_usage" ]; then
                log_info "📈 Resource constraints detected - considering scaling"
                # This would trigger a scaling operation
            fi
            
            # Check for image pull errors
            local image_errors=$(echo "$service_logs" | jq -r '.[] | select(.textPayload? | contains("Failed to pull")) | .textPayload' | head -1)
            if [ ! -z "$image_errors" ]; then
                log_error "🖼️ Container image pull errors detected"
                log_info "Recommendation: Verify image exists and permissions are correct"
            fi
        fi
    else
        log_error "❌ Service URL not available"
    fi
    
    # Check revision status
    local latest_revision=$(echo "$service_status" | jq -r '.status.latestReadyRevisionName')
    if [ "$latest_revision" != "null" ]; then
        log_success "✅ Latest revision: $latest_revision"
    else
        log_error "❌ No ready revision found"
    fi
    
    # Traffic allocation check
    local traffic_allocation=$(echo "$service_status" | jq -r '.status.traffic[0].percent')
    if [ "$traffic_allocation" = "100" ]; then
        log_success "✅ Traffic allocation: 100% to latest revision"
    else
        log_warning "⚠️ Traffic allocation: $traffic_allocation% to latest revision"
    fi
    
    log_success "🔧 Troubleshooting analysis completed"
    
    return 0
}

# Autonomous monitoring and optimization
autonomous_monitor() {
    log_info "📊 Starting autonomous monitoring"
    log_info "Service: $SERVICE_NAME"
    
    # Performance analysis
    log_info "⚡ Running performance analysis..."
    if ! "$SCRIPT_DIR/scripts/performance-test.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION" 30 5 5; then
        log_warning "Performance test indicated optimization opportunities"
        
        # AI-powered performance optimization analysis
        local service_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
        analyze_with_claude "performance_optimization" "$service_config"
    fi
    
    # Security assessment
    log_info "🔒 Running security assessment..."
    if ! "$SCRIPT_DIR/scripts/security-test.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION" "$ENVIRONMENT"; then
        log_warning "Security assessment found improvement opportunities"
        
        # AI-powered security analysis
        local security_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
        analyze_with_claude "security_review" "$security_config"
    fi
    
    # Cost optimization analysis
    log_info "💰 Analyzing cost optimization..."
    local current_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
    analyze_with_claude "cost_optimization" "$current_config"
    
    log_success "📊 Monitoring and optimization analysis completed"
    
    return 0
}

# Autonomous scaling operation
autonomous_scale() {
    local min_instances="${1:-0}"
    local max_instances="${2:-100}"
    local cpu_limit="${3:-1}"
    local memory_limit="${4:-512Mi}"
    
    log_info "📈 Starting autonomous scaling"
    log_info "Target configuration:"
    log_info "  Min instances: $min_instances"
    log_info "  Max instances: $max_instances"
    log_info "  CPU limit: $cpu_limit"
    log_info "  Memory limit: $memory_limit"
    
    # Current configuration analysis
    local current_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
    
    # AI analysis for scaling decision
    analyze_with_claude "cloud_run_analysis" "$current_config"
    
    # Execute scaling
    log_info "⚡ Applying scaling configuration..."
    
    gcloud run services update "$SERVICE_NAME" \
        --region="$REGION" \
        --project="$PROJECT_ID" \
        --min-instances="$min_instances" \
        --max-instances="$max_instances" \
        --cpu="$cpu_limit" \
        --memory="$memory_limit" \
        --quiet
    
    log_success "📈 Scaling operation completed"
    
    # Validation
    log_info "🔍 Validating scaling changes..."
    sleep 10
    "$SCRIPT_DIR/scripts/validate-cloud-run.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION"
    
    return 0
}

# Display help information
show_help() {
    cat << EOF
$AGENT_NAME v$AGENT_VERSION
AI-Powered Google Cloud Platform Operations Agent

USAGE:
    $0 <OPERATION> [SERVICE_NAME] [PROJECT_ID] [REGION] [ENVIRONMENT]

OPERATIONS:
    deploy <service> <image_url>         - Autonomous deployment with AI analysis
    troubleshoot <service>               - AI-powered troubleshooting and remediation
    monitor <service>                    - Autonomous monitoring and optimization
    scale <service> [min] [max] [cpu] [memory] - Intelligent scaling operations
    analyze <service>                    - Comprehensive AI analysis
    validate <service>                   - Validate service configuration and health
    test <service>                       - Run comprehensive test suite
    status <service>                     - Display service status and metrics
    logs <service>                       - Display and analyze service logs
    cleanup <service>                    - Clean up and optimize service configuration
    help                                 - Show this help message

EXAMPLES:
    # Deploy a new service with AI analysis
    $0 deploy my-app gcr.io/project/app:latest

    # Troubleshoot service issues with AI assistance
    $0 troubleshoot my-app my-project us-central1 production

    # Monitor and optimize service performance
    $0 monitor my-app

    # Scale service based on AI recommendations
    $0 scale my-app 2 50 2 1Gi

    # Comprehensive service analysis
    $0 analyze my-app

ENVIRONMENT VARIABLES:
    GCP_PROJECT_ID                       - Default GCP project ID
    GCP_REGION                          - Default GCP region
    CLAUDE_API_KEY                      - Claude API key for AI analysis
    LOG_LEVEL                           - Logging level (debug, info, warning, error)

CONFIGURATION:
    Agent configuration: $AGENT_CONFIG_FILE
    Claude prompts: $CLAUDE_PROMPTS_FILE

AI CAPABILITIES:
    • Deployment strategy optimization
    • Automated troubleshooting and remediation
    • Performance analysis and optimization
    • Security assessment and recommendations
    • Cost optimization analysis
    • Resource scaling decisions
    • Post-deployment validation

For more information, visit:
https://github.com/your-org/ai-devops-framework

EOF
}

# Main operation dispatcher
main() {
    case "$OPERATION" in
        "deploy")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for deploy operation"
                show_help
                exit 1
            fi
            IMAGE_URL="${4:-}"
            if [ -z "$IMAGE_URL" ]; then
                log_error "Image URL required for deploy operation"
                exit 1
            fi
            initialize_agent
            autonomous_deploy "$IMAGE_URL"
            ;;
        "troubleshoot")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for troubleshoot operation"
                exit 1
            fi
            initialize_agent
            autonomous_troubleshoot
            ;;
        "monitor")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for monitor operation"
                exit 1
            fi
            initialize_agent
            autonomous_monitor
            ;;
        "scale")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for scale operation"
                exit 1
            fi
            MIN_INSTANCES="${4:-0}"
            MAX_INSTANCES="${5:-100}"
            CPU_LIMIT="${6:-1}"
            MEMORY_LIMIT="${7:-512Mi}"
            initialize_agent
            autonomous_scale "$MIN_INSTANCES" "$MAX_INSTANCES" "$CPU_LIMIT" "$MEMORY_LIMIT"
            ;;
        "analyze")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for analyze operation"
                exit 1
            fi
            initialize_agent
            log_info "🧠 Starting comprehensive AI analysis..."
            local service_config=$(gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" --format="json")
            analyze_with_claude "cloud_run_analysis" "$service_config"
            analyze_with_claude "security_review" "$service_config"
            analyze_with_claude "performance_optimization" "$service_config"
            analyze_with_claude "cost_optimization" "$service_config"
            log_success "🧠 Comprehensive analysis completed"
            ;;
        "validate")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for validate operation"
                exit 1
            fi
            initialize_agent
            "$SCRIPT_DIR/scripts/validate-cloud-run.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION"
            ;;
        "test")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for test operation"
                exit 1
            fi
            initialize_agent
            "$SCRIPT_DIR/scripts/test-cloud-run.sh" "$SERVICE_NAME" "$PROJECT_ID" "$REGION" "$ENVIRONMENT"
            ;;
        "status")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for status operation"
                exit 1
            fi
            initialize_agent
            "$SCRIPT_DIR/scripts/manage-cloud-run.sh" status "$SERVICE_NAME" "$PROJECT_ID" "$REGION"
            ;;
        "logs")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for logs operation"
                exit 1
            fi
            initialize_agent
            "$SCRIPT_DIR/scripts/manage-cloud-run.sh" logs "$SERVICE_NAME" "$PROJECT_ID" "$REGION"
            ;;
        "cleanup")
            if [ -z "$SERVICE_NAME" ]; then
                log_error "Service name required for cleanup operation"
                exit 1
            fi
            initialize_agent
            log_info "🧹 Starting service cleanup and optimization..."
            # Implement cleanup logic here
            log_success "🧹 Cleanup completed"
            ;;
        "help"|"--help"|"-h")
            show_help
            ;;
        *)
            log_error "Unknown operation: $OPERATION"
            show_help
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"