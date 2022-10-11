# Deploy Windows VM

Simple bicep module to quickly deploy and test a Windows VM.

It creates the folloing resources:

- Azure Resource Group.
- A Vnet.
- A Default Subnet.
- A Storage Account with a file share.
- A Windows 2019 VM.
- A Public IP address.

## Project Structure

```ssh
├── README.md
├── deploy.bicep
├── modules
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
| `storageAccountName` | String | mvpdiagstorageadtest |  | Storage account where to store the boot diagnostics. |
| `adminUsername` | secureString |  |  | Administrator username. |
| `adminCreds` | secureString |  |  | The password to be used for the Windows VM. |
| `VmSize` | String | Standard_D2s_v3 |  | Specifies the size for the VM. |
| `tags` | object |  |  | Tags to be applied to all resources. |

## Validate, Plan and Create

```ssh
az deployment sub validate -n TestDev -f deploy.bicep -p @parameters.json -l eastus2 -o table
az deployment sub create -n TestDev -f deploy.bicep -p @parameters.json -l eastus2 -w
az deployment sub create -n TestDev -f deploy.bicep -p @parameters.json -l eastus2
```

During deployment you will be prompted for the password for the administrator account.

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
