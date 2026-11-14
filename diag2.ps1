# Nova Player: network path to GitHub from this PC (no secrets).
$ProgressPreference = 'SilentlyContinue'
Write-Host "== api.github.com resolves to:" -ForegroundColor Cyan
try { [Net.Dns]::GetHostAddresses('api.github.com') | ForEach-Object { $_.IPAddressToString } } catch { "DNS error: $($_.Exception.Message)" }
Write-Host "== hosts file lines mentioning github:" -ForegroundColor Cyan
Get-Content "$env:windir\System32\drivers\etc\hosts" -ErrorAction SilentlyContinue | Select-String github
Write-Host "== Public IP country (from GitHub's view is not available; ipinfo):" -ForegroundColor Cyan
& curl.exe -s https://ipinfo.io/country
Write-Host ""
Write-Host "== Unauthenticated test (expect 401):" -ForegroundColor Cyan
& curl.exe -s -o NUL -w "%{http_code}`n" -X POST -H "Content-Type: application/json" -d "{}" https://api.github.com/actions/runner-registration
Write-Host "== VPN / network adapters:" -ForegroundColor Cyan
Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object Status -eq 'Up' | Select-Object Name, InterfaceDescription | Format-Table -AutoSize
