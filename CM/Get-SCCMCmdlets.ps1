Function Get-SCCMCMdlets {
<#
.NOTES   
Name: Get-SCCMCmdlets
Author: Jesse Walter
Version: 1.0
Date Created: 11/24/2014
Date Updated: 11/24/2014

.SYNOPSIS   
The purpose of this script is to locate the Configuration Manager CMLets on any free drive on the system.
    
.DESCRIPTION 
The script searches all free drives for configurationmanager.psd1, which is useful in the instance where ConfigMgr is installed to a volume other than C:. The script will then import the module and change the drive to the local site location.

.LINK
http://www.model-technology.com

.EXAMPLE   
.\Get-SCCMCmdlets.ps1

Description:
Will search all free drives for the CMLets and import the module.
#>

#region Functions

Function Import-CMModule {
$Drives = Get-PSDrive -PSProvider FileSystem | Where-Object -Property Free
$FreeDrives = $Drives.name
$CMLets = "configurationmanager.psd1"

    ForEach ($drive in $FreeDrives)
    {
        $drive = $drive + ":"
        Write-Host "Attempting to locate CMLets on $drive..." -ForegroundColor Yellow
        cd $drive\
        $FilePath = (gci $drive -File -Filter $CMLets -Recurse -Force -ErrorVariable FailedItems -ErrorAction SilentlyContinue).FullName
        if ($FilePath)
        {
            $CMModule = $FilePath
            Write-Host "Found $CMModule. Importing..." -ForegroundColor Green
        
            try{
                    Import-Module $CMModule
               }
            catch
                {
                    $_
                }
            break
        }
        else
        {
            Write-Host "Cannot find in $drive..." -ForegroundColor Red
        }
    }
}

#endregion Functions

#region ScriptBody

Import-CMModule

$site = (gwmi -ComputerName $env:COMPUTERNAME -Namespace "root\SMS" -Class "SMS_ProviderLocation").SiteCode
$sitecodeDir = $site + ":"
CD $sitecodeDir

#endregion ScriptBody
}