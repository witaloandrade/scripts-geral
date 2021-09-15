# Get all server names from the saved txt file
$servers = $env:COMPUTERNAME;

$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName $servers | Measure-Object -Property capacity -sum | % {[math]::round(($_.sum / 1GB),2)} 
$CPUCount = Get-WmiObject –class Win32_processor | Measure-Object -Property NumberOfLogicalProcessors -sum | % {[math]::round(($_.sum),1)}  

# Loop through each server 
foreach ($server in $servers) {
 
    $out = $null;
 
    # Check if computer is online
    if (test-connection -computername $server -count 1 -ea 0) {
 
        try {
            # Define SQL instance registry keys
            $type = [Microsoft.Win32.RegistryHive]::LocalMachine;
            $regconnection = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey($type, $server) ;
            $instancekey = "Software\\Microsoft\\Microsoft SQL Server\\Instance Names\\SQL";

            try {
                # Open SQL instance registry key
                $openinstancekey = $regconnection.opensubkey($instancekey);

            }
            catch { $out = $server + ",No SQL registry keys found"; }
 
            # Get installed SQL instance names
            $instances = $openinstancekey.getvaluenames();

            # Loop through each instance found
            foreach ($instance in $instances) {

                # Define SQL setup registry keys
                $instancename = $openinstancekey.getvalue($instance);
                $instancedisplayname = $openinstancekey.getvalue($instance);
               
                $instancesetupkey = "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\Setup"; 
 
                # Open SQL setup registry key
                $openinstancesetupkey = $regconnection.opensubkey($instancesetupkey);

                $edition = $openinstancesetupkey.getvalue("Edition")

                # Get version and convert to readable text
                $version = $openinstancesetupkey.getvalue("Version");


                switch -wildcard ($version) {
                    "14*"   {$versionname = "SQL Server 2017";}
                    "13*"   {$versionname = "SQL Server 2016";}
                    "12*"   {$versionname = "SQL Server 2014";}
                    "11*"   {$versionname = "SQL Server 2012";}
                    "10.5*" {$versionname = "SQL Server 2008 R2";}
                    "10.4*" {$versionname = "SQL Server 2008";}
                    "10.3*" {$versionname = "SQL Server 2008";}
                    "10.2*" {$versionname = "SQL Server 2008";}
                    "10.1*" {$versionname = "SQL Server 2008";}
                    "10.0*" {$versionname = "SQL Server 2008";}
                    "9*"    {$versionname = "SQL Server 2005";}
                    "8*"    {$versionname = "SQL Server 2000";}
                    default {$versionname = $version;}
                }
 
                # Output results to CSV
                $out =  "Servidor: "+$server  + "`n" + "Versão: " + $versionname +  "`n" + "Instancia: " + $instancename +  "`n"  + "Edicao: " + $edition ; 
                write-host $out 
                
                try
                {
                $cluster = $regconnection.opensubkey( "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\Cluster");
                $clustername.getvalue("ClusterName");     
                
                if (-not ([string]::IsNullOrEmpty($clustername)))
                        {
                            write-host "Cluster: " + $clustername
                        }

                }
                catch
                {
                    write-host "Cluster: não configurado"
                }

                try
                {
                    $HADR = $regconnection.opensubkey( "SOFTWARE\Microsoft\Microsoft SQL Server\" + $instancename + "\MSSQLSERVER\HADR")
                    $HADRFlag = $HADR.getvalue("HADR_Enabled")
                    
                    if ($HADRFlag -eq 1)
                        { write-host "HADR: AlwaysON" }
                    else
                        { write-host "HADR:Não configurado" }
                }
                catch
                { write-host "HADR:Não configurado" }

                write-host "Numero de cpus: " $CPUCount
                write-host "Memoria instalada: " $PhysicalMemory  "GB"  "`n"

            }
 
        }
        catch { $out = $server + ",Não foi possível abrir o registro"; }       
 
    }
    else {

    $out = $server + "offline"
    }
 
    
}

pause
 