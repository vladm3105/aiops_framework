#!/bin/bash

# GCP Cloud Run Deployment Script
# Simple deployment of containerized applications to Google Cloud Run

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GCP_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$GCP_DIR/configs/gcp-deployment.json"
TEMP_DIR="/tmp/gcp-cloud-run-deploy-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "☁️  GCP Cloud Run Deployment"
echo "============================"

# Parse command line arguments
SERVICE_NAME="${1:-simple-app}"
IMAGE_NAME="${2:-gcr.io/cloudrun/hello}"
ENVIRONMENT="${3:-development}"
PROJECT_ID="${4:-}"
REGION="${5:-us-central1}"

echo "📝 Deployment Configuration:"
echo "   Service Name: $SERVICE_NAME"
echo "   Image: $IMAGE_NAME"
echo "   Environment: $ENVIRONMENT"
echo "   Region: $REGION"

# Load configuration if available
if [[ -f "$CONFIG_FILE" ]]; then
    DEFAULT_PROJECT=$(jq -r '.gcp_deployment.default_project // empty' "$CONFIG_FILE" 2>/dev/null || echo "")
    DEFAULT_REGION=$(jq -r '.gcp_deployment.default_region // "us-central1"' "$CONFIG_FILE" 2>/dev/null || echo "us-central1")
    
    # Use config defaults if not specified
    [[ "$REGION" == "us-central1" && -n "$DEFAULT_REGION" ]] && REGION="$DEFAULT_REGION"
    [[ -z "$PROJECT_ID" && -n "$DEFAULT_PROJECT" ]] && PROJECT_ID="$DEFAULT_PROJECT"
fi

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Google Cloud CLI
if ! command -v gcloud &> /dev/null; then
    echo "❌ Google Cloud CLI not found. Please install gcloud."
    exit 1
fi

# Check authentication
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" 2>/dev/null | head -n1 > /dev/null; then
    echo "❌ Not authenticated with Google Cloud. Please run 'gcloud auth login'."
    exit 1
fi

# Get current project if not specified
if [[ -z "$PROJECT_ID" ]]; then
    PROJECT_ID=$(gcloud config get-value project 2>/dev/null || echo "")
    if [[ -z "$PROJECT_ID" ]]; then
        echo "❌ No project specified and no default project set. Please run 'gcloud config set project PROJECT_ID'."
        exit 1
    fi
fi

echo "✅ Authenticated with Google Cloud (Project: $PROJECT_ID)"
echo "   Project ID: $PROJECT_ID"

# Set project
gcloud config set project "$PROJECT_ID" --quiet

# Step 1: Enable required APIs
echo "🔧 Enabling required APIs..."
gcloud services enable run.googleapis.com --quiet
gcloud services enable cloudbuild.googleapis.com --quiet
gcloud services enable containerregistry.googleapis.com --quiet
echo "✅ Required APIs enabled"

# Step 2: Prepare container configuration
echo "⚙️  Preparing container configuration..."

# Check if this is a custom build or existing image
if [[ "$IMAGE_NAME" == *"gcr.io/$PROJECT_ID"* || "$IMAGE_NAME" == *"$PROJECT_ID"* ]]; then
    echo "🔐 Detected project-specific image"
elif [[ "$IMAGE_NAME" == "gcr.io/cloudrun/hello" ]]; then
    echo "✅ Using default Cloud Run hello-world image"
elif [[ -f "$GCP_DIR/samples/simple-cloud-run-app/Dockerfile" ]]; then
    echo "🏗️  Building custom image from sample application..."
    
    # Build and push custom image
    CUSTOM_IMAGE="gcr.io/$PROJECT_ID/$SERVICE_NAME:latest"
    
    cd "$GCP_DIR/samples/simple-cloud-run-app"
    
    # Build with Cloud Build
    gcloud builds submit --tag "$CUSTOM_IMAGE" .
    
    echo "✅ Custom image built and pushed: $CUSTOM_IMAGE"
    IMAGE_NAME="$CUSTOM_IMAGE"
    
    cd "$SCRIPT_DIR"
else
    echo "✅ Using external image: $IMAGE_NAME"
fi

# Step 3: Deploy to Cloud Run
echo "🚀 Deploying to Google Cloud Run..."

# Prepare environment variables based on environment
case "$ENVIRONMENT" in
    "development")
        ENV_VARS="ENVIRONMENT=development,DEBUG=true,LOG_LEVEL=debug"
        MIN_INSTANCES=0
        MAX_INSTANCES=10
        CPU_LIMIT="1"
        MEMORY_LIMIT="512Mi"
        CONCURRENCY=10
        ;;
    "staging")
        ENV_VARS="ENVIRONMENT=staging,DEBUG=false,LOG_LEVEL=info"
        MIN_INSTANCES=0
        MAX_INSTANCES=50
        CPU_LIMIT="1"
        MEMORY_LIMIT="1Gi"
        CONCURRENCY=50
        ;;
    "production")
        ENV_VARS="ENVIRONMENT=production,DEBUG=false,LOG_LEVEL=warn"
        MIN_INSTANCES=1
        MAX_INSTANCES=100
        CPU_LIMIT="2"
        MEMORY_LIMIT="2Gi"
        CONCURRENCY=100
        ;;
    *)
        ENV_VARS="ENVIRONMENT=$ENVIRONMENT"
        MIN_INSTANCES=0
        MAX_INSTANCES=10
        CPU_LIMIT="1"
        MEMORY_LIMIT="512Mi"
        CONCURRENCY=10
        ;;
esac

# Deploy Cloud Run service
echo "⏳ Creating Cloud Run service..."
gcloud run deploy "$SERVICE_NAME" \
    --image="$IMAGE_NAME" \
    --region="$REGION" \
    --platform=managed \
    --allow-unauthenticated \
    --set-env-vars="$ENV_VARS,DEPLOYED_BY=GCP-Cloud-Run-Deployment,DEPLOYMENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --min-instances="$MIN_INSTANCES" \
    --max-instances="$MAX_INSTANCES" \
    --cpu="$CPU_LIMIT" \
    --memory="$MEMORY_LIMIT" \
    --concurrency="$CONCURRENCY" \
    --port=8080 \
    --timeout=300 \
    --quiet

if [[ $? -eq 0 ]]; then
    echo "✅ Cloud Run service deployed successfully!"
else
    echo "❌ Cloud Run deployment failed!"
    exit 1
fi

# Step 4: Get deployment information
echo "📊 Retrieving deployment information..."

# Get service details
SERVICE_URL=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --format="value(status.url)" 2>/dev/null || echo "")

SERVICE_STATE=$(gcloud run services describe "$SERVICE_NAME" \
    --region="$REGION" \
    --format="value(status.conditions[0].type)" 2>/dev/null || echo "Unknown")

# Step 5: Perform health check
echo "🏥 Performing health check..."

if [[ -n "$SERVICE_URL" ]]; then
    echo "🌐 Testing service connectivity..."
    
    for i in {1..5}; do
        if curl -f -s --max-time 10 "$SERVICE_URL" > /dev/null 2>&1; then
            echo "✅ HTTP health check passed (attempt $i)"
            break
        else
            echo "⚠️  HTTP health check failed (attempt $i/5)"
            if [[ $i -eq 5 ]]; then
                echo "❌ HTTP health check failed after 5 attempts"
            else
                sleep 10
            fi
        fi
    done
    
    # Test health endpoint if available
    if curl -f -s --max-time 5 "$SERVICE_URL/health" > /dev/null 2>&1; then
        echo "✅ Health endpoint responding"
    else
        echo "ℹ️  Health endpoint not available (may be normal)"
    fi
else
    echo "⚠️  Service URL not available"
fi

# Step 6: Display deployment summary
echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo "Service Name: $SERVICE_NAME"
echo "Image: $IMAGE_NAME"
echo "Project: $PROJECT_ID"
echo "Region: $REGION"
echo "Environment: $ENVIRONMENT"
echo "State: $SERVICE_STATE"

if [[ -n "$SERVICE_URL" ]]; then
    echo "Service URL: $SERVICE_URL"
    echo "Health Check: $SERVICE_URL/health"
fi

# Step 7: Save deployment info
cat > "$TEMP_DIR/deployment-info.json" << EOF
{
  "deployment": {
    "service_name": "$SERVICE_NAME",
    "image_name": "$IMAGE_NAME",
    "environment": "$ENVIRONMENT",
    "project_id": "$PROJECT_ID",
    "region": "$REGION",
    "deployment_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "service": {
    "state": "$SERVICE_STATE",
    "url": "$SERVICE_URL",
    "health_url": "$SERVICE_URL/health"
  },
  "gcp": {
    "project_id": "$PROJECT_ID",
    "region": "$REGION"
  },
  "resources": {
    "cpu": "$CPU_LIMIT",
    "memory": "$MEMORY_LIMIT",
    "min_instances": $MIN_INSTANCES,
    "max_instances": $MAX_INSTANCES,
    "concurrency": $CONCURRENCY
  }
}
EOF

# Copy to results directory if it exists
RESULTS_DIR="$GCP_DIR/../../../deployment_results"
if [[ -d "$(dirname "$RESULTS_DIR")" ]]; then
    mkdir -p "$RESULTS_DIR"
    cp "$TEMP_DIR/deployment-info.json" "$RESULTS_DIR/gcp-cloud-run-deployment.json"
    echo "📄 Deployment info saved to: $RESULTS_DIR/gcp-cloud-run-deployment.json"
fi

echo ""
echo "🔧 Management Commands:"
echo "View logs:    gcloud run services logs read --service='$SERVICE_NAME' --region='$REGION'"
echo "Update:       gcloud run services update '$SERVICE_NAME' --region='$REGION'"
echo "Delete:       gcloud run services delete '$SERVICE_NAME' --region='$REGION' --quiet"
echo "Describe:     gcloud run services describe '$SERVICE_NAME' --region='$REGION'"

echo ""
echo "✨ Cloud Run deployment completed successfully!"

# Output for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "service_name=$SERVICE_NAME" >> "$GITHUB_OUTPUT"
    echo "service_url=$SERVICE_URL" >> "$GITHUB_OUTPUT"
    echo "service_state=$SERVICE_STATE" >> "$GITHUB_OUTPUT"
    echo "project_id=$PROJECT_ID" >> "$GITHUB_OUTPUT"
    echo "region=$REGION" >> "$GITHUB_OUTPUT"
    echo "deployment_status=success" >> "$GITHUB_OUTPUT"
fi