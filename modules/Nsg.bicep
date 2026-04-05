@description('Specifies the Azure location where the resource should be created.')
param location string

@description('Allowed source IP or CIDR for RDP access (port 3389).')
param allowedRdpSourceAddress string

@description('Tags for the NSG.')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'default-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: allowedRdpSourceAddress
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  tags: tags
}

output nsgId string = nsg.id
