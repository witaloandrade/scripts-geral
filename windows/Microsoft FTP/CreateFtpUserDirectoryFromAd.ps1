$FtpRootDir = "E:\Ftp_ComIsolation\LocalUsers"

$Users = Get-ADGroupMember 'Group Name' | Where-Object {$_.objectClass -eq "user"} | Get-ADUser | Where-Object {$_.Enabled -eq "True"} | ForEach-Object {$_.SamAccountName}

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