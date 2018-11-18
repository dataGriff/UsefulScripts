function SQL-ReturnFailoverGroupPartners(){
 param(
	  [Parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
 [string] $server=$(Throw "Server required.") ,
	  [Parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
 [string] $adminUserName =$(Throw "Username required."),
  [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
[Security.SecureString]$adminPassword=$(Throw "Password required.")
 )

	Clear-Host

 ##Write-Output '**********Start Execution of Check-SQLIsFailoverGroup********************'

##Write-Output '1.0 Set constants'
$database = "master"

$adminPassword.MakeReadOnly() 
$creds = New-Object System.Data.SqlClient.SqlCredential($adminUserName,$adminPassword) 
$connection = New-Object System.Data.SqlClient.SqlConnection 
$connection.ConnectionString = "Server=$server;Database=$database;" 
$connection.Credential = $creds

$query = "	
SELECT   
   DISTINCT partner_server 
FROM sys.geo_replication_links
WHERE role_desc = 'primary'
	"
## Write-Output '4.0 Create Failover Group Check Command'
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)
 ##Write-Output '5.0 Open Connection Failover Group Check'
$connection.Open();
## Write-Output '6.0 Execute Query Failover Group Check'
$partner_server = $command.ExecuteScalar(); 
## Write-Output '7.0 Close Connection Failover Group Check'
$connection.Close();
##Write-Output '8.0 Create Secondary Server Connection if has Failover Group'
	if ($partner_server)
{
return [string]$partner_server
}
	Clear-Host

##Write-Output '**********End Execution of Check-SQLIsFailoverGroup********************'
}

##to test...
$server = "tcp:ss-dev01-demo-arm-paas-griff.database.windows.net,1433"
$adminUserName = "griffadmin"
$adminPassword = ConvertTo-SecureString "5up3r53cr3t!" -AsPlainText -Force

SQL-ReturnFailoverGroupPartners -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword 