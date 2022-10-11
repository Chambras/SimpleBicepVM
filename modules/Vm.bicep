param VmName string
param VmLocation string

@description('Specifies the size for the VM.')
param VmSize string
param VmOsType string 
param VmNicSubnetId string
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

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2012-R2-Datacenter'
  '2016-Datacenter'
  '2019-Datacenter'
  '2019-Datacenter-Core'
  '2019-Datacenter-Core-smalldisk'
  '2019-Datacenter-smalldisk'
  '2022-datacenter'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2019-Datacenter'


var VmOsDiskName = '${VmName}od01'
var VmNicName = '${VmName}ni01'
var VmPipName = '${VmName}pip01'


resource Pip 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: VmPipName
  location: VmLocation
  sku: {
    name: 'Basic'
  }
  properties:{
    publicIPAllocationMethod:'Dynamic'
  }
  tags: tags
}

resource Nic 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: VmNicName
  location: VmLocation
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: VmNicSubnetId
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
  name: VmName
  location: VmLocation
  properties: {
    hardwareProfile: {
      vmSize: VmSize
    }
    storageProfile: {
      osDisk: {
        name: VmOsDiskName
        createOption: 'FromImage'
        osType: VmOsType
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
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
    }
    osProfile: {
      computerName: VmName
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
