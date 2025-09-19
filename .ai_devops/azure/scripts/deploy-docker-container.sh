#!/bin/bash

# Azure Docker Container Deployment Script
# Simple deployment of Docker containers to Azure Container Instances

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$AZURE_DIR/configs/azure-deployment.json"
TEMP_DIR="/tmp/azure-docker-deploy-$$"

# Create temp directory
mkdir -p "$TEMP_DIR"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "🐳 Azure Docker Container Deployment"
echo "===================================="

# Parse command line arguments
CONTAINER_NAME="${1:-simple-app}"
IMAGE_NAME="${2:-nginx:latest}"
ENVIRONMENT="${3:-development}"
RESOURCE_GROUP="${4:-rg-containers}"
LOCATION="${5:-East US}"

echo "📝 Deployment Configuration:"
echo "   Container Name: $CONTAINER_NAME"
echo "   Image: $IMAGE_NAME"
echo "   Environment: $ENVIRONMENT"
echo "   Resource Group: $RESOURCE_GROUP"
echo "   Location: $LOCATION"

# Load configuration if available
if [[ -f "$CONFIG_FILE" ]]; then
    SUBSCRIPTION_ID=$(jq -r '.subscription_id // empty' "$CONFIG_FILE")
    DEFAULT_LOCATION=$(jq -r '.default_location // "East US"' "$CONFIG_FILE")
    DEFAULT_RG=$(jq -r '.default_resource_group // "rg-containers"' "$CONFIG_FILE")
    
    # Use config defaults if not specified
    [[ "$LOCATION" == "East US" && -n "$DEFAULT_LOCATION" ]] && LOCATION="$DEFAULT_LOCATION"
    [[ "$RESOURCE_GROUP" == "rg-containers" && -n "$DEFAULT_RG" ]] && RESOURCE_GROUP="$DEFAULT_RG"
fi

# Check prerequisites
echo "🔍 Checking prerequisites..."

# Check Azure CLI
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found. Please install Azure CLI."
    exit 1
fi

# Check authentication
if ! az account show > /dev/null 2>&1; then
    echo "❌ Not authenticated with Azure. Please run 'az login'."
    exit 1
fi

# Get current subscription
CURRENT_SUB=$(az account show --query id -o tsv)
echo "✅ Authenticated with Azure (Subscription: $CURRENT_SUB)"

# Set subscription if specified in config
if [[ -n "$SUBSCRIPTION_ID" && "$SUBSCRIPTION_ID" != "$CURRENT_SUB" ]]; then
    echo "🔄 Switching to subscription: $SUBSCRIPTION_ID"
    az account set --subscription "$SUBSCRIPTION_ID"
fi

# Step 1: Create or verify resource group
echo "📦 Setting up resource group..."
if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
    echo "✅ Resource group '$RESOURCE_GROUP' already exists"
else
    echo "🆕 Creating resource group: $RESOURCE_GROUP"
    az group create \
        --name "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --tags Environment="$ENVIRONMENT" CreatedBy="Azure-Docker-Deployment"
    echo "✅ Resource group created successfully"
fi

# Step 2: Prepare container configuration
echo "⚙️  Preparing container configuration..."

# Determine if this is a custom image or public image
if [[ "$IMAGE_NAME" == *".azurecr.io/"* ]]; then
    echo "🔐 Detected Azure Container Registry image"
    ACR_NAME=$(echo "$IMAGE_NAME" | cut -d'.' -f1)
    
    # Enable admin user for ACR if needed
    echo "🔓 Enabling ACR admin access..."
    az acr update --name "$ACR_NAME" --admin-enabled true
    
    # Get ACR credentials
    ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
    ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query passwords[0].value -o tsv)
    
    echo "✅ ACR credentials retrieved"
    
    REGISTRY_LOGIN_SERVER="$ACR_NAME.azurecr.io"
    REGISTRY_USERNAME="$ACR_USERNAME"
    REGISTRY_PASSWORD="$ACR_PASSWORD"
elif [[ "$IMAGE_NAME" == *"/"* && "$IMAGE_NAME" != "nginx:latest" && "$IMAGE_NAME" != "hello-world:latest" ]]; then
    echo "⚠️  Custom registry detected. You may need to provide registry credentials."
    REGISTRY_LOGIN_SERVER=""
    REGISTRY_USERNAME=""
    REGISTRY_PASSWORD=""
else
    echo "✅ Using public Docker Hub image"
    REGISTRY_LOGIN_SERVER=""
    REGISTRY_USERNAME=""
    REGISTRY_PASSWORD=""
fi

# Step 3: Deploy container
echo "🚀 Deploying container to Azure Container Instances..."

# Generate unique DNS name
DNS_NAME="${CONTAINER_NAME}-${ENVIRONMENT}-$(date +%s)"

# Prepare deployment command
DEPLOY_CMD="az container create \
    --resource-group '$RESOURCE_GROUP' \
    --name '$CONTAINER_NAME' \
    --image '$IMAGE_NAME' \
    --dns-name-label '$DNS_NAME' \
    --ports 80 443 \
    --os-type Linux \
    --cpu 1 \
    --memory 1 \
    --restart-policy Always \
    --environment-variables \
        ENVIRONMENT='$ENVIRONMENT' \
        DEPLOYED_BY='Azure-Docker-Deployment' \
        DEPLOYMENT_TIME='$(date -u +%Y-%m-%dT%H:%M:%SZ)'"

# Add registry credentials if needed
if [[ -n "$REGISTRY_LOGIN_SERVER" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD \
        --registry-login-server '$REGISTRY_LOGIN_SERVER' \
        --registry-username '$REGISTRY_USERNAME' \
        --registry-password '$REGISTRY_PASSWORD'"
fi

# Execute deployment
echo "⏳ Creating container instance..."
eval $DEPLOY_CMD

if [[ $? -eq 0 ]]; then
    echo "✅ Container deployed successfully!"
else
    echo "❌ Container deployment failed!"
    exit 1
fi

# Step 4: Get deployment information
echo "📊 Retrieving deployment information..."

# Get container details
CONTAINER_STATE=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query instanceView.state -o tsv)

CONTAINER_IP=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query ipAddress.ip -o tsv)

CONTAINER_FQDN=$(az container show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$CONTAINER_NAME" \
    --query ipAddress.fqdn -o tsv)

# Step 5: Perform health check
echo "🏥 Performing health check..."

if [[ "$CONTAINER_STATE" == "Running" ]]; then
    echo "✅ Container is running"
    
    # Test HTTP connectivity
    if [[ -n "$CONTAINER_FQDN" ]]; then
        echo "🌐 Testing HTTP connectivity..."
        
        for i in {1..5}; do
            if curl -f -s "http://$CONTAINER_FQDN" > /dev/null 2>&1; then
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
    fi
else
    echo "⚠️  Container state: $CONTAINER_STATE"
fi

# Step 6: Display deployment summary
echo ""
echo "🎉 Deployment Complete!"
echo "======================"
echo "Container Name: $CONTAINER_NAME"
echo "Image: $IMAGE_NAME"
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"
echo "State: $CONTAINER_STATE"

if [[ -n "$CONTAINER_IP" ]]; then
    echo "Public IP: $CONTAINER_IP"
fi

if [[ -n "$CONTAINER_FQDN" ]]; then
    echo "FQDN: $CONTAINER_FQDN"
    echo "HTTP URL: http://$CONTAINER_FQDN"
    echo "HTTPS URL: https://$CONTAINER_FQDN"
fi

# Step 7: Save deployment info
cat > "$TEMP_DIR/deployment-info.json" << EOF
{
  "deployment": {
    "container_name": "$CONTAINER_NAME",
    "image_name": "$IMAGE_NAME",
    "environment": "$ENVIRONMENT",
    "resource_group": "$RESOURCE_GROUP",
    "location": "$LOCATION",
    "deployment_time": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "container": {
    "state": "$CONTAINER_STATE",
    "public_ip": "$CONTAINER_IP",
    "fqdn": "$CONTAINER_FQDN",
    "http_url": "http://$CONTAINER_FQDN",
    "https_url": "https://$CONTAINER_FQDN"
  },
  "azure": {
    "subscription_id": "$(az account show --query id -o tsv)",
    "resource_group": "$RESOURCE_GROUP",
    "location": "$LOCATION"
  }
}
EOF

# Copy to results directory if it exists
RESULTS_DIR="$AZURE_DIR/../../../deployment_results"
if [[ -d "$(dirname "$RESULTS_DIR")" ]]; then
    mkdir -p "$RESULTS_DIR"
    cp "$TEMP_DIR/deployment-info.json" "$RESULTS_DIR/azure-container-deployment.json"
    echo "📄 Deployment info saved to: $RESULTS_DIR/azure-container-deployment.json"
fi

echo ""
echo "🔧 Management Commands:"
echo "View logs:    az container logs --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
echo "Stop:         az container stop --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
echo "Start:        az container start --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME'"
echo "Delete:       az container delete --resource-group '$RESOURCE_GROUP' --name '$CONTAINER_NAME' --yes"

echo ""
echo "✨ Deployment completed successfully!"

# Output for GitHub Actions
if [[ -n "$GITHUB_OUTPUT" ]]; then
    echo "container_name=$CONTAINER_NAME" >> "$GITHUB_OUTPUT"
    echo "container_state=$CONTAINER_STATE" >> "$GITHUB_OUTPUT"
    echo "container_ip=$CONTAINER_IP" >> "$GITHUB_OUTPUT"
    echo "container_fqdn=$CONTAINER_FQDN" >> "$GITHUB_OUTPUT"
    echo "resource_group=$RESOURCE_GROUP" >> "$GITHUB_OUTPUT"
    echo "deployment_status=success" >> "$GITHUB_OUTPUT"
fi