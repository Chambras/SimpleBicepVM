@description('Name of the virtual machine.')
param vmName string

@description('Azure region for the VM resources.')
param vmLocation string

@description('Specifies the size for the VM.')
param vmSize string

@description('OS type for the VM disk.')
param vmOsType string

@description('Subnet resource ID for the VM NIC.')
param vmNicSubnetId string

@description('Storage account blob URI for boot diagnostics.')
param diagnosticsStorageUri string

@description('Windows license type. Use Windows_Server for hybrid benefit.')
param licenseType string = ''

@description('Required. Administrator username.')
@secure()
param adminUsername string

@description('Required. The password to be used for the Windows VM.')
@secure()
param adminCreds string

@description('Tags for the VM')
param tags object = {}

@description('VM image publisher.')
@allowed([
  'MicrosoftWindowsServer'
  'MicrosoftWindowsDesktop'
  'Canonical'
  'RedHat'
])
param imagePublisher string = 'MicrosoftWindowsServer'

@description('VM image offer.')
@allowed([
  'WindowsServer'
  'Windows-11'
  'Windows-10'
  '0001-com-ubuntu-server-jammy'
  '0001-com-ubuntu-server-noble'
  'RHEL'
])
param imageOffer string = 'WindowsServer'

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
param imageSku string = '2025-datacenter-g2'

var vmOsDiskName = '${vmName}od01'
var vmNicName = '${vmName}ni01'
var vmPipName = '${vmName}pip01'

resource Pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: vmPipName
  location: vmLocation
  sku: {
    name: 'Standard'
  }
  properties:{
    publicIPAllocationMethod:'Static'
  }
  tags: tags
}

resource Nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
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

resource VirtualMachine 'Microsoft.Compute/virtualMachines@2024-07-01' = {
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
    licenseType: vmOsType == 'Windows' ? licenseType : null
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
