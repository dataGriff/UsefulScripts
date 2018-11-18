 ##https://ask.sqlservercentral.com/questions/121106/using-powershell-credentials-to-connect-to-sql-ser.html
 
 function SQL-SecureReaderExample(){
 param(
 [string] $server ,
	  [string] $username ,
   [Parameter(Mandatory=$true)]
   [ValidateNotNullOrEmpty()]
[Security.SecureString]$password=$(Throw "Password required.")
 )

 clear-host

$pwd.MakeReadOnly() 
$creds = New-Object System.Data.SqlClient.SqlCredential($uid,$pwd) 
$con = New-Object System.Data.SqlClient.SqlConnection 
$con.ConnectionString = "Server=ss-dev01-demo-arm-paas-griff.database.windows.net;Database=master;" 
$con.Credential = $creds 
$sql = "SELECT @@SERVERNAME AS ServerName" 
$cmd = New-Object System.Data.SqlClient.SqlCommand($sql,$con) 
$con.Open() 
$rdr = $cmd.ExecuteReader() 
while($rdr.Read()) 
{ $rdr["ServerName"].ToString() } 
$con.Close()
	 }

$server = "ss-dev01-demo-arm-paas-griff.database.windows.net"
$adminName = "griffadmin"
$adminPassword = ConvertTo-SecureString "5up3r53cr3t!" -AsPlainText -Force

SQL-SecureReaderExample -server $server  -adminName $adminName  -adminPassword $adminPassword 