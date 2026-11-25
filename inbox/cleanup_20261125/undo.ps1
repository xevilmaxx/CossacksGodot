# CLEAN-01 - one-command restore of every file quarantined by this ticket.
# The files were MOVED (never copied, never edited, never deleted) out of
# variant3d/assets/models so NTFS hardlinks into app/ were removed only on the
# variant side. Restoring is a Move-Item back to the original path with a
# SHA-256 check before and after each move.
#
# Usage (from anywhere):
#   powershell -ExecutionPolicy Bypass -File inbox\cleanup_20261125\undo.ps1
$ErrorActionPreference = 'Stop'

$here       = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo       = (Resolve-Path (Join-Path $here '..\..')).Path
$ledgerPath = Join-Path $here 'undo.json'
if (-not (Test-Path -LiteralPath $ledgerPath)) { throw "missing ledger: $ledgerPath" }

$ledger     = Get-Content -LiteralPath $ledgerPath -Raw | ConvertFrom-Json
$modelsRoot = Join-Path $repo $ledger.models_root
$qRoot      = Join-Path $repo $ledger.quarantine_root

$restored = 0
foreach ($e in $ledger.files) {
    $src = Join-Path $qRoot    $e.dst.Replace('/', [IO.Path]::DirectorySeparatorChar)
    $dst = Join-Path $modelsRoot $e.src.Replace('/', [IO.Path]::DirectorySeparatorChar)

    if (-not (Test-Path -LiteralPath $src)) { throw "quarantined file missing: $src" }
    if (Test-Path -LiteralPath $dst) { throw "destination already exists (refusing overwrite): $dst" }

    $pre = (Get-FileHash -LiteralPath $src -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($pre -ne $e.sha256) { throw "quarantine hash mismatch (file was altered in quarantine?): $src" }

    $dir = Split-Path -Parent $dst
    if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

    Move-Item -LiteralPath $src -Destination $dst

    $post = (Get-FileHash -LiteralPath $dst -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($post -ne $e.sha256) { throw "restore hash mismatch: $dst" }
    $restored++
}

Write-Output "CLEAN-01 undo OK - restored $restored files from $($ledger.quarantine_root) into $($ledger.models_root)"
