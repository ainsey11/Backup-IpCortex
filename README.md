# Ainsey11's IPCortex Powershell Backup Utility
This script aids in automation of backing up IPcortex units via web requests. 

At the moment it does :
  - Names backup files as the Date 
  - Backs up configuration and IVR 
  - Logs to event log for historical review

### Current Version : 1.0
### Installation Instructions :

 - Install GNUWin32 WGET from here : http://gnuwin32.sourceforge.net/packages/wget.htm as default settings.
   - this is because the standard Invoke-Webrequest function in powershell cannot handle cookies and sesssions the way I needed it to. I might be able to come up with a solution for a future release.
 - Create a folder at C:\Backups
    - this is to hold the script and logs in, I will explain moving this location later on
- Copy Backup-Cortex.ps1 into this folder
- Open task scheduler, right click and select Import Task
- Browse to Backup-Cortex.xml and seclect import
- Change the user account it runs under to an appropriate one
- On the triggers secion - change the time to an appropriate setting
- Save scheduled task
- Right click the Backup-Cortex.ps1 file and selecy edit
- Change the last line to suit your environment
    - For example it would look like : Backup-Cortex -CortexAddress "10.1.1.7" -Username "admin" -Password "password"
    - Save this file 
    - exit the editor / notepad
- Right click and select run with powershell, check backup file is created
- if file is created then all is working, if not - retrace the steps above


## Custom Configuration
For some use cases, you may not want to store the backups on the C: drive. In this case, you need to make 2 changes. 
#### Change 1
-  Open up Backup-Cortex.ps1
-  Change Line 20 from C:\Backups to your location, DO NOT LEAVE A TRAILING BACKSLASH 

#### Change 2
- Before importing the XML for the scheduled task for the automation side right click the Backup-Cortex.ps1 file and select edit
- On Line 49 change the path after the -File to the new location of the PS1 file.


##### Improvement Plan:
 - Implement E-mail alerting
 - Implement backup file retention
