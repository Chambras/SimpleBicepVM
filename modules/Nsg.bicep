@description('Specifies the Azure location where the resource should be created.')
param location string

@description('Allowed source IPs or CIDRs for RDP access (port 3389).')
param allowedRdpSourceAddresses array

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
          sourceAddressPrefixes: allowedRdpSourceAddresses
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
  tags: tags
}

output nsgId string = nsg.id
