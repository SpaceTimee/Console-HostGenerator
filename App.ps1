Class App {
    [void] Main() {
        $this.Welcome()
        $this.GenerateHost($this.GetHostPath())
        $this.Closing()
    }

    hidden [void] Welcome() {
        Clear-Host
        Write-Host "Console HostGenerator 启动!" -ForegroundColor Red
    }

    hidden [string] GetHostPath() {
        [string] $hostPath = [string]::Empty

        while (-not (Test-Path $hostPath -PathType Container)) {
            $hostPath = (Read-Host "输入 Cealing-Host-List.json 文件保存目录路径 (默认脚本根目录)").Trim("""")

            if ([string]::IsNullOrWhiteSpace($hostPath)) { $hostPath = $PSScriptRoot }
        }

        return $hostPath
    }

    hidden [void] GenerateHost([string] $hostPath) {
        [bool] $isGeneralList = $false
        [string] $lastListDomain = [string]::Empty

        foreach ($listRule in [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Invoke-WebRequest "https://gitlab.com/gfwlist/gfwlist/raw/master/gfwlist.txt"))) -split "`n") {
            if (-not $isGeneralList) {
                if ($listRule.Contains("General List Start")) {
                    Set-Content (Join-Path $hostPath "Cealing-Host-List.json") "["

                    $isGeneralList = $true
                }

                continue
            }
            elseif ($listRule.Contains("General List End")) {
                Add-Content (Join-Path $hostPath "Cealing-Host-List.json") "]" -NoNewline

                return
            }

            if ($listRule -notmatch "^[!@\[/]" -and -not [string]::IsNullOrWhiteSpace($listRule)) {
                [string] $listDomain = $listRule.Trim() -replace "^[|.*]+", [string]::Empty -replace "^https?://", [string]::Empty -replace "/.*$", [string]::Empty
                [int] $tryCount = 3

                if ($listDomain -eq $lastListDomain) { continue }
                else { $lastListDomain = $listDomain }

                while ($true) {
                    try {
                        [array] $hostIpAnswer = (Invoke-RestMethod "https://ns.net.kg/dns-query?name=$listDomain").Answer

                        if ($hostIpAnswer) { Add-Content (Join-Path $hostPath "Cealing-Host-List.json") "`t[[""*$listDomain""],"""",""$($hostIpAnswer[-1].data)""]," }
                        else { Write-Host "$listDomain 解析失败" }

                        break
                    }
                    catch {
                        if (-not $tryCount--) {
                            Write-Host "$listDomain 解析失败"

                            break
                        }
                    }
                }
            }
        }
    }

    hidden [void] Closing() {
        Write-Host "伪造规则，生出来啦!" -ForegroundColor Red
    }
}