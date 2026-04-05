param vmName string
param vmLocation string

@description('Specifies the size for the VM.')
param vmSize string
param vmOsType string
param vmNicSubnetId string
param diagnosticsStorageUri string
param licenseType string = ''

@description('Required. Administrator username.')
@secure()
param adminUsername string

@description('Required. The password to be used for the Windows VM.')
@secure()
param adminCreds string

@description('Tags for the VM')
param tags object = {}

@description('VM image publisher. Use MicrosoftWindowsServer for Server or MicrosoftWindowsDesktop for Windows 11.')
param imagePublisher string = 'MicrosoftWindowsServer'

@description('VM image offer. Use WindowsServer for Server or Windows-11 for Windows 11.')
param imageOffer string = 'WindowsServer'

@description('VM image SKU. E.g. 2025-datacenter-g2 for Server or win11-24h2-ent for Windows 11.')
param imageSku string = '2025-datacenter-g2'

var vmOsDiskName = '${vmName}od01'
var vmNicName = '${vmName}ni01'
var vmPipName = '${vmName}pip01'

resource Pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: vmPipName
  location: vmLocation
  sku: {
    name: 'Basic'
  }
  properties:{
    publicIPAllocationMethod:'Dynamic'
  }
  tags: tags
}

resource Nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: vmNicName
  location: vmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vmNicSubnetId
          }
          primary: true
          publicIPAddress: {
            id: Pip.id
          }
        }
      }
    ]
    dnsSettings: {
      dnsServers: []
    }
    enableAcceleratedNetworking: false
    enableIPForwarding: false
  }
  tags: tags
}

resource VirtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: vmLocation
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        name: vmOsDiskName
        createOption: 'FromImage'
        osType: vmOsType
        managedDisk:{
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminCreds
    }
    diagnosticsProfile:{
      bootDiagnostics:{
        enabled: true
        storageUri: diagnosticsStorageUri
      }
    }
    licenseType: licenseType
    networkProfile: {
      networkInterfaces: [
        {
          id: Nic.id
        }
      ]
    }
  }
  tags: tags
}

output VirtualMachineId string = VirtualMachine.id
output VirtualMachineName string = VirtualMachine.name
output VirtualMachinePrivateIPAddress string = Nic.properties.ipConfigurations[0].properties.privateIPAddress
output VirtualMachinePublicIPAddress string = Pip.properties.ipAddress
