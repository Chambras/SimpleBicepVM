targetScope = 'subscription'

@description('Azure region for all resources.')
param location string = 'eastus2'

@description('Name of the virtual network.')
param vnetName string = 'MZDev'

@description('Address space for the virtual network.')
param vnetAddressSpace string = '10.221.0.0/24'

@description('Address prefix for the default subnet.')
param defaultSubnet string = '10.221.0.0/24'

@description('Name of the diagnostics storage account.')
param storageAccountName string = 'diagstoragenestedvirtua'

@description('Tags to be applied to all resources.')
param tags object = {}

// VMs
@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v6'

@description('Administrator username.')
param adminUsername string

@secure()
@description('Administrator password. Prompted at deploy time.')
param adminCreds string

@description('OS type for the VM disk.')
@allowed([
  'Windows'
  'Linux'
])
param vmOsType string = 'Windows'

@description('VM image publisher.')
@allowed([
  'MicrosoftWindowsServer'
  'MicrosoftWindowsDesktop'
  'Canonical'
  'RedHat'
])
param imagePublisher string = 'MicrosoftWindowsDesktop'

@description('VM image offer.')
@allowed([
  'WindowsServer'
  'Windows-11'
  'Windows-10'
  '0001-com-ubuntu-server-jammy'
  '0001-com-ubuntu-server-noble'
  'RHEL'
])
param imageOffer string = 'Windows-11'

@description('VM image SKU. Must match the selected publisher and offer.')
@allowed([
  '2025-datacenter-g2'
  '2022-datacenter-g2'
  '2022-datacenter-azure-edition'
  '2019-datacenter-gensecond'
  'win11-24h2-ent'
  'win11-24h2-pro'
  'win11-23h2-ent'
  'win10-22h2-ent-g2'
  '22_04-lts-gen2'
  '24_04-lts-gen2'
  '8-lvm-gen2'
  '9-lvm-gen2'
])
param imageSku string = 'win11-24h2-pro'

@description('Resource Group name.')
param rgName string

@description('Allowed source IPs or CIDRs for RDP access (port 3389).')
param allowedRdpSourceAddresses array

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: rgName
  location: location
  tags: tags
}

module nsg './modules/Nsg.bicep' = {
  name: 'nsg'
  scope: resourceGroup
  params: {
    location: location
    allowedRdpSourceAddresses: allowedRdpSourceAddresses
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
    vmName: 'VMTest'
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
