targetScope = 'subscription'

param location string = 'eastus2'
param vnetName string = 'MZDev'
param vnetAddressSpace string = '10.221.0.0/24'
param defaultSubnet string = '10.221.0.0/24'
param storageAccountName string = 'diagstoragenestedvirtua'

@description('Tags to be applied to all resources.')
param tags object = {}

// VMs
@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v3'

param adminUsername string

@secure()
param adminCreds string

param vmOsType string = 'Windows'

@description('VM image publisher. Use MicrosoftWindowsServer for Server or MicrosoftWindowsDesktop for Windows 11.')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('VM image offer. Use WindowsServer for Server or Windows-11 for Windows 11.')
param imageOffer string = 'WindowsServer'

@description('VM image SKU. E.g. 2025-datacenter-g2 for Server or win11-24h2-ent for Windows 11.')
param imageSku string = '2025-datacenter-g2'

@description('Resource Group name.')
param rgName string

@description('Allowed source IP or CIDR for RDP access (port 3389).')
param allowedRdpSourceAddress string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

module nsg './modules/Nsg.bicep' = {
  name: 'nsg'
  scope: resourceGroup
  params: {
    location: location
    allowedRdpSourceAddress: allowedRdpSourceAddress
    tags: tags
  }
}

module vnet './modules/Vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup
  params: {
    location: location
    vnetname: vnetName
    addressprefix: vnetAddressSpace
    defaultsubnetprefix: defaultSubnet
    nsgId: nsg.outputs.nsgId
    tags: tags
  }
}

module diagnosticstorageaccount './modules/StorageAccount.bicep' = {
  name: 'diagnosticstorageaccount'
  scope: resourceGroup
  params: {
    storageAccountName: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    tags: tags
  }
}

module vm './modules/Vm.bicep' = {
  name: 'vm'
  scope: resourceGroup
  params: {
    vmName: 'ADTest'
    vmLocation: location
    vmSize: vmSize
    vmOsType: vmOsType
    vmNicSubnetId: vnet.outputs.defaultsubnetid
    adminUsername: adminUsername
    adminCreds: adminCreds
    diagnosticsStorageUri: diagnosticstorageaccount.outputs.blobUri
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    licenseType: 'Windows_Server'
    tags: tags
  }
}

output RGId string = resourceGroup.id
output RGName string = resourceGroup.name
output VMName string = vm.outputs.VirtualMachineName
output VMPrivateIPAddress string = vm.outputs.VirtualMachinePrivateIPAddress
output VMPublicIpAddress string = vm.outputs.VirtualMachinePublicIPAddress
