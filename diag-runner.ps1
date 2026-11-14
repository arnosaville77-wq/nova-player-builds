# Nova Player: why can't the runner register? Prints network settings only (no secrets).
param([string]$Token = '')
$ProgressPreference = 'SilentlyContinue'
Write-Host "== System proxy (WinHTTP):" -ForegroundColor Cyan
netsh winhttp show proxy
Write-Host "== Proxy for api.github.com (user settings):" -ForegroundColor Cyan
[System.Net.WebRequest]::GetSystemWebProxy().GetProxy([uri]'https://api.github.com/').AbsoluteUri
Write-Host "== Proxy environment variables:" -ForegroundColor Cyan
Get-ChildItem env: | Where-Object { $_.Name -match 'proxy' } | Format-Table -AutoSize
Write-Host "== .NET versions / TLS:" -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol
if ($Token) {
  Write-Host "== Registration test from PowerShell:" -ForegroundColor Cyan
  try {
    $r = Invoke-WebRequest -UseBasicParsing -Method Post -Uri 'https://api.github.com/actions/runner-registration' `
      -Headers @{ Authorization = "RemoteAuth $Token" } -ContentType 'application/json' `
      -Body '{"url":"https://github.com/arnosaville77-wq/nova-player","runner_event":"register"}'
    Write-Host "OK $($r.StatusCode)" -ForegroundColor Green
  } catch { Write-Host "FAILED: $($_.Exception.Message)" -ForegroundColor Red }
}
Write-Host "== Runner folder:" -ForegroundColor Cyan
Get-ChildItem D:\actions-runner -Force | Select-Object Name | Format-Wide -Column 4
Get-Content D:\actions-runner\_diag\*.log -ErrorAction SilentlyContinue | Select-String -Pattern 'proxy|Proxy|404|NotFound|url' | Select-Object -Last 12
