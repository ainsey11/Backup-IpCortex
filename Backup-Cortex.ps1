#----------------------------------------------------------------------------- 
# Script: BackupCortex.ps1
# Author: Ainsey11 (https://ainsey11.com) 
# Date: 01/21/2016 23:38:14  
# ----------------------------------------------------------------------------- 

Function Backup-Cortex{
    param (
            [string] $CortexAddress, 
            [string] $username,
            [string] $password
           )
     #static variables, not much need to tweak these
            $date = Get-Date -Format dd-MM-yy
            $EVLogSource = "Ainsey11-BackupCortex"
            $LoginEVID = "1000"
            $BackupEVID = "1001"
            $EVMessage = "Cortex Backup has been initiated, logging in"
            $EVMessageCompleted = "Cortex Backup has been initiated, logging in"
            $BackupLocation = "C:\Backups"
            $tempfile = "$BackupLocation\tmp.txt"
            $CortexLoginURL = "http://$CortexAddress/login.whtm?sessionUser=$username&sessionPass=$password"
            $CortexDownloadURL = "http://$CortexAddress/admin/backup.whtm/update/backup.tar.gz"
            $Wgetlocation = "C:\Program Files (x86)\GnuWin32\bin"
            New-EventLog -LogName Application -Source $EVLogSource -ErrorAction SilentlyContinue

            cd $Wgetlocation
            .\wget.exe -O $tempfile --max-redirect=0 --save-cookies=./cookies.txt --keep-session-cookies --tries=1 $CortexLoginURL
            Write-EventLog -LogName Application -Source $EVLogSource -EntryType Information -EventId $LoginEVID -Message $EVMessage -ErrorAction SilentlyContinue
            
            .\wget.exe -O $Backuplocation\$date.tar.gz --max-redirect=0 --load-cookies=./cookies.txt --tries=1 $CortexDownloadURL
            Write-EventLog -LogName Application -Source $EVLogSource -EntryType Information -EventId $backupEVID -Message $EVMessageCompleted -ErrorAction SilentlyContinue
           }

           Backup-Cortex -CortexAddress "<ip/hostname>" -username admin -password <password>