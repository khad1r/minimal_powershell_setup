Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Import-Module -Name Terminal-Icons
Import-Module posh-git
Invoke-Expression (&starship init powershell)

# Compute file hashes - useful for checking successful downloads 
function Compute-Hash {
    param (
        [string]$Value,
        [string]$Algorithm
    )

    if (Test-Path $Value -PathType Leaf) {
        Get-FileHash -Path $Value -Algorithm $Algorithm
    }
    else {
        $StringStream = [IO.MemoryStream]::new([byte[]][char[]]$Value)
        Get-FileHash -InputStream $StringStream -Algorithm $Algorithm
    }
}
function md5($value) { Compute-Hash $value MD5 }
function sha1($value) { Compute-Hash $value SHA1 }
function sha256($value) { Compute-Hash $value SHA256 }

function sudo {
    Start-Process @args -verb runas
}
function cdf {
    Get-ChildItem . -Recurse -Attributes Directory | Invoke-Fzf | Set-Location
}
function Open-File {
    Get-ChildItem . -Recurse -Attributes !Directory | Invoke-Fzf | % { & "$_" }
}
function Get-Hotkeys {
    Get-PSReadLineKeyHandler | Format-Table -AutoSize -Property Key, Function, Description
}
function Get-PubIP {
    (Invoke-WebRequest http://ifconfig.me/ip ).Content
}
function Start-ElevatedPS {
    param([ScriptBlock]$code)

    Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList $code
}
function find-file($name) {
    Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
        $place_path = $_.directory
        Write-Output "${place_path}\${_}"
    }
}
function unzip ($file) {
    Write-Output("Extracting", $file, "to", $pwd)
    $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
    Expand-Archive -Path $fullFile -DestinationPath $pwd
}

# Create an alias for Restart-Computer with -Firmware switch
function ToTheBios { 
    shutdown /r /fw /f /t 0 
}
function Invoke-Starship-TransientFunction {
    &starship module shell
}

# Related: https://github.com/PowerShell/PSReadLine/issues/1778
Set-PSReadLineKeyHandler -Key Shift+Delete `
    -BriefDescription RemoveFromHistory `
    -LongDescription "Removes the content of the current line from history" `
    -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    $toRemove = [Regex]::Escape(($line -replace "\n", "```n"))
    $history = Get-Content (Get-PSReadLineOption).HistorySavePath -Raw
    $history = $history -replace "(?m)^$toRemove\r\n", ""
    Set-Content (Get-PSReadLineOption).HistorySavePath $history
}
# Enable-TransientPrompt


#clear