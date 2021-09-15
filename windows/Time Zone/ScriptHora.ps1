# Definindo variaveis para download
$horareg     = 'http://tools.AnyIisSite.net/hora/HV_2018.reg'
#$horaxml     = 'http://tools.AnyIisSite.net/hora/HorarioVerao.xml'
$horaps1     = 'http://tools.AnyIisSite.net/hora/hv.ps1'

# Definindo variaveis pastas
$tmpdir        =  "C:\temp\hv"


# Criar diretório para Download
#Write-Host "# ============================================ #" 
#Write-Host "# Criar diretório para Download                #"
#Write-Host "# ============================================ #"   
New-Item $tmpdir -ItemType Directory


#  Baixar .reg 
#Write-Host "# ============================================ #" 
#Write-Host "# Baixar Reg                                   #"  
#Write-Host "# ============================================ #" 
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($horareg,'C:\temp\hv\HV_2018.reg')

#  Baixar xml 
#Write-Host "# ============================================ #" 
#Write-Host "# Baixar XML                                   #"  
#Write-Host "# ============================================ #" 
#$wc = New-Object System.Net.WebClient
#$wc.DownloadFile($horaxml,'C:\temp\hv\HorarioVerao.xml')


#  Baixar .ps1 
#Write-Host "# ============================================ #" 
#Write-Host "# Baixar PS1                                   #"  
#Write-Host "# ============================================ #" 
$wc = New-Object System.Net.WebClient
$wc.DownloadFile($horaps1,'C:\temp\hv\hv.ps1')
C:\temp\hv\hv.ps1




#Write-Host "# ============================================ #" 
#Write-Host "# Detelar Tarefa Windows 2012 / 2016           #"  
#Write-Host "# ============================================ #" 
#Unregister-ScheduledTask -TaskName HorarioVerao-2018 -confirm:$false



#Write-Host "# ============================================ #" 
#Write-Host "# Iniciar tarefa                               #"  
#Write-Host "# ============================================ #" 
#Start-ScheduledTask -TaskName "HorarioVerao-2018"

#Write-Host "# ============================================ #" 
#Write-Host "# Favor Validar Execução e finalizar           #"
#Write-Host "# ============================================ #" 
#Read-Host "Pressione ENTER"
