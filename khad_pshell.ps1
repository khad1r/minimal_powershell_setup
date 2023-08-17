# Check if the script is running as administrator
$currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (!$isAdmin) {
    Write-Host "Script is not running as administrator. Attempting to restart with administrator privileges..."
    
    $scriptPath = $MyInvocation.MyCommand.Definition
    $argumentList = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    
    Start-Process "powershell" -ArgumentList $argumentList -Verb RunAs
    Exit
}

winget install JanDeDobbeleer.OhMyPosh -s winget

$ohMyPoshDir = (Get-Command oh-my-posh).Source

if (!(test-path $PROFILE)) { 
	new-item -path $PROFILE -itemtype file -force 
}
$profileFolderPath = Split-Path $PROFILE

$themePath = "$profileFolderPath\minimal_shell.omp.json"

wget -O $PROFILE https://raw.githubusercontent.com/yourusername/yourrepository/master/Microsoft.PowerShell_profile.ps1

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

Install-Module -Name PSReadLine -RequiredVersion 2.2.6 -force

Install-Module -Name Terminal-Icons -Repository PSGallery