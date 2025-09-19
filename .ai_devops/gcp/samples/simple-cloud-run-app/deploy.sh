#!/bin/bash

# Simple Cloud Run Application Deployment Script
# This script builds and deploys the sample application to Google Cloud Run

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

PROJECT_ID="${1:-}"
SERVICE_NAME="${2:-simple-cloud-run-app}"
ENVIRONMENT="${3:-development}"
REGION="${4:-us-central1}"
IMAGE_TAG="${5:-latest}"

if [ -z "$PROJECT_ID" ]; then
    echo "Error: PROJECT_ID is required"
    echo "Usage: $0 <PROJECT_ID> [SERVICE_NAME] [ENVIRONMENT] [REGION] [IMAGE_TAG]"
    echo "Example: $0 my-gcp-project simple-app development us-central1 v1.0"
    exit 1
fi

IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}:${IMAGE_TAG}"

echo "=========================================="
echo "Cloud Run Application Deployment"
echo "=========================================="
echo "Project ID: $PROJECT_ID"
echo "Service Name: $SERVICE_NAME"
echo "Environment: $ENVIRONMENT"
echo "Region: $REGION"
echo "Image: $IMAGE_NAME"
echo "=========================================="

echo "Step 1: Validating prerequisites..."

if ! command -v gcloud &> /dev/null; then
    echo "Error: gcloud CLI is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

echo "Step 2: Configuring gcloud..."
gcloud config set project "$PROJECT_ID"
gcloud auth configure-docker --quiet

echo "Step 3: Building Docker image..."
docker build -t "$IMAGE_NAME" .

echo "Step 4: Pushing image to Container Registry..."
docker push "$IMAGE_NAME"

echo "Step 5: Deploying to Cloud Run..."

case "$ENVIRONMENT" in
    "development")
        ENV_VARS="ENVIRONMENT=development,DEBUG=true,LOG_LEVEL=debug,ENABLE_MONITORING=true"
        MIN_INSTANCES=0
        MAX_INSTANCES=10
        CPU_LIMIT="1"
        MEMORY_LIMIT="512Mi"
        CONCURRENCY=10
        TIMEOUT=300
        ALLOW_UNAUTHENTICATED="--allow-unauthenticated"
        ;;
    "staging")
        ENV_VARS="ENVIRONMENT=staging,DEBUG=false,LOG_LEVEL=info,ENABLE_MONITORING=true"
        MIN_INSTANCES=0
        MAX_INSTANCES=50
        CPU_LIMIT="1"
        MEMORY_LIMIT="1Gi"
        CONCURRENCY=50
        TIMEOUT=300
        ALLOW_UNAUTHENTICATED="--allow-unauthenticated"
        ;;
    "production")
        ENV_VARS="ENVIRONMENT=production,DEBUG=false,LOG_LEVEL=warn,ENABLE_MONITORING=true"
        MIN_INSTANCES=1
        MAX_INSTANCES=100
        CPU_LIMIT="2"
        MEMORY_LIMIT="2Gi"
        CONCURRENCY=100
        TIMEOUT=900
        ALLOW_UNAUTHENTICATED=""
        ;;
    *)
        echo "Error: Unknown environment '$ENVIRONMENT'. Use: development, staging, or production"
        exit 1
        ;;
esac

DEPLOYMENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ENV_VARS="${ENV_VARS},DEPLOYMENT_TIME=${DEPLOYMENT_TIME},DEPLOYED_BY=deploy-script"

gcloud run deploy "$SERVICE_NAME" \
    --image "$IMAGE_NAME" \
    --platform managed \
    --region "$REGION" \
    --set-env-vars "$ENV_VARS" \
    --min-instances "$MIN_INSTANCES" \
    --max-instances "$MAX_INSTANCES" \
    --cpu "$CPU_LIMIT" \
    --memory "$MEMORY_LIMIT" \
    --concurrency "$CONCURRENCY" \
    --timeout "$TIMEOUT" \
    --port 8080 \
    --labels "environment=${ENVIRONMENT},deployed-by=deploy-script,app=${SERVICE_NAME}" \
    $ALLOW_UNAUTHENTICATED \
    --quiet

echo "Step 6: Getting service information..."
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" --region "$REGION" --format="value(status.url)")

echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
echo "Service URL: $SERVICE_URL"
echo "Service Name: $SERVICE_NAME"
echo "Environment: $ENVIRONMENT"
echo "Region: $REGION"
echo "Image: $IMAGE_NAME"
echo "=========================================="

echo "Step 7: Running basic health check..."
sleep 10

if curl -f -s "${SERVICE_URL}/health" > /dev/null; then
    echo "✅ Health check passed - service is responding"
else
    echo "⚠️  Health check failed - service may not be ready yet"
    echo "Check service logs: gcloud run services logs read $SERVICE_NAME --region $REGION"
fi

echo ""
echo "Available endpoints:"
echo "  Home: $SERVICE_URL/"
echo "  Health: $SERVICE_URL/health"
echo "  Dashboard: $SERVICE_URL/dashboard"
echo "  Metrics: $SERVICE_URL/metrics"
echo "  Config: $SERVICE_URL/config"
echo ""
echo "To view logs: gcloud run services logs read $SERVICE_NAME --region $REGION --follow"
echo "To view service: gcloud run services describe $SERVICE_NAME --region $REGION"
echo ""
echo "Deployment complete! 🚀"