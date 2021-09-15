<#.NOTES   
    Author:  Raimundo Andrade
    Date: 09/25/2019
#> 

Set-ExecutionPolicy Bypass -Scope Process
$polices="https://github.com/witaloandrade/WS2012-2016-Sec-Baseline/raw/master/Files/GPO.zip"
$lgpo="https://github.com/witaloandrade/WS2012-2016-Sec-Baseline/raw/master/Files/LGPO.exe"
$tmpdir="c:\temp\pol"
$bkpdir="c:\temp\pol\bkp"
#Create Temp Dir
If(!(test-path $tmpdir)) 
{New-Item -ItemType Directory -Force -Path $tmpdir | Out-Null ; Write-Host -ForegroundColor Green "Criado diretorio temporário" } 
else {
Write-Host -ForegroundColor Cyan "Diretorio temporário já existe"  
}
#Create backup Dir
If(!(test-path $bkpdir)) 
{New-Item -ItemType Directory -Force -Path $bkpdir | Out-Null ; Write-Host -ForegroundColor Green "Criado diretorio backup" } 
else {
Write-Host -ForegroundColor Cyan "Diretorio backup já existe"  
}

# Baixar Arquivos 
Write-Host -ForegroundColor Green " Baixar Arquivos "
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri "$polices" -OutFile "$tmpdir\GPO.zip"
Invoke-WebRequest -Uri "$lgpo" -OutFile "$tmpdir\LGPO.exe"

# Descompactar Arquivos 
Write-Host -ForegroundColor Green " Descompactar Arquivos "
Add-Type -Assembly "System.IO.Compression.Filesystem"
[io.compression.zipfile]::ExtractToDirectory("$tmpdir\gpo.zip", "$tmpdir")


Set-Location $tmpdir
# Backup Local Existing Polices 
Write-Host -ForegroundColor Green " Backup de Politicas Locais"
C:\Windows\System32\cmd.exe /C LGPO.exe /b "$bkpdir"

# Apply Polices 
Write-Host -ForegroundColor Green " Aplicando Politicas "
C:\Windows\System32\cmd.exe /C LGPO.exe /g GPO /v > apply.txt