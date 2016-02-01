#----------------------------------------------------------------------------- 
# Script: BackupCortex.ps1
# Author: Ainsey11 (https://ainsey11.com) 
# Date: 01/21/2016 23:38:14  
# ----------------------------------------------------------------------------- 

Function Backup-Cortex{
    param (
            [string] $CortexAddress, 
            [string] $username,
            [string] $password,
            [string] $EmailAddress = $null,
            [string] $mailserver,
            [string] $retention = 30, 
            [string] $DownloadIVR = $true,
            [string] $DownloadCallRecordings = $true
            
           )
            #static variables, not much need to tweak these
            $date = Get-Date -Format dd-MM-yy # used for the name of the file
            $EVLogSource = "Ainsey11-BackupCortex" #ev handling
            $LoginEVID = "1000" # ev handling
            $BackupEVID = "1001"# ev handling
            $EVMessage = "Cortex Backup has been initiated, logging in" # ev handling
            $EVMessageCompleted = "Cortex Backup has been initiated, logging in" # ev handling
            $BackupLocation = "C:\Backups" # root backup location
            $tempfile = "$BackupLocation\tmp.txt" #tmp file
            $CortexLoginURL = "http://$CortexAddress/login.whtm?sessionUser=$username&sessionPass=$password" #making the url sting
            $CortexDownloadURL = "http://$CortexAddress/admin/backup.whtm/update/backup.tar.gz" #making the url sting for downloading the gz
            $CortexIVRDownloadURL = "http://$CortexAddress/admin/backup.whtm/update/ivr.tar.gz" #making the url sting for downloading the gz
            $CortexCallRecordingURL = "http://$CortexAddress/link/monitor.whtm" #URL for call recordings
            $Wgetlocation = "C:\Program Files (x86)\GnuWin32\bin"
            $CortexCallRecordFile = (gc $tempfile | % { if($_ -match "_default.cgi/recorded.tar.gz") {$_.substring(13,$_.length-13-37)}}) #some clever bits to find the url
            $CortexCallRecordFileUrl = "http://$CortexAddress$CortexCallRecordFile" #final url


            New-EventLog -LogName Application -Source $EVLogSource -ErrorAction SilentlyContinue #making EventLog source

            cd $Wgetlocation

            #Do the downloads now
            .\wget.exe -O $tempfile --max-redirect=1 --save-cookies=./cookies.txt --keep-session-cookies --tries=1 $CortexLoginURL #Logging in via wget
            Write-EventLog -LogName Application -Source $EVLogSource -EntryType Information -EventId $LoginEVID -Message $EVMessage -ErrorAction SilentlyContinue #ev handling
            
            #More downloads - downloading backup, no variable here as assumed wanted as default
            .\wget.exe -O $Backuplocation\$date.tar.gz --max-redirect=1 --load-cookies=./cookies.txt --tries=1 $CortexDownloadURL #Logging in via wget
            Write-EventLog -LogName Application -Source $EVLogSource -EntryType Information -EventId $backupEVID -Message $EVMessageCompleted -ErrorAction SilentlyContinue #ev handling

            #More downloads - downloading ivr
            if ($DownloadIVR = $true) 
                {
            .\wget.exe -O $Backuplocation\"$date-IVR.tar.gz" --max-redirect=1 --load-cookies=./cookies.txt --tries=1 $CortexIVRDownloadURL #Logging in via wget
            Write-EventLog -LogName Application -Source $EVLogSource -EntryType Information -EventId $backupEVID -Message $EVMessageCompleted -ErrorAction SilentlyContinue #ev handling
                }

            #More downloads - downloading Callrecordings 
            if( $DownloadCallRecordings = $true)
                {
            .\wget.exe -O $tempfile --max-redirect=1 --load-cookies=./cookies.txt --tries=1 $CortexCallRecordingURL
                }
            
            
            #Sends e-mail alert, will send to $null if not set. 
            Send-MailMessage -To $EmailAddress -From "CortexBackups@$cortexAddress" -Subject "Backup has been run" -SmtpServer $mailserver

            #Retention Code now
            Get-ChildItem -Path $BackupLocation -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $retention } | Remove-Item -Force
           }

           # Example of use:
            Backup-Cortex -CortexAddress "<ip/hostname>" -username admin -password password -EmailAddress "admin@domain.com" -mailserver "mail.domain.com" -retention 15 