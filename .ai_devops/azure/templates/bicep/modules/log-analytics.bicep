@description('Log Analytics workspace deployment for container monitoring')

// Parameters
@description('Name of the Log Analytics workspace')
param workspaceName string

@description('Location for the workspace')
param location string = resourceGroup().location

@description('Environment tag')
param environment string = 'development'

@description('Data retention in days')
@minValue(30)
@maxValue(730)
param retentionInDays int = 30

@description('SKU for the workspace')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param sku string = 'PerGB2018'

@description('Daily quota in GB (0 = no limit)')
@minValue(0)
param dailyQuotaGb int = 0

@description('Enable public network access')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForIngestion string = 'Enabled'

@description('Enable public network access for query')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccessForQuery string = 'Enabled'

@description('Enable solutions for container monitoring')
param enableContainerInsights bool = true

// Variables
var workspaceNameCleaned = toLower(replace(workspaceName, ' ', '-'))

// Resources
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceNameCleaned
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'Claude-Agent'
    Framework: 'AI-DevOps'
    Purpose: 'Container-Monitoring'
    CreatedAt: utcNow()
  }
  properties: {
    sku: {
      name: sku
    }
    retentionInDays: retentionInDays
    workspaceCapping: dailyQuotaGb > 0 ? {
      dailyQuotaGb: dailyQuotaGb
    } : null
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
  }
}

// Container Insights solution
resource containerInsightsSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableContainerInsights) {
  name: 'ContainerInsights(${logAnalyticsWorkspace.name})'
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'Claude-Agent'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
  plan: {
    name: 'ContainerInsights(${logAnalyticsWorkspace.name})'
    product: 'OMSGallery/ContainerInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

// Azure Monitor for containers data collection rule
resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = if (enableContainerInsights) {
  name: '${workspaceNameCleaned}-dcr'
  location: location
  tags: {
    Environment: environment
    ManagedBy: 'Claude-Agent'
  }
  properties: {
    description: 'Data collection rule for container insights'
    dataSources: {
      extensions: [
        {
          name: 'ContainerInsightsExtension'
          extensionName: 'ContainerInsights'
          extensionSettings: {
            dataCollectionSettings: {
              interval: '1m'
              namespaceFilteringMode: 'Off'
              enableContainerLogV2: true
            }
          }
          streams: [
            'Microsoft-ContainerInsights-Group-Default'
            'Microsoft-ContainerLog'
            'Microsoft-ContainerLogV2'
            'Microsoft-KubeEvents'
            'Microsoft-KubeHealth'
            'Microsoft-KubeMonAgentEvents'
            'Microsoft-KubeNodeInventory'
            'Microsoft-KubePodInventory'
            'Microsoft-KubeServices'
            'Microsoft-Perf'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [
        {
          name: 'ciworkspace'
          workspaceResourceId: logAnalyticsWorkspace.id
        }
      ]
    }
    dataFlows: [
      {
        streams: [
          'Microsoft-ContainerInsights-Group-Default'
          'Microsoft-ContainerLog'
          'Microsoft-ContainerLogV2'
          'Microsoft-KubeEvents'
          'Microsoft-KubeHealth'
          'Microsoft-KubeMonAgentEvents'
          'Microsoft-KubeNodeInventory'
          'Microsoft-KubePodInventory'
          'Microsoft-KubeServices'
          'Microsoft-Perf'
        ]
        destinations: [
          'ciworkspace'
        ]
      }
    ]
  }
}

// Sample queries for container monitoring
resource savedSearches 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = [for (query, index) in containerQueries: {
  name: '${logAnalyticsWorkspace.name}/${query.name}'
  properties: {
    category: 'Container Monitoring'
    displayName: query.displayName
    query: query.queryText
    tags: [
      {
        name: 'Environment'
        value: environment
      }
      {
        name: 'Type'
        value: 'Container'
      }
    ]
  }
}]

// Variables for container monitoring queries
var containerQueries = [
  {
    name: 'container-errors'
    displayName: 'Container Errors'
    queryText: 'ContainerLog | where LogEntry contains "error" or LogEntry contains "ERROR" | order by TimeGenerated desc | limit 100'
  }
  {
    name: 'container-restarts'
    displayName: 'Container Restarts'
    queryText: 'KubePodInventory | where PodRestartCount > 0 | summarize RestartCount = sum(PodRestartCount) by Computer, Name | order by RestartCount desc'
  }
  {
    name: 'container-performance'
    displayName: 'Container Performance'
    queryText: 'Perf | where ObjectName == "Container" and CounterName == "% Processor Time" | summarize AvgCPU = avg(CounterValue) by Computer, InstanceName | order by AvgCPU desc'
  }
  {
    name: 'container-memory-usage'
    displayName: 'Container Memory Usage'
    queryText: 'Perf | where ObjectName == "Container" and CounterName == "Memory Usage MB" | summarize AvgMemory = avg(CounterValue) by Computer, InstanceName | order by AvgMemory desc'
  }
]

// Outputs
@description('Log Analytics workspace name')
output workspaceName string = logAnalyticsWorkspace.name

@description('Log Analytics workspace ID')
output workspaceId string = logAnalyticsWorkspace.properties.customerId

@description('Log Analytics workspace resource ID')
output resourceId string = logAnalyticsWorkspace.id

@description('Primary shared key for the workspace')
output primarySharedKey string = logAnalyticsWorkspace.listKeys().primarySharedKey

@description('Secondary shared key for the workspace')
output secondarySharedKey string = logAnalyticsWorkspace.listKeys().secondarySharedKey

@description('Location of the workspace')
output location string = logAnalyticsWorkspace.location

@description('Retention period in days')
output retentionInDays int = retentionInDays

@description('Data collection rule resource ID')
output dataCollectionRuleId string = enableContainerInsights ? dataCollectionRule.id : ''

@description('Container Insights solution state')
output containerInsightsEnabled bool = enableContainerInsights

@description('Workspace provisioning state')
output provisioningState string = logAnalyticsWorkspace.properties.provisioningState