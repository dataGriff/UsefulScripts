function SQL-UpdateLogin(){
 param(
 	  [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
 [string] $server=$(Throw "Server required.") ,
	  [Parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
 [string] $adminUserName =$(Throw "Admin Username required."),
  [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
[Security.SecureString]$adminPassword=$(Throw "Admin Password required."),
   [Parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
 [string] $loginName =$(Throw "Login name required."),
   [Parameter(Mandatory=$true)]
     [ValidateNotNullOrEmpty()]
 [string] $loginPassword =$(Throw "Login password required."),
 [string] $sid
 )

clear-host

##Write-Output '**********Start Execution of Add-SQLLogin********************'

##Write-Output '1.0 Set constants'
$database = "master"

##Write-Output '2.0 Set Connection'
$adminPassword.MakeReadOnly() 
$creds = New-Object System.Data.SqlClient.SqlCredential($adminUserName,$adminPassword) 
$connection = New-Object System.Data.SqlClient.SqlConnection 
$connection.ConnectionString = "Server=$server;Database=$database;" 
$connection.Credential = $creds

##Write-Output '8.0 Set Query'
####$query = [System.IO.File]::ReadAllText($queryPath)
if($sid) {$sid = ",sid = $sid;"} else {$sid = ""}
if($sid)
	{$sidAlter = "EXEC (''DROP LOGIN [''+@LoginName+'']; CREATE LOGIN [''+@LoginName+''] WITH PASSWORD=N''''+@Password+''''   " + $sid +   "'');"} 
	else {$sidAlter = "EXEC (''ALTER LOGIN [''+@LoginName+''] WITH PASSWORD=N''''+@Password+'''''');"}

	$query = "
DECLARE @sql NVARCHAR(MAX) = 'IF NOT EXISTS (SELECT * FROM sys.sql_logins WHERE name = @LoginName)
BEGIN
DECLARE @errormessage NVARCHAR(MAX)
BEGIN TRY
  EXEC (''CREATE LOGIN [''+@LoginName+''] WITH PASSWORD=N''''+@Password+''''   " + $sid +   "'');
	END TRY
	BEGIN CATCH
	 SET @errormessage =  ''Login [''+@LoginName+''] failed to create.''+ '' - '' +ERROR_MESSAGE();
	 RAISERROR(@errormessage,16,1);
	END CATCH
  END 
  ELSE
  BEGIN
  PRINT ''Login [''+@LoginName+''] already exists.'';
  PRINT ''Set Password of [''+@LoginName+''].'';
  BEGIN TRY

  "+$sidAlter+"
	END TRY
	BEGIN CATCH
	 SET @errormessage =  ''Login [''+@LoginName+''] failed to alter.''+ '' - '' +ERROR_MESSAGE();
	 RAISERROR(@errormessage,16,1);
	END CATCH
  END';

DECLARE @parmDefinition NVARCHAR(MAX) = '@LoginName NVARCHAR(128), @Password NVARCHAR(128)';

EXECUTE sp_executesql @sql, @ParmDefinition, @LoginName = @LoginName, @Password=@Password;  
	
DECLARE @hexbin VARBINARY(MAX);
SET @hexbin = (SELECT sid FROM sys.sql_logins WHERE name = @LoginName)
SELECT '0x' + cast('' as xml).value('xs:hexBinary(sql:variable(`"@hexbin`") )', 'varchar(max)') AS Sid;
"

##Write-Output '11.0 Set Command'
$command = New-Object -TypeName System.Data.SqlClient.SqlCommand($query, $connection)

##Write-Output '12.0 Create Parameter Objects'
$usernameparam = New-Object -TypeName System.Data.SqlClient.SqlParameter("@LoginName", $loginName )
$passwordparam = New-Object -TypeName System.Data.SqlClient.SqlParameter("@Password", $loginPassword)

##Write-Output '13.0 Add Parameters to Query'
$param = $command.Parameters.Add($usernameparam) 
$param = $command.Parameters.Add($passwordparam)

##Write-Output '14.0 Attach the InfoMessage Event Handler to the connection to write out the messages'
$handler = [System.Data.SqlClient.SqlInfoMessageEventHandler] {param($sender, $event) Write-Host $event.Message }; 
$connection.add_InfoMessage($handler); 
$connection.FireInfoMessageEventOnUserErrors = $true;

##Write-Output '15. Open Connection'
$connection.Open();
##Write-Output '16. Add login to primary'
$sid = $command.ExecuteScalar(); 
##Write-Output '17. Close Connection'
$connection.Close();

return $sid

##Write-Output '**********End Execution of Add-SQLLogin********************'
}

##to test...
$server = "tcp:ss-dev01-demo-arm-paas-griff.database.windows.net,1433"
$adminUserName = "griffadmin"
$adminPassword = ConvertTo-SecureString "5up3r53cr3t!" -AsPlainText -Force
$loginName = "Test01Login"
$loginPassword = '5up3r53cr3t!1'

$sid =(SQL-UpdateLogin -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword -loginName $loginName -loginPassword $loginPassword)
$server = "tcp:ss-dev02-demo-arm-paas-griff.database.windows.net,1433"
$sid =(SQL-UpdateLogin -server $server  -adminUserName $adminUserName  -adminPassword $adminPassword -loginName $loginName -loginPassword $loginPassword -sid $sid)