Stop-Service -name spooler
Remove-Item "C:\Windows\System32\spool\PRINTERS\*" -Force -Recurse
Start-Service -name spooler
