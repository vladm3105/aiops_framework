#!/bin/sh

# Health check script for Azure Container Instances
# This script performs comprehensive health checks for the web application

set -e

# Configuration
HEALTH_URL="http://localhost:80/health"
READY_URL="http://localhost:80/ready"
TIMEOUT=5
MAX_RETRIES=3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [HEALTH] $1"
}

# Check if curl is available, fallback to wget
check_http() {
    local url=$1
    local timeout=$2
    
    if command -v curl >/dev/null 2>&1; then
        curl -f -s --max-time "$timeout" "$url" >/dev/null 2>&1
    elif command -v wget >/dev/null 2>&1; then
        wget -q --timeout="$timeout" -O /dev/null "$url" >/dev/null 2>&1
    else
        log "ERROR: Neither curl nor wget available for health check"
        return 1
    fi
}

# Main health check function
perform_health_check() {
    local retries=0
    
    while [ $retries -lt $MAX_RETRIES ]; do
        log "Performing health check (attempt $((retries + 1))/$MAX_RETRIES)..."
        
        # Check 1: Basic health endpoint
        if check_http "$HEALTH_URL" "$TIMEOUT"; then
            log "✅ Health endpoint responding"
        else
            log "❌ Health endpoint not responding"
            retries=$((retries + 1))
            [ $retries -lt $MAX_RETRIES ] && sleep 2
            continue
        fi
        
        # Check 2: Ready endpoint
        if check_http "$READY_URL" "$TIMEOUT"; then
            log "✅ Ready endpoint responding"
        else
            log "⚠️  Ready endpoint not responding (non-critical)"
        fi
        
        # Check 3: Nginx process
        if pgrep nginx >/dev/null 2>&1; then
            log "✅ Nginx process running"
        else
            log "❌ Nginx process not found"
            retries=$((retries + 1))
            [ $retries -lt $MAX_RETRIES ] && sleep 2
            continue
        fi
        
        # Check 4: Port 80 listening
        if netstat -ln 2>/dev/null | grep -q ":80 " || ss -ln 2>/dev/null | grep -q ":80 "; then
            log "✅ Port 80 is listening"
        else
            log "❌ Port 80 not listening"
            retries=$((retries + 1))
            [ $retries -lt $MAX_RETRIES ] && sleep 2
            continue
        fi
        
        # Check 5: Disk space (warn if low)
        DISK_USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$DISK_USAGE" -gt 90 ]; then
            log "⚠️  High disk usage: ${DISK_USAGE}%"
        else
            log "✅ Disk usage normal: ${DISK_USAGE}%"
        fi
        
        # Check 6: Memory usage (warn if high)
        if [ -f /proc/meminfo ]; then
            TOTAL_MEM=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
            AVAIL_MEM=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null || awk '/MemFree/ {print $2}' /proc/meminfo)
            MEM_USAGE=$((100 - (AVAIL_MEM * 100 / TOTAL_MEM)))
            
            if [ "$MEM_USAGE" -gt 85 ]; then
                log "⚠️  High memory usage: ${MEM_USAGE}%"
            else
                log "✅ Memory usage normal: ${MEM_USAGE}%"
            fi
        fi
        
        # All checks passed
        log "✅ All health checks passed"
        return 0
    done
    
    log "❌ Health check failed after $MAX_RETRIES attempts"
    return 1
}

# Container startup check
startup_check() {
    log "Performing startup health check..."
    
    # Wait for nginx to start
    local startup_timeout=60
    local elapsed=0
    
    while [ $elapsed -lt $startup_timeout ]; do
        if pgrep nginx >/dev/null 2>&1; then
            log "✅ Nginx started successfully"
            break
        fi
        
        sleep 1
        elapsed=$((elapsed + 1))
    done
    
    if [ $elapsed -ge $startup_timeout ]; then
        log "❌ Nginx failed to start within ${startup_timeout} seconds"
        return 1
    fi
    
    # Give nginx a moment to bind to port
    sleep 2
    
    # Run full health check
    perform_health_check
}

# Main execution
main() {
    case "${1:-health}" in
        "startup")
            startup_check
            ;;
        "health"|"")
            perform_health_check
            ;;
        "quick")
            check_http "$HEALTH_URL" "$TIMEOUT"
            ;;
        *)
            log "Usage: $0 [startup|health|quick]"
            log "  startup - Comprehensive startup check"
            log "  health  - Standard health check (default)"
            log "  quick   - Quick health endpoint check"
            exit 1
            ;;
    esac
}

# Execute main function
main "$@"