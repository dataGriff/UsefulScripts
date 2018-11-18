$resourceGroupName = "datagriff-rg"
$location = "north europe"
$storageAccountName = "datagriffsa123456"
$containerName = "mycontainer"
$storagePolicyName = “readpolicy”
$expiryTime = (Get-Date).AddDays(7)
$permission = "r" ##r,w,l,d
$requestsSaS = true

<#
function Update-StorageAccountSharedAccessPolicyWithSignature{
    param(
     [string]   $resourceGroupName ,
     [string]   $location ,
     [string]   $storageAccountName ,
     [string]   $container ,
     [string]   $storagePolicyName ,
     [datetime] $expiryTime ,
     [string]   $permission 
    )
    #>
   
    clear-host

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

$storageAccountExists = Get-AzureRmResource -ResourceType "Microsoft.Storage/storageAccounts" -ResourceName $storageAccountName -ResourceGroupName $resourceGroupName

if  ( !$storageAccountExists ) {
Write-Output $storageAccountName " storage account does not exist so creating..."
    New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName Standard_LRS -Kind StorageV2
}
else
{
Write-Output $storageAccountName " storage account already exists."
}



## 3.0 Create Container
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
$storageContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

$containerExists = Get-AzureStorageContainer -Context $storageContext -ErrorAction Stop | where-object {$_.Name -eq $containerName} 

if  ( !$containerExists ) {
Write-Output $containerName " container does not exist so creating..."
$storageContainer = New-AzureStorageContainer -Name $containerName -Context $storageContext
}else
{
Write-Output $containerName " container already exists."
}




## 4.0 Create or Update Shared Access Policy

$policyExists = Get-AzureStorageContainerStoredAccessPolicy -Container $containerName -Policy $storagePolicyName -Context $storageContext

if  ( !$policyExists ) {
Write-Output $storagePolicyName " policy does not exist so creating..."
New-AzureStorageContainerStoredAccessPolicy -Container $containerName -Policy $storagePolicyName -Permission $permission -ExpiryTime $expiryTime -Context $storageContext
}
else
{
Write-Output $storagePolicyName " policy does exist so updating..."
Set-AzureStorageContainerStoredAccessPolicy -Container $containerName -Policy $storagePolicyName -Permission $permission -ExpiryTime $expiryTime -Context $storageContext
}

## 5.0 Create Shared Access Signature from Policy and Return

If($requestsSaS)
{
Write-Output "Returning SaS..."
$sasToken = (New-AzureStorageContainerSASToken -Name $containerName -Policy $storagePolicyName -Context $storageContext).substring(1)
}
else
{
Write-Output "No SaS requested so none returned."
}

#>

<#
Update-StorageAccountSharedAccessPolicyWithSignature -resourceGroupName  $resourceGroupName `
-location $location `
-storageaccountname $storageaccountname `
-container $container `
-storagePolicyName $storagePolicyName ` 
-expiryTime $expiryTime `
-permission $permission 
#>