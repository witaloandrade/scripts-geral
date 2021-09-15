<#
.SYNOPSIS
Script that will automate the process of creating FTP Server with user isolation(Domain users)
.DESCRIPTION
This script will setup microsoft windows ftp server with ftp user isolation for Domain users.
What this script will do:
1) Prompt for FTP server role and IIS management console installation if not already installed.
2) Create ftp group (default is "ftp_group") to give ftp permission to ftp site in the specified OU.
3) All domain users in the specified OU will be added to the newly created group in the same OU.
4) Create new FTP site, set SSL Mode, set user isolation mode, create virtual directory, enable basic authentication,
   and create authorization rule.
Note: All domain users who will access this ftp site need to be created first in the specified  OU.
Example usage:																					  
.\Setup_FTP_User_Isolation_AD.ps1 -OU "Sale Dept" -FtpRootDir D:\FtpRoot -FtpGroup "sale users"
-FtpSiteName ftp.contoso.com -Port 21 -RequireSSL -ExcludeUsers "Sales Admin","Jenny"
Author: phyoepaing3.142@gmail.com
Country: Myanmar(Burma)
Released: 09/09/2016
.EXAMPLE
.\Setup_FTP_User_Isolation_AD.ps1
It will prompt for OU and FTP Site Name and setup with default parameters. See Get-Help .\Setup_FTP_User_Isolation_AD.ps1 -PARAMETER <parameter> for each parameter usage.
.EXAMPLE
.\Setup_FTP_User_Isolation_AD.ps1 -OU "Sale Dept" -FtpRootDir D:\FtpRoot -FtpGroup "sale users" -FtpSiteName ftp.contoso.com -Port 21 -RequireSSL -ExcludeUsers "Sale Admin","Jenny"
It will create group "sale users" and add all users (except "Sale Admin" and "Jenny") to that group.
Then, it will create ftp site "ftp.contoso.com" with service port "21".
Note: If you include "RequireSSL", you need a valid certificate to use in your ftp site.
.PARAMETER OU
Specify the Organizational Unit in which ftp users' group will be created. All users in this OU (Except users in
-ExcludeUsers parameter) will be added to that group.
.PARAMETER FtpRootDir
Specify the root directory in which user's ftp home folders are created. Default is c:\ftproot.
.PARAMETER FtpGroup
Specify the group name for ftp users. Default is "ftp_group".
.PARAMETER FtpSiteName
Specify the name of the ftp site.
.PARAMETER Port
Specify the network port of your ftp site.
.PARAMETER RequireSSL
If used, this parameter will set the FTP SSL Mode to "SSL Require". All users connection will be encrypted.
You need a valid SSL certificate (public certificate, self-signed certificate or from Microsoft CA) to use this.
.PARAMETER ExcludeUsers
Specify the users you want to exclude in specified OU(defined in -OU parameter) to be added to group. Also, these users will not have ftp folders and permissions to access ftp site.
.LINK
You can find this script and more at: https://www.sysadminplus.blogspot.com/
#>

param( [array]$ExcludeUsers,[string]$FtpRootDir='c:\ftproot',[parameter(Mandatory=$true)][string]$OU,[string]$FtpGroup='Ftp_Group',[parameter(Mandatory=$true)][string]$FtpSiteName,[int]$Port=21,[switch]$RequireSSL)
############# Data Lookup from the output of $SslControlModeString for user display ######################################
$SslMode = DATA { ConvertFrom-StringData -StringData @'
SslAllow = "Allow SSL Connection"
SslRequire = "Require SSL Connection"
'@}
		
############## Check the if FTP server role, IIS Management Console, RSAT AD DS Powershell, WAS Roles are installed #########
[string]$VirtualDirectoryName= (Get-WmiObject Win32_NTDomain).DomainName											## Find domain's NetBios Name
$RolesAlreadyInstalled = 0; 		## Initialy reset $RolesAlreadyInstalled Flag
If ($RolesAlreadyInstalled -eq 0 -AND (Get-WindowsFeature RSAT-AD-Powershell).Installed -eq $True -AND (Get-WindowsFeature Web-Ftp-Server).Installed -eq $True -AND (Get-WindowsFeature Web-Mgmt-Console).Installed -eq $True -AND (Get-WindowsFeature WAS-Process-Model).Installed -eq $True)
	{
	Write-Host -Fore Cyan "AD DS Powershell Module, FTP Service, IIS Console, Windows Process Activation Service are already installed."
	}
else
	{
	$InstallConfirm=Read-Host "`nTo install ftp with user isolation by powershell, you need to install AD DS Powershell Module, FTP Service, IIS Console, Windows Activation Service. Do you want to automatically install it now(y/n)?"
	If($InstallConfirm -match 'y')
		{
			Add-WindowsFeature RSAT-AD-Powershell,Web-Ftp-Server,Web-Mgmt-Console, WAS-Process-Model -WarningAction "SilentlyContinue" | Out-Null
			$RolesAlreadyInstalled=1;
		}
	else
		{ Write-Host -Fore Yellow "FTP Service and IIS Console are not installed. Now exits..."; Exit 0;}
	}

################# Continue the setup if the required roles are installed ###############################
If ((Get-WindowsFeature RSAT-AD-Powershell).Installed -eq $True -AND (Get-WindowsFeature Web-Ftp-Server).Installed -eq $True -AND (Get-WindowsFeature Web-Mgmt-Console).Installed -eq $True -AND (Get-WindowsFeature WAS-Process-Model).Installed -eq $True)
{	
	If ($RolesAlreadyInstalled -eq 1)
	{ Write-Host -Fore Green "AD DS Powershell Module, FTP Service, IIS Console, Windows Process Activation Service are successfully installed." }
	
	############### If $OU is not found, then exit the script ##############
	$OuInfo=Get-ADOrganizationalUnit -Filter {name -eq $OU}
	If ($OuInfo.Name -ne $OU)
		{ Write-Host -Fore Red "OU($OU) is not found."
		Exit; 		
		}
	############## Find all users in the specified OU and exclude unwanted users #######################
	$Users = (Get-aduser -Filter * -SearchBase $OuInfo.DistinguishedName).SamAccountName
	$Users = $Users | where { $ExcludeUsers -NotContains $_ }											
))
	############## Create Users' own directory to be jailed ;P #########################
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
	############### Create Group for ftp users to give permission at FTP Site #############
	Try { 
		New-ADGroup $FtpGroup -GroupScope Global -Path (Get-ADOrganizationalUnit -Filter {name -eq $OU}).DistinguishedName
		Write-Host -Fore Green "$FtpGroup is successfully created."
		}
	catch
		{
		Write-Host -Fore Cyan "Active Directory Group `(`"$FtpGroup`"`) already Exists"
		}

	############# If the users in the specified OU are not in $FtpGroup, then add them to the group #############
	$FtpGroupMember = (Get-AdGroupMember -Identity $FtpGroup).Name											## Fetch the user names in $FtpGroup group
	$Users | % { 
			If ( $FtpGroupMember -NotContains $_)
				{
				Add-AdGroupMember -Identity $FtpGroup -Member $_ 
				Write-Host -Fore Green "$_ is added to $FtpGroup."
				}
			else
				{
				Write-Host -Fore Cyan "$_ is already in the $FtpGroup."
				}
		}
	If ((Get-Module -Name WebAdministration).Name -ne "WebAdministration")										## Load the WebAdministration module if not already loaded
	{
	Import-Module WebAdministration
	Write-Host -fore Yellow "WebAdministration module successfully loaded."
	}

	################ Add New FTP Site with binding information##############
	Try	{
			$Result=New-Item "IIS:\Sites\$FtpSiteName" -bindings @{protocol="ftp";bindingInformation="`:$Port`:"} -physicalPath $FtpRootDir -EA:"Stop"	 ##Create New Ftp Site with binding information, -ErrorAction:"Stop" is used to fetch catch statement
			Write-Host -Fore Green "FTP Site `($FtpSiteName`) is successfully created."
			If ($Result.State -eq "Stopped")
				{
					Write-Host -Fore Red "FTP Service cannot be started. Please make sure there is no other service using Port:$Port"
				}
		}
	Catch {
		Write-Host -Fore Cyan "FTP Site `($FtpSiteName`) already exists. No further action is taken."
		}

	############### Get current FTP SSL Mode ##################
	$SslControlModeString = Get-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.security.ssl.controlChannelPolicy
	$SslDataModeString = Get-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.security.ssl.dataChannelPolicy

	################ The following condition will test if the current status of FTP SSL and the wanted SSL state(from $RequireSSL Flag) is matched or not. If not matched, it will change the SSL Mode ############
	If(($RequireSSL -AND (($SslControlModeString -eq "SslAllow") -Or ($SslDataModeString -eq "SslAllow"))) -OR ((!$RequireSSL) -AND (($SslControlModeString -eq "SslRequire") -Or ($SslDataModeString -eq "SslRequire"))))
		{
		Write-Host -Fore Yellow "Current FTP SSL Connection Mode for `"$FtpSiteName`" is $($SslMode[$SslControlModeString])"
		Try {
			Set-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.security.ssl.controlChannelPolicy -Value $(if($RequireSSL){ 1 } else {0})	## If $Require  flag is set, then change ftp control channel ssl connection to "Require SSL" Mode, else Allow SSL Mode
			Set-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.security.ssl.dataChannelPolicy -Value $(if($RequireSSL){ 1 } else {0})		## If $Require  flag is set, then change ftp data channel ssl connection to "Require SSL" Mode, else Allow SSL Mode
			Write-Host -Fore Green "FTP SSL Connection Mode for `"$FtpSiteName`" is successfully set to `"$(If($RequireSSL){"Require SSL Connection"}else{"Allow SSL Connection"})`""
			}	
		Catch {
			Write-Host -Fore Red "Cannot change FTP Connection to `"$(If($RequireSSL){"Require SSL Connection"}else{"Allow SSL Connection"})`""
			}
		}
	else
		{
		Write-Host -Fore Cyan "Current FTP SSL Connection Mode for `"$FtpSiteName`" is $($SslMode[$SslControlModeString]). No Need to change."
		}

	############## If the user isolation mode is not correct, then change FTP User Isolation Mode to 3 #########
	If ((Get-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.userIsolation.mode) -ne "IsolateAllDirectories")
		{
		Try {
			Set-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.userIsolation -Value 3
			Write-Host -Fore Green "User Isolation Mode is successfully changed to `"User name directory(Disable global virtual directories)`"."
			}
		Catch {
			Write-Host -Fore Red "Cannot change User Isolation Mode to `"User name directory(Disable global virtual directories)`"."
			}
		}
	else
		{
			Write-Host -Fore Cyan "User Isolation Mode is already in `"User Name Directory Isolation Mode`". No Need to change."
		}

	################ Add New Virtual Directory under the newly created site ################
	$VirtualDirectoryName=($VirtualDirectoryName -Join "").Trim()							## Get NetBios Domain Name to create Virtual Directory

	Try {
		New-Item "IIS:\Sites\$FtpSiteName\$VirtualDirectoryName" -physicalPath $FtpRootDir -type VirtualDirectory -EA:"Stop" | Out-Null	## Create New Virtual Directory with the try/catch statement
		Write-Host -Fore Green "Virtual Directory `($VirtualDirectoryName`) is successfully created under $FtpSiteName."
		}
	Catch {
		Write-Host -Fore Cyan "Virtual Directory `($VirtualDirectoryName`) already exists under $FtpSiteName. No further action is taken."
		}

	################ Enable Basic Authentication to our Site ########################
	Try {
		Set-ItemProperty "IIS:\Sites\$FtpSiteName" -Name ftpServer.security.authentication.basicAuthentication.enabled -value $true -EA:"Stop"
		}
	Catch {
		Write-Host -Fore Red "Cannot enable the Basic Authentication for $FtpSiteName."
		}

	################### Add Read,Write Permission to $FtpSiteName for $FtpGroup##################
	Try {
		Add-WebConfiguration -Filter /System.FtpServer/Security/Authorization -Value (@{AccessType="Allow"; roles="$FtpGroup"; Permissions="Read, Write"}) -PSPath IIS:\Sites -Location $FtpSiteName	
		Write-Host -Fore Green "`"$FtpGroup`" is given Read,Write Permission to $FtpSiteName successfully."
		}
	Catch [System.Runtime.InteropServices.COMException]
		{
		Write-Host -Fore Cyan "Read,Write permission for `"$FtpGroup`" to $FtpSiteName already has been set. No Need to change."
		}

	Try { 
		Restart-Service ftpsvc -ea "stop"
		Write-Host -Fore Green "FTP Service successfully restarted."
		}
	 catch { 
		Write-Host -Fore Red "Cannot restart ftp service. Please make sure service is not disabled or it has appropriate permission"
		}
 }
 else
 {
 Write-Host -Fore Red "The required services are not installed. Please check your permission and installation prerequisites."
 }
 