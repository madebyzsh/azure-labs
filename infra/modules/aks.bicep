// modules/aks.bicep — AKS cluster for Lab 3
param location string = resourceGroup().location
param environmentName string
param tags object

@description('Name of the existing VNet whose subnet the nodes will join.')
param vnetName string

@description('Name of the existing subnet where node NICs are created.')
param aksSubnetName string

@description('Nodes in the system pool.')
@minValue(1)
@maxValue(3)
param nodeCount int = 2

@description('Node VM size. B-series keeps the lab cheap.')
param nodeVmSize string = 'Standard_B2s'

@description('Overlay pod CIDR. Must NOT overlap the VNet address space.')
param podCidr string = '192.168.0.0/16'

@description('Kubernetes service CIDR. Must NOT overlap the VNet or the pod CIDR.')
param serviceCidr string = '10.20.0.0/16'

@description('CoreDNS service IP. Must fall inside serviceCidr.')
param dnsServiceIp string = '10.20.0.10'

var clusterName = 'aks-${environmentName}'
var networkContributorRoleId = '4d97b98b-1d4f-4787-a291-c67834d212e7'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: aksSubnetName
}

// 1. Identity first — it must exist before we can grant it anything.
resource aksIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-${clusterName}'
  location: location
  tags: tags
}

// 2. Least privilege: Network Contributor scoped to ONE subnet, not the VNet,
//    not the resource group, not the subscription.
resource subnetRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: aksSubnet
  name: guid(aksSubnet.id, aksIdentity.id, networkContributorRoleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', networkContributorRoleId)
    principalId: aksIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// 3. The cluster.
resource aks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: clusterName
  location: location
  tags: tags
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${aksIdentity.id}': {}
    }
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        osDiskType: 'Managed'
        osDiskSizeGB: 32
        type: 'VirtualMachineScaleSets'
        vnetSubnetID: aksSubnet.id
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
      podCidr: podCidr
      serviceCidr: serviceCidr
      dnsServiceIP: dnsServiceIp
    }
  }
  // Bicep infers dependencies from references. The cluster never *references*
  // the role assignment, so without this it could deploy in parallel and fail
  // on permissions. Explicit dependsOn is the fix.
  dependsOn: [
    subnetRoleAssignment
  ]
}

output clusterName string = aks.name
output nodeResourceGroup string = aks.properties.nodeResourceGroup