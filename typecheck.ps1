# typecheck.ps1
# Parse-only check of the non-UI Swift files using the Windows toolchain.
# Catches obvious typos, missing commas, wrong types, etc. before moving to Mac.
#
# We can't fully typecheck files that import Supabase or SwiftUI on Windows
# because those frameworks aren't available. Supabase-touching files use
# `#if canImport(Supabase)` guards that are false on Windows, so the stub
# branch compiles cleanly. SwiftUI files are skipped entirely.

$ErrorActionPreference = 'Stop'

$toolchainBin = 'C:\Users\codyw\AppData\Local\Programs\Swift\Toolchains\6.3.0+Asserts\usr\bin'
$runtimeBin   = 'C:\Users\codyw\AppData\Local\Programs\Swift\Runtimes\6.3.0\usr\bin'
$swiftc       = Join-Path $toolchainBin 'swiftc.exe'

$env:Path    = "$runtimeBin;$toolchainBin;" + $env:Path
$env:SDKROOT = 'C:\Users\codyw\AppData\Local\Programs\Swift\Platforms\6.3.0\Windows.platform\Developer\SDKs\Windows.sdk'

$root = 'C:\Users\codyw\Documents\mlb-value-bets-ios\MLBValueBets'

# Files that are safe to parse on Windows (no SwiftUI, no actual Supabase import)
$files = @(
    "$root\Core\Utilities\Config.swift",
    "$root\Core\Utilities\ErrorTypes.swift",
    "$root\Core\Utilities\FontLoader.swift",
    "$root\Core\Utilities\Extensions\Date+Format.swift",
    "$root\Core\Models\Pick.swift",
    "$root\Core\Models\PicksResponse.swift",
    "$root\Core\Models\Profile.swift",
    "$root\Core\Models\Performance.swift",
    "$root\Core\Services\SupabaseManager.swift",
    "$root\Core\Services\APIClient.swift",
    "$root\Core\Services\AuthService.swift",
    "$root\Core\Services\PicksService.swift",
    "$root\Core\Services\PerformanceService.swift",
    "$root\Core\Services\BillingService.swift"
)

Write-Host "Running swiftc -parse on $($files.Count) files..." -ForegroundColor Cyan

$stdout = Join-Path $PSScriptRoot 'typecheck-stdout.txt'
$stderr = Join-Path $PSScriptRoot 'typecheck-stderr.txt'
if (Test-Path $stdout) { Remove-Item $stdout }
if (Test-Path $stderr) { Remove-Item $stderr }

$argList = @('-parse') + $files
$proc = Start-Process -FilePath $swiftc `
    -ArgumentList $argList `
    -NoNewWindow -Wait -PassThru `
    -RedirectStandardOutput $stdout `
    -RedirectStandardError  $stderr

Write-Host ""
Write-Host "ExitCode=$($proc.ExitCode)"
if (Test-Path $stdout) {
    $out = Get-Content $stdout -Raw
    if ($out) { Write-Host "--- stdout ---"; Write-Host $out }
}
if (Test-Path $stderr) {
    $err = Get-Content $stderr -Raw
    if ($err) { Write-Host "--- stderr ---" -ForegroundColor Yellow; Write-Host $err }
}

if ($proc.ExitCode -eq 0) {
    Write-Host "`n✓ All files parsed clean." -ForegroundColor Green
} else {
    Write-Host "`n✗ Parse errors — see above." -ForegroundColor Red
}
exit $proc.ExitCode
