#INICIO
#(Get-Content .\sites.txt) | ForEach {Write-Host $_, "-", ([System.Net.NetworkInformation.Ping]::new().Send($_)).Status}
#(Get-Content .\sites.txt) | ForEach-Object {Write-Host $_}
(Get-Content .\sites.txt) | ForEach-Object {Resolve-DnsName $_ -NoRecursion } 2> null | Out-File sites2.txt


