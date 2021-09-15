<#
.SYNOPSIS
  Script para Administração de Ambientes VDI.

.DESCRIPTION
  Consulta, Cria, Deleta Host, Collections  e Usuários em um ambiente RDS.


.NOTES
  Version:        1.0
  Author:         Raimundo Witalo Andrade
  Creation Date:  07/09/2019
  Purpose/Change: Administração Básica de usuários e Session Hosts.
  
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

#-----------------------------------------------------------[Functions]------------------------------------------------------------

Function Banner{
Write-Host
Write-Host "-------------------------------------------------------" -Foregroundcolor Yellow
Write-Host "     Script para Administração Ambientes VDI           " -ForegroundColor Green
Write-Host "-------------------------------------------------------" -Foregroundcolor Yellow
Write-Host
}

Function Opcoes{
#Clear
Write-Host "Selecione umas das opções abaixo: " -ForegroundColor Yellow
Write-Host " 1 - Consulta Broker Master" -ForegroundColor Green
Write-Host " 2 - Lista Collections" -ForegroundColor Green
Write-Host " 3 - Lista Sessões de Usuários Ativos" -ForegroundColor Green
Write-Host " 4 - Consulta Vinculo de Usuário/Session Host" -ForegroundColor Green
Write-Host " 5 - Forçar LogOff de Sessões" -ForegroundColor Green
Write-Host " 6 - Adicionar um novo Servidor como Session Host" -ForegroundColor Green
Write-Host " 7 - Adicionar o Session Host na Collection" -ForegroundColor Green
Write-Host " 8 - Adiconar Vinculo de Usuário/Session Host" -ForegroundColor Green
Write-Host " 9 - Deleta Vinculo de Usuário/Session Host" -ForegroundColor Green
Write-Host "10 - Remover um Session Host do Connection Broker " -ForegroundColor Green
}

Function Trabalhando {
Write-Host
Write-Host "Executando Comandos...Favor Aguade..." -ForegroundColor Green
Start-sleep -Seconds 3
}

#F1
Function Cons_MasterBroker {
Trabalhando
$ConnectionBrokerFQDN = (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer
if (!$?) {
	Write-Host "Executado com Erro" -ForegroundColor Red
}
else {
    Write-Host "O Broker Master Atual é o $ConnectionBrokerFQDN" -ForegroundColor Yellow
}
} 

#F2
Function Cons_Colection {
Trabalhando
$Collections = Get-RDSessionCollection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer | Select CollectionName
if (!$?) {
	Write-Host "Executado com Erro" -ForegroundColor Red
}
else {
    Write-Host "Collections disponíveis: `n" -ForegroundColor Yellow
    $Collections | Out-String
}
} 

#F3
Function Ver_Sesoes{
Trabalhando
$VS=Get-RDUserSession -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe |  Select ServerName,UserName,SessionId,ServerIPAddress
if (!$?) {
	Write-Host " Sem Conexões Ativas !" -ForegroundColor Red
}
else {
    Write-Host "Conexões Ativas: `n" -ForegroundColor Yellow
    $VS | Out-String
}
} 
  
#F4
Function Cons_Vinculo {
Cons_Colection
Write-Host "Digite o nome da Collection Para Consulta:" -ForegroundColor Yellow
$Collection = Read-Host
$Vinculo = Get-RDPersonalSessionDesktopAssignment  -ConnectionBroker  (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe -CollectionName $Collection | FT
if (!$?) {
	Write-Host "Executado com Erro" -ForegroundColor Red
}
else {
    Write-Host "Vinculo de Usuário/Session Host: `n" -ForegroundColor Yellow
    $Vinculo | Out-String
}
}

#F5
Function Usr_LogOut {
Trabalhando
$VS=Get-RDUserSession -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe |  Select ServerName,UserName,SessionId,ServerIPAddress
if(!$vs ) {
	       Write-Host " Sem Conexões Ativas !" -ForegroundColor Red
           }
            else
            {
            Write-Host "Conexões Ativas:" -ForegroundColor Green
            $VS | Out-String 
            Write-Host "Digite o nome do Host Para LogOff:" -ForegroundColor Yellow
            $HostLogOut = Read-Host
            Write-Host "Digite o ID da Sessão Para LogOff:" -ForegroundColor Yellow
            $SessLogOut = Read-Host
            Write-Host "Executando Comandos..." -ForegroundColor Green
            Invoke-RDUserLogoff -HostServer $HostLogOut -UnifiedSessionID  $SessLogOut -Force
            }
}

#F6
Function Add_SessionHost {
Trabalhando
Write-Host "Digite o nome do RDS-RD-Server para Adiconar no RDS:" -ForegroundColor Yellow
$HostToAdd = Read-Host
Write-Host "Executando Comandos..." -ForegroundColor Green
Add-RDServer -Server $HostToAdd -Role "RDS-RD-Server" -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe
if (!$?) {
	Write-Host "Executado com Erro" -ForegroundColor Red
}
else {
    Write-Host "Executado com Sucesso" -ForegroundColor Yellow
}
}

#F7
Function Add_ToCollection {
Trabalhando
Write-Host "Consultando Collections Disponíveis..." -ForegroundColor Green
Cons_Colection
Write-Host "Digite o nome na Collection:" -ForegroundColor Yellow
$Collection = Read-Host
Write-Host "Digite o nome do Host Para Adicionar na Collection:" -ForegroundColor Yellow
$HostToAdd = Read-Host
Write-Host "Executando Comandos..." -ForegroundColor Green
Add-RDSessionHost -SessionHost $HostToAdd -CollectionName $Collection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe
if (!$?) {
	Write-Host "Executado com Erro" -ForegroundColor Red
}
else {
    Write-Host "Executado com Sucesso" -ForegroundColor Yellow
}
}

#F8
Function Add_Vinculo {
Trabalhando
Write-Host "Consultando Collections Disponíveis..." -ForegroundColor Green
Get-RDSessionCollection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer
Write-Host "Digite o nome da Collection Para Adicionar o Vinculo:" -ForegroundColor Yellow
$Collection = Read-Host
Write-Host "Digite o nome do Host Para Adicionar na Collection:" -ForegroundColor Yellow
$HostToAdd = Read-Host
Write-Host "Digite o nome do Usuário Para Vincular com o VDI Ex: Dominio\usuário:" -ForegroundColor Yellow
$UsrToAdd = Read-Host
Set-RDPersonalSessionDesktopAssignment -CollectionName $Collection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe -User $UsrToAdd -Name $HostToAdd
}

#F9
Function Del_Vinculo {
Trabalhando
Write-Host "Consultando Collections Disponíveis..." -ForegroundColor Green
Get-RDSessionCollection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer
Write-Host "Digite o nome da Collection Para Remover o Vinculo:" -ForegroundColor Yellow
$Collection = Read-Host
Write-Host "Consultando Usuários Disponíveis..." -ForegroundColor Green
Get-RDPersonalSessionDesktopAssignment  -ConnectionBroker  (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe -CollectionName $Collection | FT
Write-Host "Digite o nome do usário para: Deletar Vinculo e Usuário/Session Host:" -ForegroundColor Yellow
$UsrToDel = Read-Host
Write-Host "Executando Comandos..." -ForegroundColor Green
#Write-Host "$env:USERDNSDOMAIN\$UsrToDel"
Remove-RDPersonalSessionDesktopAssignment -collectionname $Collection -user $UsrToDel -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe
}

#F10
Function Del_SessionHost {
Trabalhando
Write-Host "Digite o nome do Host Para Remover Do RDS:" -ForegroundColor Red
$HostToDel = Read-Host
Remove-RDSessionHost -SessionHost $HostToDel  -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe
# Não da para testar pois só tenho  apenas 1 host
#Remove-RDServer -Server $HostToDel -Role "RDS-RD-SERVER" -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe
# Pendente deletar dos grupos e do AD
} 

#-----------------------------------------------------------[Functions]------------------------------------------------------------

#-----------------------------------------------------------[Executios]------------------------------------------------------------
Banner
Opcoes
Do {
$UserInput = Read-Host
Banner
Write-Host "Opção Inválida! Digite novamente: " -ForegroundColor Yellow
Opcoes
} While (('1','2','3','4','5','6','7','8','9','10') -notcontains $UserInput)
Write-Host
switch ($UserInput)
    {
        1  {}
        2  {}
        3  {}
        4  {}
        5  {}
        6  {}
        7  {}
        8  {}
        9  {}
        10 {}

    }

if($UserInput -eq "1"){
Clear
#Write-Host "Trabalhando, Favor Aguade..." -ForegroundColor Green -NoNewLine
Cons_MasterBroker}
if($UserInput -eq "2"){
Clear
Cons_Colection}
if($UserInput -eq "3"){
Clear
Ver_Sesoes}
if($UserInput -eq "4"){
Clear
Cons_Vinculo}
if($UserInput -eq "5"){
Clear
Usr_LogOut}
if($UserInput -eq "6"){
Clear
Add_SessionHost}
if($UserInput -eq "7"){
Clear
Add_ToCollection}
if($UserInput -eq "8"){
Clear
Add_Vinculo}
if($UserInput -eq "9"){
Clear
Del_Vinculo}
if($UserInput -eq "10"){
Clear
Del_SessionHost}

#-----------------------------------------------------------[Executios]------------------------------------------------------------
