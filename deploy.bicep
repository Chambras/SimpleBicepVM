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
param VmSize string = 'Standard_D2s_v3'

@secure()
param adminUsername string

@secure()
param adminCreds string

param VmOsType string = 'Windows' 


@description('Resource Group name.')
param rgName string


resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: rgName
  location: location
  tags: tags
}

module vnet './modules/Vnet.bicep' = {
  name: 'vnet'
  scope: resourceGroup
  params: {
    location: location
    vnetname: vnetName
    addressprefix: vnetAddressSpace
    defaultsubnetprefix: defaultSubnet
    tags: tags
  }
}

module diagnosticstorageaccount './modules/StorageAccount.bicep' = {
  name: 'diagnosticstorageaccount' 
  scope: resourceGroup
  params:{
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
    VmName: 'ADTest'
    VmLocation: location
    VmSize: VmSize
    VmOsType: VmOsType 
    VmNicSubnetId: vnet.outputs.defaultsubnetid
    adminUsername: adminUsername 
    adminCreds: adminCreds
    diagnosticsStorageUri: diagnosticstorageaccount.outputs.blobUri
    licenseType: 'Windows_Server'
    tags: tags
  }
  dependsOn:[
    vnet
    diagnosticstorageaccount
  ]
}

/*module vm2 './modules/Vm.bicep' = {
  name: 'vm2'
  scope: resourceGroup
  params: {
    VmName: 'ADTest2'
    VmLocation: location
    sharedImageGallerySubscriptionID: sharedImageGallerySubscriptionID
    sharedImageGalleryRGName: sharedImageGalleryRGName
    sharedImageGalleryName: sharedImageGalleryName
    sharedImageGalleryImageName: sharedImageGalleryImageName
    VmSize: VmSize
    VmOsType: VmOsType 
    VmNicSubnetId: vnet.outputs.defaultsubnetid
    adminUsername: adminUsername 
    adminCreds: adminCreds
    diagnosticsStorageUri: diagnosticstorageaccount.outputs.blobUri
    licenseType: 'Windows_Server'
    tags: tags
  }
  dependsOn:[
    vnet
    diagnosticstorageaccount
  ]
}
*/
output RGId string = resourceGroup.id
output RGName string = resourceGroup.name
output VMName string = vm.outputs.VirtualMachineName
output VMPrivateIPAddress string = vm.outputs.VirtualMachinePrivateIPAddress
output VMPublicIpAddress string = vm.outputs.VirtualMachinePublicIPAddress
//output VMPublicIpAddress2 string = vm2.outputs.VirtualMachinePublicIPAddress
