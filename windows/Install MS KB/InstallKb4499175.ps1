<#.NOTES   
    Author:  Raimundo Andrade
    Date: 06/28/2019
#> 

Set-ExecutionPolicy Bypass -Scope Process
$kb="http://download.windowsupdate.com/d/msdownload/update/software/secu/2019/05/windows6.1-kb4499175-x64_3704acfff45ddf163d8049683d5a3b75e49b58cb.msu"
$filepath="c:\kb\windows6.1-kb4499175-x64_3704acfff45ddf163d8049683d5a3b75e49b58cb.msu"
$tmpdir="c:\kb"
#Temp Dir
If(!(test-path $tmpdir)) 
{New-Item -ItemType Directory -Force -Path $tmpdir | Out-Null ; Write-Host -ForegroundColor Green "Criado diretorio temporário" } 
else {
Write-Host -ForegroundColor Cyan "Diretorio temporário já existe"  
}
# Baixar Arquivo de configuração zabbix 
Write-Host -ForegroundColor Green " Baixando KB "
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($kb,$filepath)
Write-Host -ForegroundColor Green "# Executando Instalação #"
wusa "c:\kb\windows6.1-kb4499175-x64_3704acfff45ddf163d8049683d5a3b75e49b58cb.msu"
