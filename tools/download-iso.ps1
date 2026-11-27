<#
download-iso.ps1 - fetch an ISO built by GitHub Actions, join it, check it
(the Windows version of download-iso.sh).

    .\tools\download-iso.ps1            # the newest ISO release
    .\tools\download-iso.ps1 iso-TAG    # a specific one (gh release list -R luzikaj/onehand-iso)

Needs the GitHub CLI signed in to an account that can read the private
repository, once:
    winget install --id GitHub.cli
    gh auth login
The ISO lands in out\<tag>\ next to the kit (or next to this script when
it's copied on its own, e.g. to Downloads). -Repo owner/name overrides the
repository (default: luzikaj/onehand-iso). If Windows refuses to run scripts:
    powershell -ExecutionPolicy Bypass -File .\tools\download-iso.ps1
Then write the ISO with Rufus in DD mode, or Fedora Media Writer.
#>
param(
    [string]$Tag = "",
    [string]$Repo = "luzikaj/onehand-iso"
)
$ErrorActionPreference = "Stop"

function Die($msg) { Write-Host " x  $msg" -ForegroundColor Red; exit 1 }

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Die "Install the GitHub CLI first: winget install --id GitHub.cli, then gh auth login"
}

if (-not $Tag) {
    $tags = gh release list -R $Repo --limit 50 --json tagName -q '.[].tagName'
    if ($LASTEXITCODE -ne 0) { Die "gh couldn't list the releases (signed in? gh auth login)" }
    $Tag = $tags | Where-Object { $_ -like 'iso-*' } | Select-Object -First 1
    if (-not $Tag) { Die "No ISO releases yet: run build-iso in $Repo first." }
}

# In the kit: out\ next to it. Script copied on its own: out\ next to the script.
$Kit = Split-Path -Parent $PSScriptRoot
if (-not (Test-Path (Join-Path $Kit "build-spin.sh"))) { $Kit = $PSScriptRoot }
$Out = Join-Path $Kit "out\$Tag"
New-Item -ItemType Directory -Force -Path $Out | Out-Null

Write-Host "==> Downloading $Tag into $Out" -ForegroundColor Blue
gh release download $Tag -R $Repo --dir $Out --clobber --pattern '*.part*' --pattern SHA256SUMS
if ($LASTEXITCODE -ne 0) { Die "Download failed." }

# SHA256SUMS: "<hash>  <file name>"
$line = (Get-Content (Join-Path $Out "SHA256SUMS") | Select-Object -First 1).Trim()
$want, $name = $line -split '\s+', 2
$name = $name.TrimStart('*')
if (-not $name) { Die "SHA256SUMS is empty." }
$Iso = Join-Path $Out $name

Write-Host "==> Joining the parts" -ForegroundColor Blue
$parts = Get-ChildItem -Path $Out -Filter "$name.part*" | Sort-Object Name
if (-not $parts) { Die "No .part files were downloaded." }
$dst = [System.IO.File]::Create($Iso)
try {
    foreach ($p in $parts) {
        $src = [System.IO.File]::OpenRead($p.FullName)
        try { $src.CopyTo($dst, 4MB) } finally { $src.Dispose() }
    }
} finally { $dst.Dispose() }

Write-Host "==> Checking (takes a minute)" -ForegroundColor Blue
$have = (Get-FileHash -Algorithm SHA256 -Path $Iso).Hash.ToLower()
if ($have -ne $want.ToLower()) {
    Die "Checksum mismatch: delete $Out and download again."
}
Write-Host "$name`: OK"
$parts | Remove-Item

Write-Host ""
Write-Host "Ready: $Iso" -ForegroundColor Green
Write-Host "Write it to a USB stick with Rufus in DD mode (when Rufus asks, pick"
Write-Host "'Write in DD Image mode'), or with Fedora Media Writer."
