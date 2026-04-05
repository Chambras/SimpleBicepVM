# Deploy Windows VM

Simple bicep module to quickly deploy and test a Windows VM.

It creates the following resources:

- Azure Resource Group.
- A Network Security Group (NSG) with RDP access restricted to a specified source IP.
- A Vnet.
- A Default Subnet (associated with the NSG).
- A Storage Account with a file share.
- A Windows Server 2025 VM (configurable for Windows 11 Desktop).
- A Public IP address.

## Project Structure

```ssh
├── README.md
├── deploy.bicep
├── modules
│   ├── Nsg.bicep
│   ├── StorageAccount.bicep
│   ├── Vm.bicep
│   └── Vnet.bicep
└── parameters.json
```

## Prerequisites

It assumes you have access to an Azure Subscription and you have [az cli installed and configured](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). You also need to have [bicep installed.](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install)

### versions

This bicep script has been tested using the following versions:

- Azure CLI 2.40.0
- Bicep 0.11.1

## Parameters

You can use the _parameters.json_ file to customize the deployment.

### Required parameters

| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `rgName` | String |  |  | Resource Group Name. |
| `location` | String | eastus2 |  | Location for all resources. |
| `storageAccountName` | String | diagstoragenestedvirtua |  | Storage account where to store the boot diagnostics. |
| `adminUsername` | String |  |  | Administrator username. |
| `adminCreds` | secureString |  |  | The password for the VM. Prompted at deploy time. |
| `vmSize` | String | Standard_D2s_v3 |  | Specifies the size for the VM. |
| `vmOsType` | String | Windows | Windows, Linux | OS type for the VM disk. |
| `allowedRdpSourceAddress` | String |  |  | Source IP or CIDR allowed for RDP access (port 3389). |
| `imagePublisher` | String | MicrosoftWindowsServer |  | VM image publisher. Use `MicrosoftWindowsDesktop` for Windows 11. |
| `imageOffer` | String | WindowsServer |  | VM image offer. Use `Windows-11` for Windows 11. |
| `imageSku` | String | 2025-datacenter-g2 |  | VM image SKU. E.g. `win11-24h2-ent` for Windows 11. |
| `tags` | object |  |  | Tags to be applied to all resources. |

## Validate, Plan and Create

```ssh
az deployment sub validate -n TestDev -f deploy.bicep -p @parameters.json -l eastus2 -o table
az deployment sub create -n TestDev -f deploy.bicep -p @parameters.json -l eastus2 -w
az deployment sub create -n TestDev -f deploy.bicep -p @parameters.json -l eastus2
```

During deployment you will be prompted for the password for the administrator account, and the allowed RDP source address.

## List the deployment outputs

The script outputs the following information: the Resource Group ID, the Resource Group Name, the VM Name, the VM private IP address and the VM public IP address.

```ssh
az deployment sub show -n TestDev --query "properties.outputs" -o yaml
```

## Clean resources

```ssh
az deployment sub delete -n TestDev
az deployment group delete -n {{ResourceGroupName}}
```

## Caution

Be aware that by running this script your account will get billed.

## Authors

- Marcelo Zambrana
