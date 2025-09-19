#!/bin/bash

# Deployment script for Simple Web App to Azure Container Instances
# This script builds and deploys the sample application

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
APP_NAME="simple-web-app"
IMAGE_TAG="latest"
DEFAULT_CONTAINER_NAME="simple-web-app"
DEFAULT_RESOURCE_GROUP="rg-containers"
DEFAULT_LOCATION="East US"

echo "🐳 Simple Web App Deployment Script"
echo "==================================="

# Parse command line arguments
BUILD_IMAGE="${1:-true}"
CONTAINER_NAME="${2:-$DEFAULT_CONTAINER_NAME}"
ENVIRONMENT="${3:-development}"
RESOURCE_GROUP="${4:-$DEFAULT_RESOURCE_GROUP}"
LOCATION="${5:-$DEFAULT_LOCATION}"

echo "📝 Deployment Configuration:"
echo "   Build Image: $BUILD_IMAGE"
echo "   Container Name: $CONTAINER_NAME"
echo "   Environment: $ENVIRONMENT"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"

# Check prerequisites
echo "🔍 Checking prerequisites..."

if ! command -v docker &> /dev/null && [[ "$BUILD_IMAGE" == "true" ]]; then
    echo "❌ Docker not found but image build requested"
    exit 1
fi

if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found"
    exit 1
fi

# Check Azure authentication
if ! az account show > /dev/null 2>&1; then
    echo "❌ Not authenticated with Azure. Please run 'az login'."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Build Docker image (if requested)
if [[ "$BUILD_IMAGE" == "true" ]]; then
    echo "🏗️  Building Docker image..."
    
    cd "$SCRIPT_DIR"
    
    # Build the image locally
    docker build -t "$APP_NAME:$IMAGE_TAG" .
    
    echo "✅ Docker image built: $APP_NAME:$IMAGE_TAG"
    
    # Check if Azure Container Registry is available
    ACR_NAME=$(echo "$RESOURCE_GROUP" | tr -d '-' | tr '[:upper:]' '[:lower:]')acr
    
    echo "🔍 Checking for Azure Container Registry: $ACR_NAME"
    
    if az acr show --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" > /dev/null 2>&1; then
        echo "📦 Found existing ACR: $ACR_NAME"
        
        # Tag and push to ACR
        ACR_LOGIN_SERVER="$ACR_NAME.azurecr.io"
        IMAGE_NAME="$ACR_LOGIN_SERVER/$APP_NAME:$IMAGE_TAG"
        
        echo "🔐 Logging into ACR..."
        az acr login --name "$ACR_NAME"
        
        echo "🏷️  Tagging image for ACR..."
        docker tag "$APP_NAME:$IMAGE_TAG" "$IMAGE_NAME"
        
        echo "⬆️  Pushing image to ACR..."
        docker push "$IMAGE_NAME"
        
        echo "✅ Image pushed to ACR: $IMAGE_NAME"
        DEPLOYMENT_IMAGE="$IMAGE_NAME"
    else
        echo "⚠️  ACR not found. Creating new ACR..."
        
        # Create resource group if it doesn't exist
        if ! az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
            echo "📦 Creating resource group: $RESOURCE_GROUP"
            az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        fi
        
        # Create ACR
        az acr create --name "$ACR_NAME" --resource-group "$RESOURCE_GROUP" --sku Basic
        
        # Enable admin user
        az acr update --name "$ACR_NAME" --admin-enabled true
        
        echo "✅ ACR created: $ACR_NAME"
        
        # Now push the image
        ACR_LOGIN_SERVER="$ACR_NAME.azurecr.io"
        IMAGE_NAME="$ACR_LOGIN_SERVER/$APP_NAME:$IMAGE_TAG"
        
        az acr login --name "$ACR_NAME"
        docker tag "$APP_NAME:$IMAGE_TAG" "$IMAGE_NAME"
        docker push "$IMAGE_NAME"
        
        echo "✅ Image pushed to ACR: $IMAGE_NAME"
        DEPLOYMENT_IMAGE="$IMAGE_NAME"
    fi
else
    echo "⚠️  Skipping image build. Using nginx:latest"
    DEPLOYMENT_IMAGE="nginx:latest"
fi

# Deploy using the Azure deployment script
echo "🚀 Deploying container to Azure..."

cd "$AZURE_DIR"

# Run the deployment script
./scripts/deploy-docker-container.sh \
    "$CONTAINER_NAME" \
    "$DEPLOYMENT_IMAGE" \
    "$ENVIRONMENT" \
    "$RESOURCE_GROUP" \
    "$LOCATION"

if [[ $? -eq 0 ]]; then
    echo "✅ Deployment completed successfully!"
    
    # Run validation
    echo "🔍 Running post-deployment validation..."
    ./scripts/validate-deployment.sh "$RESOURCE_GROUP" "$CONTAINER_NAME"
    
    # Get deployment information
    echo ""
    echo "📊 Deployment Information:"
    echo "========================="
    
    CONTAINER_IP=$(az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CONTAINER_NAME" \
        --query ipAddress.ip -o tsv 2>/dev/null || echo "Not assigned")
    
    CONTAINER_FQDN=$(az container show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CONTAINER_NAME" \
        --query ipAddress.fqdn -o tsv 2>/dev/null || echo "Not assigned")
    
    echo "Container Name: $CONTAINER_NAME"
    echo "Image: $DEPLOYMENT_IMAGE"
    echo "Resource Group: $RESOURCE_GROUP"
    echo "Public IP: $CONTAINER_IP"
    echo "FQDN: $CONTAINER_FQDN"
    
    if [[ -n "$CONTAINER_FQDN" && "$CONTAINER_FQDN" != "Not assigned" ]]; then
        echo ""
        echo "🌐 Access URLs:"
        echo "HTTP: http://$CONTAINER_FQDN"
        echo "Health Check: http://$CONTAINER_FQDN/health"
        echo "Readiness Check: http://$CONTAINER_FQDN/ready"
    fi
    
    echo ""
    echo "🔧 Management Commands:"
    echo "View logs: az container logs --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
    echo "Restart: az container restart --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
    echo "Delete: az container delete --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME' --yes"
else
    echo "❌ Deployment failed!"
    exit 1
fi

echo ""
echo "✨ Simple Web App deployment completed successfully!"