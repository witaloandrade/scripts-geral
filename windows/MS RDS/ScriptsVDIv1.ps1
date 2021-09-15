#Script para Administração Ambientes VDI
#Script por Raimundo Andrade
#Versão 1.0 - Administração de VDI

function Banner{
Write-Host
Write-Host "-------------------------------------------------------" -Foregroundcolor Yellow
Write-Host "     Script para Administração Ambientes VDI           " -ForegroundColor Green
Write-Host "-------------------------------------------------------" -Foregroundcolor Yellow
Write-Host
}
function Opcoes{
Write-Host "Selecione umas das opções abaixo: " -ForegroundColor Yellow
Write-Host "1 - Consulta Broker Master" -ForegroundColor Green
Write-Host "2 - Lista Collections" -ForegroundColor Green
Write-Host "3 - Lista Sessões de Usuários Ativos" -ForegroundColor Green
Write-Host "4 - Consulta Vinculo e Usuário/Host" -ForegroundColor Green
#Write-Host "5 - Listar salas de um cliente/master" -ForegroundColor Green
}

Function Cons_MasterBroker {
$ConnectionBrokerFQDN = (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer
Write-Host
Write-Host "O Broker Master Atual é o $ConnectionBrokerFQDN"
}

Function Cons_Colection {
Get-RDSessionCollection -ConnectionBroker (Get-RDConnectionBrokerHighAvailability).ActiveManagementServer
}

Function Ver_Sesoes{
 Get-RDUserSession -CollectionName (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe |  Select ServerName,UserName,SessionId,ServerIPAddress
}

Function Cons_Vinculo {
Write-Host "Consultando Collections Disponíveis..." -ForegroundColor Green
Cons_Colection
Write-Host
Write-Host "Digite o nome da Collection Para Consulta" -ForegroundColor Yellow
$Collection = Read-Host
Get-RDPersonalSessionDesktopAssignment  -ConnectionBroker  (Get-RDConnectionBrokerHighAvailability).ActiveManagementServe -CollectionName $Collection | FT
}
Banner
Opcoes
Do {
$UserInput = Read-Host
Banner
Write-Host "Opção Inválida! Digite novamente: " -ForegroundColor Yellow
Opcoes
} While (('1','2','3','4','5') -notcontains $UserInput)
Write-Host
switch ($UserInput)
    {
        1 {}
        2 {}
        3 {}
        4 {}
        5 {}
    }

if($UserInput -eq "1"){
Clear
Write-Host "Trabalhando, Favor Aguade..." -ForegroundColor Green -NoNewLine
Cons_MasterBroker}
if($UserInput -eq "2"){
Clear
Write-Host "Trabalhando, Favor Aguade..." -ForegroundColor Green -NoNewLine
Cons_Colection}
if($UserInput -eq "3"){
Clear
Write-Host "Trabalhando, Favor Aguade..." -ForegroundColor Green -NoNewLine
Ver_Sesoes}
if($UserInput -eq "4"){
Clear
Write-Host "Trabalhando, Favor Aguade..." -ForegroundColor Green
Cons_Vinculo}