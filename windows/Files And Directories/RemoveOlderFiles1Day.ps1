﻿Get-ChildItem "E:\Ftp_Public_Folder"  -Recurse -File | Where CreationTime -lt  (Get-Date).AddDays(-1)  | Remove-Item -Force