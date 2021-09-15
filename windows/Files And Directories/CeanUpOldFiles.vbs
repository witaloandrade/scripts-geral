Dim fso, f, f1, fc
Set fso = CreateObject("Scripting.FileSystemObject")
Set f = fso.GetFolder("D:\Parallels\Plesk\Databases\MSSQL\MSSQL11.MSSQLSERVER2012\MSSQL\Backup\")
Set fc = f.Files

For Each f1 in fc
	If DateDiff("d", f1.DateLastModified, Now) > 90 Then
		f1.Delete True
	End If
Next