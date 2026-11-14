# Nova Player: installs a GitHub Actions runner on this PC so Android builds run here for free.
# Usage: setup-runner.ps1 -Token <registration token from the repo's "New self-hosted runner" page>
# Nothing secret is stored in this file. Remove later: delete the folder and the runner in GitHub settings.
param([Parameter(Mandatory = $true)][string]$Token)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$dir = Join-Path $HOME 'actions-runner'
Write-Host "== Nova Player build runner -> $dir" -ForegroundColor Cyan
$free = [math]::Round((Get-PSDrive ($HOME.Substring(0,1))).Free / 1GB, 1)
Write-Host "Free disk space: $free GB (about 6 GB needed)"
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Set-Location $dir
if (-not (Test-Path (Join-Path $dir 'config.cmd'))) {
  $rel = Invoke-RestMethod 'https://api.github.com/repos/actions/runner/releases/latest'
  $ver = $rel.tag_name.TrimStart('v')
  $zip = "actions-runner-win-x64-$ver.zip"
  Write-Host "Downloading runner $ver ..."
  Invoke-WebRequest "https://github.com/actions/runner/releases/download/v$ver/$zip" -OutFile $zip
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::ExtractToDirectory((Join-Path $dir $zip), $dir)
  Remove-Item $zip
}
Write-Host "Registering this PC with the nova-player repository ..."
& .\config.cmd --unattended --url 'https://github.com/arnosaville77-wq/nova-player' --token $Token --name "nova-pc-$env:COMPUTERNAME" --labels nova --work '_work' --replace
if ($LASTEXITCODE -ne 0) { throw "Runner registration failed (token expired? get a new one)" }
# Start with Windows (minimized), and start now.
$startup = [Environment]::GetFolderPath('Startup')
$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut((Join-Path $startup 'Nova build runner.lnk'))
$lnk.TargetPath = Join-Path $dir 'run.cmd'
$lnk.WorkingDirectory = $dir
$lnk.WindowStyle = 7
$lnk.Save()
Start-Process -FilePath (Join-Path $dir 'run.cmd') -WorkingDirectory $dir -WindowStyle Minimized
Write-Host ""
Write-Host "Done. The runner is running (minimized window 'run.cmd') and starts with Windows." -ForegroundColor Green
Write-Host "Keep the PC on while a build runs. You can close this window."
