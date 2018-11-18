function SQL-UpdateLogins(){
 param(
 	  [Parameter(Mandatory=$true)]
 [string] $server=$(Throw "Server required.") ,
	  [Parameter(Mandatory=$true)]
 [string] $adminUserName =$(Throw "Username required."),
  [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
[Security.SecureString]$adminPassword=$(Throw "Password required."),
 [hashtable]$loginpasswordlist
 )

 clear-host

Write-Output '**********Start Execution of Add-SQLLogin********************'

	Write-Output '1.0 How many logins to update...?'
	$countLogins = $loginpasswordlist.Count
	if ($countLogins -gt 0) {$countLogins.ToString() + " logins and passwords to update"} else {'No logins to update'};


Write-Output '2.0 Set constants'
$database = "master"

Write-Output '3.0 Set Primary Connection'
$adminPassword.MakeReadOnly() 
$creds = New-Object System.Data.SqlClient.SqlCredential($adminUserName,$adminPassword) 
$connection = New-Object System.Data.SqlClient.SqlConnection 
$connection.ConnectionString = "Server=$server;Database=$database;" 
$connection.Credential = $creds

Write-Output '4.0 Get Failover Group Server Connections'
$partnerServer = (SQL-ReturnFailoverGroupPartners -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword)
$partnerServer =$partnerServer+".database.windows.net"

Write-Output '5.0 Start login password loop'
foreach($key in $loginpasswordlist.keys)
{

Write-Output '6.0 Get user name and password from list' 
$loginName = $key
$loginPassword = $loginpasswordlist[$key]

	Write-Output '7.0 Update Login on Primary' 
$sid =(SQL-UpdateLogin -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword -loginName $loginName -loginPassword $loginPassword)
	if($sid)
	{
			Write-Output '8.0 Update Login Failover Partner with Sid' 
$sid =(SQL-UpdateLogin -server $partnerServer  -adminUserName $adminUserName  -adminPassword $adminPassword -loginName $loginName -loginPassword $loginPassword -sid $sid)
		}
	}
Write-Output '**********End Execution of Add-SQLLogin********************'
}
	


##to test...
$server = "tcp:ss-dev01-demo-arm-paas-griff.database.windows.net,1433"
$adminUserName = "griffadmin"
$adminPassword = ConvertTo-SecureString "5up3r53cr3t!" -AsPlainText -Force
$loginpasswordlist = @{
    Test01Login   = '5up3r53cr3t!1'
    Test02Login   = '5up3r53cr3t!2'
    Test03Login   = '5up3r53cr3t!3'
}

SQL-UpdateLogins -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword  -loginpasswordlist $loginpasswordlist