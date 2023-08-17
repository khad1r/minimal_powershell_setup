# Check if the script is running as administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$scriptPath = $MyInvocation.MyCommand.Definition

if (!$isAdmin) {
    Write-Host "Script is not running as administrator. Attempting to restart with administrator privileges..."
    
    $argumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    Start-Process "powershell" -ArgumentList $argumentList -Verb RunAs
    Exit
}

#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-RestMethod https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, show the message and do nothing.
else {
    Get-Item -Path $PROFILE | Move-Item -Destination oldprofile.ps1
    Invoke-RestMethod https://github.com/ChrisTitusTech/powershell-profile/raw/main/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
}


winget install JanDeDobbeleer.OhMyPosh -s winget

$ohMyPoshDir = (Get-Command oh-my-posh).Source

$profileFolderPath = Split-Path $PROFILE

$themePath = "$profileFolderPath/minimal_shell.omp.json"

wget -O $themePath https://raw.githubusercontent.com/yourusername/yourrepository/master/minimal_shell.omp.json

# Define the custom string to replace the first line with
$customString = "$ohMyPoshDir init pwsh --config '$themePath' | Invoke-Expression"
# Read the content of the file
$fileContent = Get-Content -Path $PROFILE -Raw
# Find the index of the first line break
$firstLineBreakIndex = $fileContent.IndexOf("`r`n")
if ($firstLineBreakIndex -ge 0) {
    # Extract the part of the content after the first line break
    $remainingContent = $fileContent.Substring($firstLineBreakIndex + 2)

    # Construct the new content with the custom string
    $newContent = "$customString`r`n$remainingContent"

    # Write the new content back to the file
    $newContent | Set-Content -Path $filePath
    Write-Host "First line replaced with Corect Oh My Posh Init."
} else {
    Write-Host "File is empty or does not contain a line break."
}

# Font Install
# Get all installed font families
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$fontFamilies = (New-Object System.Drawing.Text.InstalledFontCollection).Families

# Check if CaskaydiaCove NF is installed
if ($fontFamilies -notcontains "CaskaydiaCove NF") {
    
    # Download and install CaskaydiaCove NF
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile("https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CascadiaCode.zip", ".\CascadiaCode.zip")

    Expand-Archive -Path ".\CascadiaCode.zip" -DestinationPath ".\CascadiaCode" -Force
    $destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
    Get-ChildItem -Path ".\CascadiaCode" -Recurse -Filter "*.ttf" | ForEach-Object {
        If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {        
            # Install font
            $destination.CopyHere($_.FullName, 0x10)
        }
    }

    # Clean up
    Remove-Item -Path ".\CascadiaCode" -Recurse -Force
    Remove-Item -Path ".\CascadiaCode.zip" -Force
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned CurrentUser -force

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned LocalMachine -force

Install-Module -Name PSReadLine -RequiredVersion 2.2.6 -force

Install-Module -Name Terminal-Icons -Repository PSGallery

if (test-path $scriptPath) { rm $scriptPath}

. $PROFILE