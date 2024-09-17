param ([string] $trans, [switch] $loop)

do {
    if (Test-Path $trans) { Start-Transcript (Join-Path $trans "Trans.log") -UseMinimalHeader | Out-Null }

    if ($PSEdition -ne "Core") {
        Write-Host "该脚本需要在 PowerShell 7.x 环境运行"
    }
    else {
        foreach ($ps1File in Get-ChildItem $PSScriptRoot "*.ps1") {
            if ($ps1File.FullName -ne $PSCommandPath) { . $ps1File.FullName }
        }

        [App]::new().Main()
    }

    if (Test-Path $trans) { Stop-Transcript }
    if ($loop) { Start-Sleep 60 }
} while ($loop)

Read-Host "按回车键结束"