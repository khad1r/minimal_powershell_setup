C:\path\to\oh-my-posh.exe init pwsh --config 'C:\path\to\WindowsPowerShell\minimal_shell.omp.json' | Invoke-Expression
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Import-Module -Name Terminal-Icons
function sudo {
    Start-Process @args -verb runas
}
function Get-Hotkeys {
    Get-PSReadLineKeyHandler | Format-Table -AutoSize -Property Key, Function, Description
}
function Start-ElevatedPS {
    param([ScriptBlock]$code)

    Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList $code
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
clear

