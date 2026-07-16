param ([string] $trans, [switch] $loop, [string] $out)

do {
    if (Test-Path -LiteralPath $trans -PathType Container) {
        $null = Start-Transcript -LiteralPath (Join-Path $trans "Trans.log") -UseMinimalHeader
    }

    if (-not $IsCoreCLR) {
        Write-Host "该脚本需要在 PowerShell 7.x 环境运行"
    }
    else {
        foreach ($ps1File in Get-ChildItem -LiteralPath $PSScriptRoot "*.ps1") {
            if ($ps1File.FullName -ne $PSCommandPath) { . $ps1File.FullName }
        }

        [App]::new().Main($out)
    }

    if (Test-Path -LiteralPath $trans -PathType Container) { Stop-Transcript }
    if ($loop) { Start-Sleep 60 }
}
while ($loop)

Read-Host "按回车键结束"