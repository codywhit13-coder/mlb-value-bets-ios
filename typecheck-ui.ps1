# typecheck-ui.ps1
# Parse-only check of the SwiftUI files.
# `swiftc -parse` only validates syntax — it doesn't resolve imports —
# so SwiftUI and Supabase modules being unavailable on Windows is fine.

$ErrorActionPreference = 'Stop'

$toolchainBin = 'C:\Users\codyw\AppData\Local\Programs\Swift\Toolchains\6.3.0+Asserts\usr\bin'
$runtimeBin   = 'C:\Users\codyw\AppData\Local\Programs\Swift\Runtimes\6.3.0\usr\bin'
$swiftc       = Join-Path $toolchainBin 'swiftc.exe'

$env:Path    = "$runtimeBin;$toolchainBin;" + $env:Path
$env:SDKROOT = 'C:\Users\codyw\AppData\Local\Programs\Swift\Platforms\6.3.0\Windows.platform\Developer\SDKs\Windows.sdk'

$root = 'C:\Users\codyw\Documents\mlb-value-bets-ios\MLBValueBets'

$files = @(
    "$root\App\MLBValueBetsApp.swift",
    "$root\Core\Utilities\Extensions\Color+Theme.swift",
    "$root\Features\Auth\LoginView.swift",
    "$root\Features\Auth\AuthViewModel.swift",
    "$root\Features\Dashboard\DashboardView.swift",
    "$root\Features\Dashboard\DashboardViewModel.swift",
    "$root\Features\Picks\PicksListView.swift",
    "$root\Features\Picks\PickDetailView.swift",
    "$root\Features\Picks\PickCard.swift",
    "$root\Features\Picks\LockedPickCard.swift",
    "$root\Features\Picks\PicksViewModel.swift",
    "$root\Features\Settings\SettingsView.swift"
)

Write-Host "Parse-checking $($files.Count) SwiftUI files..." -ForegroundColor Cyan

$stdout = Join-Path $PSScriptRoot 'ui-stdout.txt'
$stderr = Join-Path $PSScriptRoot 'ui-stderr.txt'
if (Test-Path $stdout) { Remove-Item $stdout }
if (Test-Path $stderr) { Remove-Item $stderr }

$argList = @('-parse') + $files
$proc = Start-Process -FilePath $swiftc `
    -ArgumentList $argList `
    -NoNewWindow -Wait -PassThru `
    -RedirectStandardOutput $stdout `
    -RedirectStandardError  $stderr

Write-Host "ExitCode=$($proc.ExitCode)"
if (Test-Path $stdout) {
    $out = Get-Content $stdout -Raw
    if ($out) { Write-Host "--- stdout ---"; Write-Host $out }
}
if (Test-Path $stderr) {
    $err = Get-Content $stderr -Raw
    if ($err) { Write-Host "--- stderr ---"; Write-Host $err }
}
exit $proc.ExitCode
