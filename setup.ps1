# Check if the script is running as administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$scriptPath = $MyInvocation.MyCommand.Definition
$profileFolderPath = Split-Path $PROFILE

# if (!$isAdmin) {
#     Write-Host "Script is not running as administrator. Try With Elevated Previledge..."
    
#     # $argumentList = "-NoProfile -ExecutionPolicy Bypass -File '$scriptPath'"
    
#     # Start-Process "powershell" -ArgumentList $argumentList -Verb RunAs
#     Exit
# }

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

        Invoke-RestMethod https://raw.githubusercontent.com/khad1r/minimal_powershell_setup/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, move to oldProfile.ps1.
else {
    Get-Item -Path $PROFILE | Move-Item -Destination $profileFolderPath/oldprofile.ps1
    Invoke-RestMethod https://raw.githubusercontent.com/khad1r/minimal_powershell_setup/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
    Write-Host "The profile @ [$PROFILE] has been created and old profile has been moved @ [$profileFolderPath/oldprofile.ps1]."
}
# Instaling The Oh-My-Posh
# winget install JanDeDobbeleer.OhMyPosh -s winget

#Install Scooop & Fzf
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
scoop install fzf
Install-Module -Name PSFzf -Scope CurrentUser -Force
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json

# Reloading Path Environment Variable
$Env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Get OhMyPosh Directory
$ohMyPoshDir = (Get-Command oh-my-posh).Source

# Get The Oh-My-Posh theme
$themePath = "$profileFolderPath/minimal_shell.omp.json"
wget -O $themePath https://raw.githubusercontent.com/khad1r/minimal_powershell_setup/main/minimal_shell.omp.json


### Refactor the OhMyPosh Init in profile file
# Define the custom string to replace the first line with
$customString = "$ohMyPoshDir init pwsh --config '$themePath' | Invoke-Expression"
# Read the content of the file
$fileContent = Get-Content -Path $PROFILE -Raw
# Find the index of the first line break
$remainingContent = $fileContent.Substring(2)
# Construct the new content with the custom string
$newContent = "$customString`r`n$remainingContent"
# Write the new content back to the file
$newContent | Set-Content -Path $PROFILE
Write-Host "Added Oh My Posh Init."

Write-Host "Installing Nerd Font......"
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
        Write-Host "        Installing Font $($_.Name)......"
        If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {        
            # Install font
            $destination.CopyHere($_.FullName, 0x10)
        }
    }

    # Clean up
    Remove-Item -Path ".\CascadiaCode" -Recurse -Force
    Remove-Item -Path ".\CascadiaCode.zip" -Force
}

Write-Host "Set The Execution Policy......"

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned CurrentUser -force

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned LocalMachine -force

Write-Host "Updating PSReadLine And Instaling Terminal-Icons ....."

Install-Module -Name PSReadLine -RequiredVersion 2.2.6 -force

Install-Module -Name Terminal-Icons -Repository PSGallery

if (test-path $scriptPath) { rm $scriptPath}

if (Get-Command wt) { 
    Start wt
    Exit
}
Write-Host "Windows Terminal Is Not Installed !!!!, Start Powershell"
start powershell
Exit