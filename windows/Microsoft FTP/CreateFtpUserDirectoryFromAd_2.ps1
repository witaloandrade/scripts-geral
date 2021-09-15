#
$FtpRootDir = "E:\Ftp_ComIsolation\LocalUsers"
$FtpPublicDir = "E:\Ftp_Public_Folder\"
#
$Users = Get-ADGroupMember -Identity 'Group Name' -Recursive | Where-Object {$_.objectClass -eq "user"} | Get-ADUser | Where-Object {$_.Enabled -eq "True"} | ForEach-Object {$_.SamAccountName}
$Users
	$Users | foreach {	
			Try {
				New-Item "$FtpRootDir\$_" -Type Directory -EA:"Stop" | Out-Null
				Write-Host -Fore Green "$_'s folder successfully created."
				}
			catch
				{ 
				Write-Host -fore Cyan "$_"
				}
			}


	$Users | foreach {	
			Try {
                C:\Windows\system32\inetsrv\appcmd.exe add vdir /app.name:"FTP-ISOLADO/" /path:/Mandic/$_/Public/ /physicalPath:$FtpPublicDir
				Write-Host -Fore Green "$_'s VDIR successfully created."
				}
			catch
				{ 
				Write-Host -fore Cyan "$_"
				}
			}