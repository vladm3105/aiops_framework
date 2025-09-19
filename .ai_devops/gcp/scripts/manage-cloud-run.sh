#!/bin/bash

# GCP Cloud Run Management Script
# Manage Google Cloud Run services - list, delete, logs, status, etc.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCP_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧹 GCP Cloud Run Management"
echo "==========================="

# Parse command line arguments
ACTION="${1:-list}"
SERVICE_NAME="${2:-}"
REGION="${3:-us-central1}"
PROJECT_ID="${4:-}"

echo "Action: $ACTION"
echo "Region: $REGION"
if [[ -n "$SERVICE_NAME" ]]; then
    echo "Service Name: $SERVICE_NAME"
fi

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

case "$ACTION" in
    "list")
        echo "📋 Listing Cloud Run services in region: $REGION"
        
        SERVICES=$(gcloud run services list --region="$REGION" --project="$PROJECT_ID" --format="table(
            metadata.name:label=SERVICE,
            status.url:label=URL,
            status.conditions[0].type:label=STATUS,
            spec.template.spec.template.spec.containers[0].image:label=IMAGE
        )" 2>/dev/null || echo "")
        
        if [[ -n "$SERVICES" ]]; then
            echo "$SERVICES"
        else
            echo "No Cloud Run services found in region: $REGION"
        fi
        ;;
        
    "delete")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for delete action"
            echo "Usage: $0 delete <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "🗑️  Deleting Cloud Run service: $SERVICE_NAME"
        
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            gcloud run services delete "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --quiet
            echo "✅ Service '$SERVICE_NAME' deleted successfully"
        else
            echo "Service '$SERVICE_NAME' not found in region '$REGION'"
        fi
        ;;
        
    "delete-all")
        echo "🗑️  Deleting ALL Cloud Run services in region: $REGION"
        echo "⚠️  This action cannot be undone!"
        
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            SERVICE_NAMES=$(gcloud run services list --region="$REGION" --project="$PROJECT_ID" --format="value(metadata.name)" 2>/dev/null || echo "")
            
            if [[ -n "$SERVICE_NAMES" ]]; then
                while IFS= read -r service; do
                    if [[ -n "$service" ]]; then
                        echo "Deleting: $service"
                        gcloud run services delete "$service" \
                            --region="$REGION" \
                            --project="$PROJECT_ID" \
                            --quiet
                    fi
                done <<< "$SERVICE_NAMES"
                echo "✅ All services deleted successfully"
            else
                echo "No services found to delete"
            fi
        else
            echo "Operation cancelled"
        fi
        ;;
        
    "logs")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for logs action"
            echo "Usage: $0 logs <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "📜 Fetching logs for Cloud Run service: $SERVICE_NAME"
        
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            gcloud run services logs read \
                --service="$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --limit=50
        else
            echo "Service '$SERVICE_NAME' not found"
        fi
        ;;
        
    "status")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for status action"
            echo "Usage: $0 status <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "📊 Status for Cloud Run service: $SERVICE_NAME"
        
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="table(
                    metadata.name:label=SERVICE,
                    status.url:label=URL,
                    status.conditions[0].type:label=STATUS,
                    spec.template.spec.template.spec.containers[0].image:label=IMAGE,
                    spec.template.spec.template.spec.containers[0].resources.limits.cpu:label=CPU,
                    spec.template.spec.template.spec.containers[0].resources.limits.memory:label=MEMORY,
                    status.traffic[0].percent:label=TRAFFIC
                )"
        else
            echo "Service '$SERVICE_NAME' not found"
        fi
        ;;
        
    "revisions")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for revisions action"
            echo "Usage: $0 revisions <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "📜 Revisions for Cloud Run service: $SERVICE_NAME"
        
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            gcloud run revisions list \
                --service="$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="table(
                    metadata.name:label=REVISION,
                    status.conditions[0].type:label=STATUS,
                    metadata.creationTimestamp:label=CREATED,
                    spec.template.spec.containers[0].image:label=IMAGE
                )"
        else
            echo "Service '$SERVICE_NAME' not found"
        fi
        ;;
        
    "traffic")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for traffic action"
            echo "Usage: $0 traffic <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "🚦 Traffic allocation for Cloud Run service: $SERVICE_NAME"
        
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="table(
                    status.traffic[].revisionName:label=REVISION,
                    status.traffic[].percent:label=PERCENT,
                    status.traffic[].url:label=URL
                )"
        else
            echo "Service '$SERVICE_NAME' not found"
        fi
        ;;
        
    "metrics")
        if [[ -z "$SERVICE_NAME" ]]; then
            echo "❌ Service name required for metrics action"
            echo "Usage: $0 metrics <service-name> [region] [project-id]"
            exit 1
        fi
        
        echo "📊 Metrics for Cloud Run service: $SERVICE_NAME"
        
        # Get service metrics (basic implementation)
        if gcloud run services describe "$SERVICE_NAME" --region="$REGION" --project="$PROJECT_ID" > /dev/null 2>&1; then
            echo ""
            echo "Service Details:"
            echo "=================="
            
            SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(status.url)" 2>/dev/null || echo "")
            
            SERVICE_STATE=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(status.conditions[0].type)" 2>/dev/null || echo "Unknown")
            
            CPU_LIMIT=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(spec.template.spec.template.spec.containers[0].resources.limits.cpu)" 2>/dev/null || echo "")
            
            MEMORY_LIMIT=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(spec.template.spec.template.spec.containers[0].resources.limits.memory)" 2>/dev/null || echo "")
            
            MIN_INSTANCES=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(spec.template.metadata.annotations.'autoscaling.knative.dev/minScale')" 2>/dev/null || echo "0")
            
            MAX_INSTANCES=$(gcloud run services describe "$SERVICE_NAME" \
                --region="$REGION" \
                --project="$PROJECT_ID" \
                --format="value(spec.template.metadata.annotations.'autoscaling.knative.dev/maxScale')" 2>/dev/null || echo "100")
            
            echo "Status: $SERVICE_STATE"
            echo "URL: $SERVICE_URL"
            echo "CPU Limit: ${CPU_LIMIT:-'Not set'}"
            echo "Memory Limit: ${MEMORY_LIMIT:-'Not set'}"
            echo "Min Instances: ${MIN_INSTANCES:-'0'}"
            echo "Max Instances: ${MAX_INSTANCES:-'100'}"
            
            # Test response time if service is available
            if [[ -n "$SERVICE_URL" ]]; then
                echo ""
                echo "Performance Test:"
                echo "=================="
                
                RESPONSE_TIME=$(curl -o /dev/null -s -w '%{time_total}' "$SERVICE_URL" 2>/dev/null || echo "0")
                RESPONSE_CODE=$(curl -o /dev/null -s -w '%{http_code}' "$SERVICE_URL" 2>/dev/null || echo "000")
                
                echo "Response Time: ${RESPONSE_TIME}s"
                echo "Response Code: $RESPONSE_CODE"
                
                if [[ "$RESPONSE_CODE" == "200" ]]; then
                    echo "✅ Service responding normally"
                else
                    echo "⚠️  Service returned status: $RESPONSE_CODE"
                fi
            fi
        else
            echo "Service '$SERVICE_NAME' not found"
        fi
        ;;
        
    *)
        echo "❌ Unknown action: $ACTION"
        echo ""
        echo "Available actions:"
        echo "  list                                    - List all services in region"
        echo "  delete <service-name>                   - Delete specific service"
        echo "  delete-all                              - Delete all services in region"
        echo "  logs <service-name>                     - Show service logs"
        echo "  status <service-name>                   - Show service status"
        echo "  revisions <service-name>                - Show service revisions"
        echo "  traffic <service-name>                  - Show traffic allocation"
        echo "  metrics <service-name>                  - Show service metrics"
        echo ""
        echo "Examples:"
        echo "  $0 list us-central1"
        echo "  $0 delete my-service us-central1"
        echo "  $0 logs my-service us-central1"
        echo "  $0 status my-service us-central1"
        exit 1
        ;;
esac