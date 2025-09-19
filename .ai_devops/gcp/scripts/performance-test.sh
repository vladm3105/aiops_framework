#!/bin/bash

# Cloud Run Performance Testing Script
# AI DevOps Framework v3.7 - Load testing and performance validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

SERVICE_NAME="${1:-}"
PROJECT_ID="${2:-}"
REGION="${3:-us-central1}"
TEST_DURATION="${4:-60}"
CONCURRENT_USERS="${5:-10}"
RAMP_UP_TIME="${6:-10}"

if [ -z "$SERVICE_NAME" ]; then
    echo "Error: SERVICE_NAME is required"
    echo "Usage: $0 <SERVICE_NAME> [PROJECT_ID] [REGION] [TEST_DURATION] [CONCURRENT_USERS] [RAMP_UP_TIME]"
    echo "Example: $0 simple-app my-project us-central1 60 10 10"
    exit 1
fi

if [ -z "$PROJECT_ID" ]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    if [ -z "$PROJECT_ID" ]; then
        echo "Error: PROJECT_ID not found. Set with: gcloud config set project YOUR_PROJECT_ID"
        exit 1
    fi
fi

# Check dependencies
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is required but not installed"
        return 1
    fi
}

log_info "Checking performance testing dependencies..."
check_command "curl" || exit 1
check_command "jq" || exit 1

# Get service URL
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --format="value(status.url)" 2>/dev/null || echo "")

if [ -z "$SERVICE_URL" ]; then
    log_error "Cloud Run service '$SERVICE_NAME' not found in region '$REGION'"
    exit 1
fi

RESULTS_DIR="$SCRIPT_DIR/../results/performance"
mkdir -p "$RESULTS_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULTS_FILE="$RESULTS_DIR/${SERVICE_NAME}_${TIMESTAMP}.json"
LOG_FILE="$RESULTS_DIR/${SERVICE_NAME}_${TIMESTAMP}.log"

log_info "Starting performance test for Cloud Run service"
log_info "Service: $SERVICE_NAME"
log_info "URL: $SERVICE_URL"
log_info "Duration: ${TEST_DURATION}s"
log_info "Concurrent users: $CONCURRENT_USERS"
log_info "Ramp-up time: ${RAMP_UP_TIME}s"
log_info "Results will be saved to: $RESULTS_FILE"

# Initialize results
cat > "$RESULTS_FILE" << EOF
{
  "test_info": {
    "service_name": "$SERVICE_NAME",
    "service_url": "$SERVICE_URL",
    "project_id": "$PROJECT_ID",
    "region": "$REGION",
    "test_duration": $TEST_DURATION,
    "concurrent_users": $CONCURRENT_USERS,
    "ramp_up_time": $RAMP_UP_TIME,
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "test_type": "performance"
  },
  "endpoints": [],
  "summary": {}
}
EOF

# Performance test function
run_performance_test() {
    local endpoint="$1"
    local endpoint_name="$2"
    local test_url="${SERVICE_URL}${endpoint}"
    
    log_info "Testing endpoint: $endpoint_name ($endpoint)"
    
    local temp_results="/tmp/perf_test_${endpoint_name}_$$"
    local response_times=()
    local status_codes=()
    local errors=0
    local total_requests=0
    
    # Calculate requests per user
    local requests_per_user=$((TEST_DURATION / CONCURRENT_USERS))
    if [ $requests_per_user -lt 1 ]; then
        requests_per_user=1
    fi
    
    # Background processes for concurrent users
    local pids=()
    
    for ((user=1; user<=CONCURRENT_USERS; user++)); do
        (
            # Stagger start times
            sleep $((user * RAMP_UP_TIME / CONCURRENT_USERS))
            
            local user_requests=0
            local end_time=$(($(date +%s) + TEST_DURATION - (user * RAMP_UP_TIME / CONCURRENT_USERS)))
            
            while [ $(date +%s) -lt $end_time ]; do
                local start_time=$(date +%s.%N)
                local response=$(curl -s -w "%{http_code}|%{time_total}|%{time_connect}|%{time_starttransfer}" \
                    --max-time 30 "$test_url" 2>/dev/null || echo "000|99.999|99.999|99.999")
                local end_time_req=$(date +%s.%N)
                
                IFS='|' read -r status_code total_time connect_time ttfb <<< "$response"
                
                echo "${start_time}|${status_code}|${total_time}|${connect_time}|${ttfb}" >> "${temp_results}_${user}"
                
                user_requests=$((user_requests + 1))
                
                # Small delay to prevent overwhelming
                sleep 0.1
            done
        ) &
        pids+=($!)
    done
    
    # Wait for all background processes
    for pid in "${pids[@]}"; do
        wait $pid
    done
    
    # Aggregate results
    local min_response=999999
    local max_response=0
    local total_time=0
    local success_count=0
    local error_count=0
    local total_requests=0
    
    declare -A status_code_counts
    
    for ((user=1; user<=CONCURRENT_USERS; user++)); do
        if [ -f "${temp_results}_${user}" ]; then
            while IFS='|' read -r timestamp status_code response_time connect_time ttfb; do
                total_requests=$((total_requests + 1))
                
                if [ "$status_code" = "200" ]; then
                    success_count=$((success_count + 1))
                    total_time=$(awk "BEGIN {print $total_time + $response_time}")
                    
                    # Min/Max tracking
                    if (( $(awk "BEGIN {print ($response_time < $min_response)}") )); then
                        min_response=$response_time
                    fi
                    if (( $(awk "BEGIN {print ($response_time > $max_response)}") )); then
                        max_response=$response_time
                    fi
                else
                    error_count=$((error_count + 1))
                fi
                
                status_code_counts[$status_code]=$((${status_code_counts[$status_code]:-0} + 1))
                
            done < "${temp_results}_${user}"
            rm -f "${temp_results}_${user}"
        fi
    done
    
    local avg_response=0
    if [ $success_count -gt 0 ]; then
        avg_response=$(awk "BEGIN {print $total_time / $success_count}")
    fi
    
    local success_rate=0
    if [ $total_requests -gt 0 ]; then
        success_rate=$(awk "BEGIN {print ($success_count / $total_requests) * 100}")
    fi
    
    local requests_per_second=0
    if [ $TEST_DURATION -gt 0 ]; then
        requests_per_second=$(awk "BEGIN {print $total_requests / $TEST_DURATION}")
    fi
    
    # Add results to JSON file
    local endpoint_result=$(cat << EOF
{
  "endpoint": "$endpoint",
  "endpoint_name": "$endpoint_name",
  "url": "$test_url",
  "total_requests": $total_requests,
  "successful_requests": $success_count,
  "failed_requests": $error_count,
  "success_rate_percent": $success_rate,
  "requests_per_second": $requests_per_second,
  "response_times": {
    "min_seconds": $min_response,
    "max_seconds": $max_response,
    "avg_seconds": $avg_response
  },
  "status_codes": $(echo "${!status_code_counts[@]}" "${status_code_counts[@]}" | awk '
    BEGIN { printf "{" }
    {
      n = NF/2
      for(i=1; i<=n; i++) {
        if(i>1) printf ","
        printf "\"%s\": %s", $(i), $(n+i)
      }
      printf "}"
    }')
}
EOF
)
    
    # Update results file
    jq ".endpoints += [$endpoint_result]" "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"
    
    log_info "Endpoint $endpoint_name results:"
    log_info "  Total requests: $total_requests"
    log_info "  Success rate: ${success_rate}%"
    log_info "  Requests/sec: $requests_per_second"
    log_info "  Avg response time: ${avg_response}s"
    log_info "  Min response time: ${min_response}s"
    log_info "  Max response time: ${max_response}s"
}

echo "=========================================="
echo "CLOUD RUN PERFORMANCE TESTING"
echo "=========================================="

# Warm up the service
log_info "Warming up service..."
for i in {1..5}; do
    curl -s --max-time 30 "$SERVICE_URL/health" >/dev/null || true
    sleep 1
done

# Test critical endpoints
echo ""
echo "Testing critical endpoints..."

run_performance_test "/" "home"
run_performance_test "/health" "health_check"
run_performance_test "/ready" "readiness_probe"
run_performance_test "/config" "configuration"

# Calculate overall summary
TOTAL_REQUESTS=$(jq '[.endpoints[].total_requests] | add' "$RESULTS_FILE")
TOTAL_SUCCESSFUL=$(jq '[.endpoints[].successful_requests] | add' "$RESULTS_FILE")
TOTAL_FAILED=$(jq '[.endpoints[].failed_requests] | add' "$RESULTS_FILE")
OVERALL_SUCCESS_RATE=$(awk "BEGIN {print ($TOTAL_SUCCESSFUL / $TOTAL_REQUESTS) * 100}")
OVERALL_RPS=$(awk "BEGIN {print $TOTAL_REQUESTS / $TEST_DURATION}")

# Add summary to results
SUMMARY=$(cat << EOF
{
  "total_requests": $TOTAL_REQUESTS,
  "total_successful": $TOTAL_SUCCESSFUL,
  "total_failed": $TOTAL_FAILED,
  "overall_success_rate_percent": $OVERALL_SUCCESS_RATE,
  "overall_requests_per_second": $OVERALL_RPS,
  "test_completed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
)

jq ".summary = $SUMMARY" "$RESULTS_FILE" > "${RESULTS_FILE}.tmp" && mv "${RESULTS_FILE}.tmp" "$RESULTS_FILE"

echo ""
echo "=========================================="
echo "PERFORMANCE TEST SUMMARY"
echo "=========================================="

log_info "Overall Results:"
log_info "  Total requests: $TOTAL_REQUESTS"
log_info "  Successful requests: $TOTAL_SUCCESSFUL"
log_info "  Failed requests: $TOTAL_FAILED"
log_info "  Overall success rate: ${OVERALL_SUCCESS_RATE}%"
log_info "  Overall requests/sec: $OVERALL_RPS"

echo ""
echo "Performance Assessment:"

# Performance thresholds
if (( $(awk "BEGIN {print ($OVERALL_SUCCESS_RATE >= 99.0)}") )); then
    log_success "✅ Success rate: EXCELLENT (≥99%)"
elif (( $(awk "BEGIN {print ($OVERALL_SUCCESS_RATE >= 95.0)}") )); then
    log_warning "⚠️  Success rate: GOOD (≥95%)"
else
    log_error "❌ Success rate: POOR (<95%)"
fi

if (( $(awk "BEGIN {print ($OVERALL_RPS >= 10)}") )); then
    log_success "✅ Throughput: EXCELLENT (≥10 req/s)"
elif (( $(awk "BEGIN {print ($OVERALL_RPS >= 5)}") )); then
    log_warning "⚠️  Throughput: MODERATE (≥5 req/s)"
else
    log_error "❌ Throughput: LOW (<5 req/s)"
fi

# Check individual endpoint performance
echo ""
echo "Endpoint Performance:"
jq -r '.endpoints[] | "  \(.endpoint_name): \(.success_rate_percent | tonumber | floor)% success, \(.requests_per_second | tonumber * 10 | floor / 10) req/s, \(.response_times.avg_seconds | tonumber * 1000 | floor)ms avg"' "$RESULTS_FILE"

echo ""
echo "Detailed results saved to: $RESULTS_FILE"

# Generate recommendations
echo ""
echo "Performance Recommendations:"

if (( $(awk "BEGIN {print ($OVERALL_SUCCESS_RATE < 99)}") )); then
    echo "  • Investigate failed requests and error handling"
    echo "  • Consider increasing timeout settings"
    echo "  • Review application logs for errors"
fi

if (( $(awk "BEGIN {print ($OVERALL_RPS < 10)}") )); then
    echo "  • Consider increasing CPU allocation"
    echo "  • Optimize application code for better performance"
    echo "  • Review database connection pooling"
    echo "  • Consider increasing max instances for higher concurrency"
fi

AVG_RESPONSE_TIME=$(jq '[.endpoints[].response_times.avg_seconds] | add / length' "$RESULTS_FILE")
if (( $(awk "BEGIN {print ($AVG_RESPONSE_TIME > 1.0)}") )); then
    echo "  • Response times are high - consider application optimization"
    echo "  • Review external API calls and database queries"
    echo "  • Consider enabling startup CPU boost"
fi

echo ""
echo "Cloud Console Performance Monitoring:"
echo "https://console.cloud.google.com/run/detail/$REGION/$SERVICE_NAME?project=$PROJECT_ID"

if (( $(awk "BEGIN {print ($OVERALL_SUCCESS_RATE >= 95 && $OVERALL_RPS >= 5)}") )); then
    log_success "🎉 Performance test PASSED - Service meets performance criteria"
    exit 0
else
    log_error "❌ Performance test FAILED - Service needs optimization"
    exit 1
fi