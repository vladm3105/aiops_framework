@description('Main deployment template for Azure Container Instances with AI DevOps framework')

// Parameters
@description('Base name for all resources')
param baseName string = 'aidevops'

@description('Environment for deployment')
@allowed([
  'development'
  'staging'
  'production'
])
param environment string = 'development'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Container image to deploy')
param containerImage string = 'nginx:latest'

@description('Enable Azure Container Registry')
param enableContainerRegistry bool = true

@description('Container registry SKU')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param registrySku string = 'Basic'

@description('Enable Log Analytics workspace')
param enableLogAnalytics bool = true

@description('CPU cores for the container')
param cpuCores string = '1.0'

@description('Memory in GB for the container')
param memoryInGB string = '1.5'

@description('Enable managed identity')
param enableManagedIdentity bool = false

@description('Additional environment variables for the container')
param additionalEnvironmentVariables array = []

@description('Enable vulnerability scanning (Premium SKU only)')
param enableVulnerabilityScanning bool = false

@description('Container restart policy')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

// Variables
var resourcePrefix = '${baseName}-${environment}'
var containerName = '${resourcePrefix}-app'
var registryName = '${toLower(replace(baseName, '-', ''))}${toLower(environment)}acr'
var logAnalyticsWorkspaceName = '${resourcePrefix}-law'
var dnsNameLabel = '${containerName}-${uniqueString(resourceGroup().id)}'

var environmentSpecificSettings = {
  development: {
    cpuCores: '0.5'
    memoryInGB: '1.0'
    registrySku: 'Basic'
  }
  staging: {
    cpuCores: '1.0'
    memoryInGB: '2.0'
    registrySku: 'Standard'
  }
  production: {
    cpuCores: '2.0'
    memoryInGB: '4.0'
    registrySku: 'Premium'
  }
}

var actualSettings = environmentSpecificSettings[environment]
var finalCpuCores = cpuCores != '1.0' ? cpuCores : actualSettings.cpuCores
var finalMemoryInGB = memoryInGB != '1.5' ? memoryInGB : actualSettings.memoryInGB
var finalRegistrySku = registrySku != 'Basic' ? registrySku : actualSettings.registrySku

// Modules

// Log Analytics Workspace
module logAnalytics 'modules/log-analytics.bicep' = if (enableLogAnalytics) {
  name: 'logAnalyticsDeployment'
  params: {
    workspaceName: logAnalyticsWorkspaceName
    location: location
    environment: environment
    retentionInDays: environment == 'production' ? 90 : 30
  }
}

// Azure Container Registry
module containerRegistry 'container-registry.bicep' = if (enableContainerRegistry) {
  name: 'containerRegistryDeployment'
  params: {
    registryName: registryName
    location: location
    sku: finalRegistrySku
    environment: environment
    adminUserEnabled: true
    enableVulnerabilityScanning: enableVulnerabilityScanning && finalRegistrySku == 'Premium'
    enableContentTrust: finalRegistrySku == 'Premium'
    dataEndpointEnabled: finalRegistrySku == 'Premium'
  }
}

// Container Instance
module containerInstance 'container-instance.bicep' = {
  name: 'containerInstanceDeployment'
  params: {
    containerName: containerName
    imageName: containerImage
    environment: environment
    location: location
    cpuCores: finalCpuCores
    memoryInGB: finalMemoryInGB
    dnsNameLabel: dnsNameLabel
    restartPolicy: restartPolicy
    enableLogging: enableLogAnalytics
    logAnalyticsWorkspaceId: enableLogAnalytics ? logAnalytics.outputs.workspaceId : ''
    logAnalyticsWorkspaceKey: enableLogAnalytics ? logAnalytics.outputs.primarySharedKey : ''
    enableManagedIdentity: enableManagedIdentity
    additionalEnvironmentVariables: additionalEnvironmentVariables
    registryServer: enableContainerRegistry ? containerRegistry.outputs.loginServer : ''
    registryUsername: enableContainerRegistry ? containerRegistry.outputs.adminUsername : ''
    registryPassword: enableContainerRegistry ? listCredentials(containerRegistry.outputs.resourceId, '2023-01-01-preview').passwords[0].value : ''
  }
  dependsOn: [
    logAnalytics
    containerRegistry
  ]
}

// Role assignments for managed identity (if enabled)
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableManagedIdentity && enableContainerRegistry) {
  name: guid(resourceGroup().id, containerInstance.outputs.managedIdentityPrincipalId, 'AcrPull')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: containerInstance.outputs.managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
@description('Container instance details')
output containerInstance object = {
  name: containerInstance.outputs.containerName
  resourceId: containerInstance.outputs.resourceId
  publicIpAddress: containerInstance.outputs.publicIpAddress
  fqdn: containerInstance.outputs.fqdn
  httpUrl: containerInstance.outputs.httpUrl
  httpsUrl: containerInstance.outputs.httpsUrl
  state: containerInstance.outputs.containerState
}

@description('Container registry details')
output containerRegistry object = enableContainerRegistry ? {
  name: containerRegistry.outputs.registryName
  loginServer: containerRegistry.outputs.loginServer
  resourceId: containerRegistry.outputs.resourceId
  adminUsername: containerRegistry.outputs.adminUsername
  sku: containerRegistry.outputs.sku
} : {}

@description('Log Analytics workspace details')
output logAnalytics object = enableLogAnalytics ? {
  name: logAnalytics.outputs.workspaceName
  workspaceId: logAnalytics.outputs.workspaceId
  resourceId: logAnalytics.outputs.resourceId
} : {}

@description('Managed identity details')
output managedIdentity object = enableManagedIdentity ? {
  principalId: containerInstance.outputs.managedIdentityPrincipalId
  tenantId: containerInstance.outputs.managedIdentityTenantId
} : {}

@description('Deployment summary')
output deploymentSummary object = {
  baseName: baseName
  environment: environment
  location: location
  containerImage: containerImage
  resources: {
    containerInstance: containerInstance.outputs.containerName
    containerRegistry: enableContainerRegistry ? containerRegistry.outputs.registryName : 'Not deployed'
    logAnalytics: enableLogAnalytics ? logAnalytics.outputs.workspaceName : 'Not deployed'
  }
  access: {
    httpUrl: containerInstance.outputs.httpUrl
    httpsUrl: containerInstance.outputs.httpsUrl
    healthCheck: '${containerInstance.outputs.httpUrl}/health'
    readinessCheck: '${containerInstance.outputs.httpUrl}/ready'
  }
  managementCommands: {
    viewLogs: 'az container logs --resource-group ${resourceGroup().name} --name ${containerInstance.outputs.containerName}'
    restart: 'az container restart --resource-group ${resourceGroup().name} --name ${containerInstance.outputs.containerName}'
    delete: 'az container delete --resource-group ${resourceGroup().name} --name ${containerInstance.outputs.containerName} --yes'
  }
}