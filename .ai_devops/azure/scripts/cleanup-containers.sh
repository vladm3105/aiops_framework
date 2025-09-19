#!/bin/bash

# Azure Container Cleanup Script
# Clean up Azure Container Instances and related resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AZURE_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$AZURE_DIR/configs/azure-deployment.json"

echo "🧹 Azure Container Cleanup"
echo "========================="

# Parse command line arguments
ACTION="${1:-list}"
RESOURCE_GROUP="${2:-rg-containers}"
CONTAINER_NAME="${3:-}"

echo "Action: $ACTION"
echo "Resource Group: $RESOURCE_GROUP"
if [[ -n "$CONTAINER_NAME" ]]; then
    echo "Container Name: $CONTAINER_NAME"
fi

# Check prerequisites
if ! command -v az &> /dev/null; then
    echo "❌ Azure CLI not found"
    exit 1
fi

if ! az account show > /dev/null 2>&1; then
    echo "❌ Not authenticated with Azure"
    exit 1
fi

case "$ACTION" in
    "list")
        echo "📋 Listing containers in resource group: $RESOURCE_GROUP"
        
        if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
            CONTAINERS=$(az container list --resource-group "$RESOURCE_GROUP" --query "[].{Name:name,State:instanceView.state,IP:ipAddress.ip,FQDN:ipAddress.fqdn}" -o table)
            
            if [[ -n "$CONTAINERS" ]]; then
                echo "$CONTAINERS"
            else
                echo "No containers found in resource group: $RESOURCE_GROUP"
            fi
        else
            echo "Resource group '$RESOURCE_GROUP' not found"
        fi
        ;;
        
    "delete")
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "❌ Container name required for delete action"
            echo "Usage: $0 delete <resource-group> <container-name>"
            exit 1
        fi
        
        echo "🗑️  Deleting container: $CONTAINER_NAME"
        
        if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
            az container delete \
                --resource-group "$RESOURCE_GROUP" \
                --name "$CONTAINER_NAME" \
                --yes
            echo "✅ Container '$CONTAINER_NAME' deleted successfully"
        else
            echo "Container '$CONTAINER_NAME' not found in resource group '$RESOURCE_GROUP'"
        fi
        ;;
        
    "delete-all")
        echo "🗑️  Deleting ALL containers in resource group: $RESOURCE_GROUP"
        echo "⚠️  This action cannot be undone!"
        
        read -p "Are you sure? (y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            CONTAINER_NAMES=$(az container list --resource-group "$RESOURCE_GROUP" --query "[].name" -o tsv)
            
            if [[ -n "$CONTAINER_NAMES" ]]; then
                while IFS= read -r container; do
                    echo "Deleting: $container"
                    az container delete \
                        --resource-group "$RESOURCE_GROUP" \
                        --name "$container" \
                        --yes
                done <<< "$CONTAINER_NAMES"
                echo "✅ All containers deleted successfully"
            else
                echo "No containers found to delete"
            fi
        else
            echo "Operation cancelled"
        fi
        ;;
        
    "logs")
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "❌ Container name required for logs action"
            echo "Usage: $0 logs <resource-group> <container-name>"
            exit 1
        fi
        
        echo "📜 Fetching logs for container: $CONTAINER_NAME"
        
        if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
            az container logs \
                --resource-group "$RESOURCE_GROUP" \
                --name "$CONTAINER_NAME"
        else
            echo "Container '$CONTAINER_NAME' not found"
        fi
        ;;
        
    "status")
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "❌ Container name required for status action"
            echo "Usage: $0 status <resource-group> <container-name>"
            exit 1
        fi
        
        echo "📊 Status for container: $CONTAINER_NAME"
        
        if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
            az container show \
                --resource-group "$RESOURCE_GROUP" \
                --name "$CONTAINER_NAME" \
                --query "{Name:name,State:instanceView.state,RestartCount:instanceView.restartCount,IP:ipAddress.ip,FQDN:ipAddress.fqdn,CPU:containers[0].resources.requests.cpu,Memory:containers[0].resources.requests.memoryInGB}" \
                -o table
        else
            echo "Container '$CONTAINER_NAME' not found"
        fi
        ;;
        
    "stop")
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "❌ Container name required for stop action"
            echo "Usage: $0 stop <resource-group> <container-name>"
            exit 1
        fi
        
        echo "⏹️  Stopping container: $CONTAINER_NAME"
        
        if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
            az container stop \
                --resource-group "$RESOURCE_GROUP" \
                --name "$CONTAINER_NAME"
            echo "✅ Container stopped successfully"
        else
            echo "Container '$CONTAINER_NAME' not found"
        fi
        ;;
        
    "start")
        if [[ -z "$CONTAINER_NAME" ]]; then
            echo "❌ Container name required for start action"
            echo "Usage: $0 start <resource-group> <container-name>"
            exit 1
        fi
        
        echo "▶️  Starting container: $CONTAINER_NAME"
        
        if az container show --resource-group "$RESOURCE_GROUP" --name "$CONTAINER_NAME" > /dev/null 2>&1; then
            az container start \
                --resource-group "$RESOURCE_GROUP" \
                --name "$CONTAINER_NAME"
            echo "✅ Container started successfully"
        else
            echo "Container '$CONTAINER_NAME' not found"
        fi
        ;;
        
    *)
        echo "❌ Unknown action: $ACTION"
        echo ""
        echo "Available actions:"
        echo "  list                                    - List all containers in resource group"
        echo "  delete <resource-group> <container>     - Delete specific container"
        echo "  delete-all <resource-group>             - Delete all containers in resource group"
        echo "  logs <resource-group> <container>       - Show container logs"
        echo "  status <resource-group> <container>     - Show container status"
        echo "  stop <resource-group> <container>       - Stop container"
        echo "  start <resource-group> <container>      - Start container"
        echo ""
        echo "Examples:"
        echo "  $0 list rg-containers"
        echo "  $0 delete rg-containers my-app"
        echo "  $0 logs rg-containers my-app"
        exit 1
        ;;
esac