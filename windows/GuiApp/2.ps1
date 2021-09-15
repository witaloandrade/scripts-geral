Add-Type -AssemblyName System.Windows.Forms

$Form = New-Object system.Windows.Forms.Form

$Form.Text = "Sample Form"

 

$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")

$Form.Icon = $Icon

 

$Image = [system.drawing.image]::FromFile("$($Env:Public)\Pictures\Sample Pictures\Oryx Antelope.jpg")

$Form.BackgroundImage = $Image

$Form.BackgroundImageLayout = "None"

    # None, Tile, Center, Stretch, Zoom

$Form.Width = $Image.Width

$Form.Height = $Image.Height

$Font = New-Object System.Drawing.Font("Times New Roman",24,[System.Drawing.FontStyle]::Italic)

    # Font styles are: Regular, Bold, Italic, Underline, Strikeout

$Form.Font = $Font

$Label = New-Object System.Windows.Forms.Label

$Label.Text = "This form is very simple."

$Label.BackColor = "Transparent"

$Label.AutoSize = $True

$Form.Controls.Add($Label)

$Form.ShowDialog() 