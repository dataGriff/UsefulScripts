$resourceGroupName = "datagriff-rg"
$location = "north europe"
$storageaccountname = "datagriffsa123456"
$container = "mycontainer"
$storagePolicyName = “readpolicy”
$expiryTime = (Get-Date).AddDays(7)
$permission = "r" ##r,w,l,d

Connect-AzureRmAccount

## 1.0 Create Resource Group

Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location 
}
else
{
    Write-Output $resourceGroupName " resource group already exists."
}

## 2.0 Create Storage Account
$StorageObject = Get-AzureRmResource -ResourceType "Microsoft.Storage/storageAccounts" -ResourceName $storageaccountname -ResourceGroupName $resourceGroupName
if  ( !$StorageObject ) {
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageaccountname -Location $location -SkuName Standard_LRS -Kind StorageV2
}
else
{
Write-Output $storageaccountname " storage account already exists."
}

<#
## 2.0 Create Container

$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$storageContainer = New-AzureStorageContainer -Name rawsamples -Context $storageContext


## 3.0 Create Shared Access Policy

$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
New-AzureStorageContainerStoredAccessPolicy -Container $container -Policy $storagePolicyName -Permission $permission -ExpiryTime $expiryTime -Context $storageContext

## 4.0 Create Shared Access Signature from Policy and Return

$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey
$sasToken = (New-AzureStorageContainerSASToken -Name rawsamples -Policy $storagePolicyName -Context $storageContext).substring(1)

#>