Add-Type -assembly System.Windows.Forms
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='RDS Ninja Administration'
$main_form.Width = 600
$main_form.Height = 400
$main_form.AutoSize = $true



$main_form.ShowDialog()
