
If(-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}


# $rootPath = Read-Host -Prompt "Enter the path where the Library folder is located. If unsure, run RSI Launcher > Settings > Library Folder (e.g. F:\RSI)"

$rootPath = "C:\Program Files\Roberts Space Industries"

$version = Read-Host -Prompt "Enter the version you want to modify (e.g. LIVE, PTU, EPTU, TECH, 4.0_PREVIEW)"

switch ($version) {
    "LIVE" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcecharacters = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -Directory -Recurse | Where-Object {$_.Name -eq "CustomCharacters"}
		$sourceattributes = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -File -Recurse | Where-Object {$_.Name -eq "attributes.xml"}
        $sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\LIVE" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    "PTU" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcecharacters = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -Directory -Recurse | Where-Object {$_.Name -eq "CustomCharacters"}
        $sourceattributes = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -File -Recurse | Where-Object {$_.Name -eq "attributes.xml"}
		$sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\PTU" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    "EPTU" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcecharacters = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -Directory -Recurse | Where-Object {$_.Name -eq "CustomCharacters"}
        $sourceattributes = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -File -Recurse | Where-Object {$_.Name -eq "attributes.xml"}
		$sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\EPTU" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }"TECH" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\TECH-PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcecharacters = Get-ChildItem -Path "$rootPath\StarCitizen\TECH-PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "CustomCharacters"}
        $sourceattributes = Get-ChildItem -Path "$rootPath\StarCitizen\TECH-PREVIEW" -File -Recurse | Where-Object {$_.Name -eq "attributes.xml"}
		$sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\TECH-PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }"4.0_PREVIEW" {
        $sourcebindings = Get-ChildItem -Path "$rootPath\StarCitizen\4.0_PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "Mappings"}
        $sourcecharacters = Get-ChildItem -Path "$rootPath\StarCitizen\4.0_PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "CustomCharacters"}
        $sourceattributes = Get-ChildItem -Path "$rootPath\StarCitizen\4.0_PREVIEW" -File -Recurse | Where-Object {$_.Name -eq "attributes.xml"}
		$sourcefolder = Get-ChildItem -Path "$rootPath\StarCitizen\4.0_PREVIEW" -Directory -Recurse | Where-Object {$_.Name -eq "USER"}
    }
    default {
        Write-Host "Invalid input. Please enter a valid version (e.g. LIVE, PTU, EPTU)"
        exit
    }
}

if ($sourcebindings -eq $null -or $sourcefolder -eq $null) {
    $confirmation = Read-Host "Mappings or USER folder not found. Press 'Y' to exit the script"
    if ($confirmation -eq 'Y') {
    exit
    }
}

# $backupfolder = "$env:localappdata\Star Citizen Backup $version $((Get-Date).ToString("MMddyyyy"))"
$backupfolder = "$env:localappdata\Star Citizen Backup $version $((Get-Date).ToString("yyyyMMddHHmmss"))"
$attributesbackup = "$backupfolder\attributes"


# this code 
# if ($confirm -eq 'yes') {
#     # Script code
#     if (!(Test-Path -Path $backupfolder)) {
#         New-Item -ItemType directory -Path $backupfolder
#     }
#     Copy-Item -Path $sourcebindings.FullName -Destination $backupfolder -Recurse
# }

$shadersfolder = "$env:localappdata\Star Citizen"

$confirm = Read-Host -Prompt "Do you want to continue and backup your files? (yes/no)"
if ($confirm -eq 'yes') {
    # Script code
} else {
    Write-Host "Script execution stopped"
	Start-Sleep -Seconds 5
    exit
}

# create the backup folders - need to do this so that copying the mappings folder makes
# a mappings folder 
if (!(Test-Path -Path $backupfolder)) {
        New-Item -ItemType directory -Path $backupfolder | Out-Null
}
# create a subfolder for the attributes file 
if (!(Test-Path -Path $attributesbackup)) {
        New-Item -ItemType directory -Path $attributesbackup | Out-Null
}

# copy the saved bindings folder to the backup folder 
Copy-Item -Path $sourcebindings.FullName -Destination $backupfolder -Recurse
Write-Host "Bindings/Mappings backed up"
# copy the attributes file to the backup folder
Copy-Item -Path $sourceattributes.FullName -Destination $attributesbackup
Write-Host "Attributes file backed up"
# copy the custom characters folder to the backup folder 
Copy-Item -Path $sourcecharacters.FullName -Destination $backupfolder -Recurse
Write-Host "Custom Characters backed up"

if (Test-Path $backupfolder -PathType Container) {
    # folder exists, continue with the script
} else {
    Write-Host "Folder $backupfolder does not exist"
    # stop the script or take other necessary actions
}

$confirm = Read-Host -Prompt "Do you want to continue and remove your shader and user folders? (yes/no)"
if ($confirm -eq 'yes') {
    # Script code
} else {
    explorer.exe "$backupfolder" 
	Write-Host "Script execution stopped"
	Start-Sleep -Seconds 5
    exit
}

# Remove the user and shader folders 
Remove-Item -Path $sourcefolder.FullName -Recurse -Force

Remove-Item -Path $shadersfolder -Recurse -Force

$response = Read-Host -Prompt "Please launch Star Citizen. Once fully loaded and at the menu screen, quit the game and continue the script. Type 'done' when ready to move to the next step"
while ($response -ne 'done') {
    $response = Read-Host -Prompt "Please launch Star Citizen and then close the game after launch and type 'done' below"
}


###
###
### now to copy stuff back 
###
###

# restore the bindings/mappings files 
if (Test-Path $sourcebindings.FullName -PathType Container) {
    # folder exists, use one form of the copy command 
	Copy-Item -Path "$backupfolder\Mappings\*" -Destination $sourcebindings.FullName -Recurse
} else {
    # use the form of copy command that creates the folder 
	Write-Host "Creating mappings files directory"
	Copy-Item -Path "$backupfolder\Mappings\" -Destination $sourcebindings.FullName -Recurse
}
Write-Host "Mappings files restored"

# restore the attributes file 
if (Test-Path $sourceattributes.Directory -PathType Container) {
    # folder exists, continue script 	
} else {
    # use the form of copy command that creates the folder 
	Write-Host "Creating attributes file directory"
	New-Item -ItemType directory -Path $sourceattributes.Directory
}
Copy-Item -Path "$backupfolder\attributes\attributes.xml" -Destination $sourceattributes.Directory
Write-Host "Attributes file restored"

# restore the custom character files 
if (Test-Path $sourcecharacters.FullName -PathType Container) {
    # folder exists, use one form of the copy command 
	Copy-Item -Path "$backupfolder\CustomCharacters\*" -Destination $sourcecharacters.FullName -Recurse
} else {
    # use the form of copy command that creates the folder 
	Write-Host "Creating custom characters files directory"
	Copy-Item -Path "$backupfolder\CustomCharacters\" -Destination $sourcecharacters.FullName -Recurse
}
Write-Host "Custom Characters restored"

Write-Host "Task completed successfully. Don't forget to load your custom controls using in-game options menu or the in-game console with the command 'pp_rebindkeys <xmlpath>' to load the xml.  Press 'Y' to close the script."
$confirmation = Read-Host
if ($confirmation -eq 'Y') {
    exit
}
