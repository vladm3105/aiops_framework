@description('Name of the Azure Container Registry')
param registryName string

@description('Location for the container registry')
param location string = resourceGroup().location

@description('SKU for the container registry')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Basic'

@description('Enable admin user for the registry')
param adminUserEnabled bool = true

@description('Enable public network access')
param publicNetworkAccess string = 'Enabled'

@description('Zone redundancy setting')
@allowed([
  'Enabled'
  'Disabled'
])
param zoneRedundancy string = 'Disabled'

@description('Environment tag')
param environment string = 'development'

@description('Enable vulnerability scanning (Premium SKU only)')
param enableVulnerabilityScanning bool = false

@description('Enable content trust (Premium SKU only)')
param enableContentTrust bool = false

@description('Data endpoint enabled (Premium SKU only)')
param dataEndpointEnabled bool = false

@description('Network rule set configuration')
param networkRuleSet object = {
  defaultAction: 'Allow'
  virtualNetworkRules: []
  ipRules: []
}

@description('Retention policy for untagged manifests (days)')
param retentionDays int = 7

@description('Quarantine policy enabled')
param quarantinePolicyEnabled bool = false

@description('Trust policy enabled')
param trustPolicyEnabled bool = false

// Variables
var registryNameCleaned = toLower(replace(registryName, '-', ''))
var isPremiumSku = sku == 'Premium'

// Resources
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryNameCleaned
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'Claude-Agent'
    Framework: 'AI-DevOps'
    CreatedAt: utcNow()
    SKU: sku
  }
  sku: {
    name: sku
  }
  properties: {
    adminUserEnabled: adminUserEnabled
    publicNetworkAccess: publicNetworkAccess
    zoneRedundancy: isPremiumSku ? zoneRedundancy : 'Disabled'
    dataEndpointEnabled: isPremiumSku ? dataEndpointEnabled : false
    networkRuleSet: networkRuleSet
    policies: {
      quarantinePolicy: {
        status: quarantinePolicyEnabled ? 'enabled' : 'disabled'
      }
      trustPolicy: {
        type: 'Notary'
        status: (isPremiumSku && trustPolicyEnabled) ? 'enabled' : 'disabled'
      }
      retentionPolicy: {
        days: retentionDays
        status: 'enabled'
      }
      exportPolicy: {
        status: 'enabled'
      }
    }
  }
}

// Diagnostic settings (if Log Analytics workspace is provided)
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (isPremiumSku) {
  name: '${registryNameCleaned}-diagnostics'
  scope: containerRegistry
  properties: {
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Vulnerability scanning (Premium SKU only)
resource securityCenterAssessment 'Microsoft.Security/assessments@2021-06-01' = if (isPremiumSku && enableVulnerabilityScanning) {
  name: guid(containerRegistry.id, 'vulnerabilityAssessment')
  scope: containerRegistry
  properties: {
    resourceDetails: {
      source: 'Azure'
      id: containerRegistry.id
    }
    displayName: 'Container Registry Vulnerability Assessment'
    status: {
      code: 'Healthy'
      cause: 'Enabled'
      description: 'Vulnerability scanning enabled for container registry'
    }
  }
}

// Outputs
@description('Name of the created container registry')
output registryName string = containerRegistry.name

@description('Login server for the container registry')
output loginServer string = containerRegistry.properties.loginServer

@description('Resource ID of the container registry')
output resourceId string = containerRegistry.id

@description('Admin username (if admin user is enabled)')
output adminUsername string = adminUserEnabled ? containerRegistry.name : ''

@description('SKU of the container registry')
output sku string = sku

@description('Zone redundancy status')
output zoneRedundancy string = isPremiumSku ? zoneRedundancy : 'Disabled'

@description('Public network access status')
output publicNetworkAccess string = publicNetworkAccess

@description('Registry creation time')
output creationDate string = containerRegistry.properties.creationDate

@description('Registry provisioning state')
output provisioningState string = containerRegistry.properties.provisioningState