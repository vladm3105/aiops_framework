@description('Name of the container instance')
param containerName string = 'simple-app'

@description('Container image name')
param imageName string = 'nginx:latest'

@description('Deployment environment')
@allowed([
  'development'
  'staging'
  'production'
])
param environment string = 'development'

@description('Location for the container instance')
param location string = resourceGroup().location

@description('CPU cores for the container')
param cpuCores string = '1.0'

@description('Memory in GB for the container')
param memoryInGB string = '1.5'

@description('Ports to expose on the container')
param ports array = [
  {
    port: 80
    protocol: 'TCP'
  }
  {
    port: 443
    protocol: 'TCP'
  }
]

@description('DNS name label for the container')
param dnsNameLabel string = '${containerName}-${environment}-${uniqueString(resourceGroup().id)}'

@description('Container restart policy')
@allowed([
  'Always'
  'Never'
  'OnFailure'
])
param restartPolicy string = 'Always'

@description('Container registry server (leave empty for public images)')
param registryServer string = ''

@description('Container registry username')
param registryUsername string = ''

@description('Container registry password')
@secure()
param registryPassword string = ''

@description('Enable container logging')
param enableLogging bool = true

@description('Log Analytics workspace ID (optional)')
param logAnalyticsWorkspaceId string = ''

@description('Log Analytics workspace key (optional)')
@secure()
param logAnalyticsWorkspaceKey string = ''

@description('Enable managed identity for the container')
param enableManagedIdentity bool = false

@description('Network profile resource ID for VNet integration')
param networkProfileId string = ''

@description('Volume mounts configuration')
param volumes array = []

@description('Additional environment variables')
param additionalEnvironmentVariables array = []

// Variables
var containerGroupName = containerName
var hasRegistry = !empty(registryServer)
var hasLogAnalytics = !empty(logAnalyticsWorkspaceId) && !empty(logAnalyticsWorkspaceKey)
var hasNetworkProfile = !empty(networkProfileId)

var baseEnvironmentVariables = [
  {
    name: 'ENVIRONMENT'
    value: environment
  }
  {
    name: 'DEPLOYED_BY'
    value: 'Azure-Bicep-Template'
  }
  {
    name: 'DEPLOYMENT_TIME'
    value: utcNow()
  }
  {
    name: 'CONTAINER_NAME'
    value: containerName
  }
]

var environmentVariables = concat(baseEnvironmentVariables, additionalEnvironmentVariables)

var imageRegistryCredentials = hasRegistry ? [
  {
    server: registryServer
    username: registryUsername
    password: registryPassword
  }
] : []

var logAnalyticsConfiguration = {
  logType: 'LogAnalytics'
  metadata: {}
  options: {
    'log-driver': 'json-file'
    'max-size': '10m'
    'max-file': '3'
  }
  logAnalytics: {
    workspaceId: logAnalyticsWorkspaceId
    workspaceKey: logAnalyticsWorkspaceKey
  }
}

var defaultLogConfiguration = {
  logType: 'ContainerInsights'
  metadata: {}
  options: {
    'log-driver': 'json-file'
    'max-size': '10m'
    'max-file': '3'
  }
}

// Resources
resource containerGroup 'Microsoft.ContainerInstance/containerGroups@2021-07-01' = {
  name: containerGroupName
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'Claude-Agent'
    Framework: 'AI-DevOps'
    DeployedAt: utcNow()
    Version: '1.0.0'
  }
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    containers: [
      {
        name: containerName
        properties: {
          image: imageName
          ports: ports
          environmentVariables: environmentVariables
          resources: {
            requests: {
              cpu: cpuCores
              memoryInGB: memoryInGB
            }
          }
          volumeMounts: volumes
          livenessProbe: {
            httpGet: {
              path: '/health'
              port: 80
              scheme: 'Http'
            }
            initialDelaySeconds: 30
            periodSeconds: 30
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 5
          }
          readinessProbe: {
            httpGet: {
              path: '/ready'
              port: 80
              scheme: 'Http'
            }
            initialDelaySeconds: 10
            periodSeconds: 10
            failureThreshold: 3
            successThreshold: 1
            timeoutSeconds: 3
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: restartPolicy
    ipAddress: hasNetworkProfile ? null : {
      type: 'Public'
      ports: ports
      dnsNameLabel: dnsNameLabel
    }
    networkProfile: hasNetworkProfile ? {
      id: networkProfileId
    } : null
    imageRegistryCredentials: imageRegistryCredentials
    diagnostics: enableLogging ? (hasLogAnalytics ? logAnalyticsConfiguration : defaultLogConfiguration) : null
    volumes: volumes
  }
}

// Outputs
@description('Name of the created container')
output containerName string = containerName

@description('Name of the container group')
output containerGroupName string = containerGroupName

@description('Public IP address of the container')
output publicIpAddress string = hasNetworkProfile ? '' : containerGroup.properties.ipAddress.ip

@description('Fully qualified domain name of the container')
output fqdn string = hasNetworkProfile ? '' : containerGroup.properties.ipAddress.fqdn

@description('Current state of the container')
output containerState string = containerGroup.properties.instanceView.state

@description('HTTP URL to access the container')
output httpUrl string = hasNetworkProfile ? '' : 'http://${containerGroup.properties.ipAddress.fqdn}'

@description('HTTPS URL to access the container')
output httpsUrl string = hasNetworkProfile ? '' : 'https://${containerGroup.properties.ipAddress.fqdn}'

@description('Resource ID of the container group')
output resourceId string = containerGroup.id

@description('Managed identity principal ID (if enabled)')
output managedIdentityPrincipalId string = enableManagedIdentity ? containerGroup.identity.principalId : ''

@description('Managed identity tenant ID (if enabled)')
output managedIdentityTenantId string = enableManagedIdentity ? containerGroup.identity.tenantId : ''