# MLB Value Bets — iOS

[![iOS Build](https://github.com/codywhit13-coder/mlb-value-bets-ios/actions/workflows/ios-build.yml/badge.svg)](https://github.com/codywhit13-coder/mlb-value-bets-ios/actions/workflows/ios-build.yml)

Native iOS companion app for [mlbvaluebets.com](https://mlbvaluebets.com).
Shares the same Supabase auth and Stripe subscriptions as the web — ships as an
App Store **Reader App** (no in-app pricing or signup).

- Backend: FastAPI on Render (unchanged, reused as-is)
- Auth: Supabase (shared users with web)
- Billing: Stripe (existing subscriptions — no IAP in Phase 1)
- Target: iOS 17+, SwiftUI, Swift 5.9+

## Repo layout

```
MLBValueBets/
├── App/                        @main entry point + root routing
├── Core/
│   ├── Models/                 Pick, PicksResponse, Profile, Performance
│   ├── Services/               Supabase, APIClient, Picks, Performance, Billing, Auth
│   └── Utilities/              Config, ErrorTypes, Color+Theme, Date+Format
├── Features/
│   ├── Auth/                   LoginView + AuthViewModel
│   ├── Dashboard/              DashboardView + VM
│   ├── Picks/                  List, Detail, PickCard, LockedPickCard, VM
│   └── Settings/               SettingsView
└── Resources/                  (Assets.xcassets + Info.plist added on Mac)
```

No Xcode project is checked in yet — it's created on the Mac side on first open.

## Windows pre-flight check (optional)

Syntax-only parse of all Swift files against the Swift 6.3 Windows toolchain —
catches typos and malformed declarations before you open Xcode on the Mac.

```powershell
# Install once:
winget install --id Swift.Toolchain --skip-dependencies

# Then run from the repo root:
powershell -ExecutionPolicy Bypass -File .\typecheck.ps1      # non-UI
powershell -ExecutionPolicy Bypass -File .\typecheck-ui.ps1   # SwiftUI
```

Both should print `ExitCode=0`. Full type-checking isn't available on Windows
because it needs Visual Studio Build Tools for `errno.h` + the WinSDK module —
the real compile runs in Xcode on the Mac.

## Cloud builds (no Mac required)

Every push to `master` triggers a build on a free GitHub Actions macOS runner.
The workflow runs `xcodegen generate` and then `xcodebuild` against the iPhone
15 Pro simulator — no signing, no Apple Developer Program needed for this
phase, just proves the code compiles.

Watch builds at:
[github.com/codywhit13-coder/mlb-value-bets-ios/actions](https://github.com/codywhit13-coder/mlb-value-bets-ios/actions)

The compiled `.app` bundle is uploaded as a build artifact (retained 7 days).
You can download it from any successful build's "Artifacts" section.

### Cost
GitHub's free tier on private repos = 2,000 CI minutes/month, but **macOS
minutes count 10×**, so effectively ~200 macOS minutes ≈ 15-25 builds/month.
Beyond that: $0.08/minute. To unlock unlimited macOS minutes, make the repo
public (the Supabase anon key is already public on the web frontend, so it's
not actually a secret).

### Trigger a build manually
Go to **Actions → iOS Build → Run workflow** in the GitHub UI, or push any
commit to `master`.

## Mac setup (one time, optional)

The Xcode project is generated from `project.yml` via
[XcodeGen](https://github.com/yonaskolb/XcodeGen) — no clicking through the
Xcode GUI required. Only needed if you want to run the simulator interactively
on a real Mac.

```bash
# 1. Install Xcode 15+ from the Mac App Store.

# 2. Install XcodeGen (one-time).
brew install xcodegen

# 3. Clone the repo.
git clone https://github.com/codywhit13-coder/mlb-value-bets-ios.git
cd mlb-value-bets-ios

# 4. Generate the Xcode project from project.yml.
xcodegen generate

# 5. Open it.
open MLBValueBets.xcodeproj

# 6. ⌘B to build. Xcode will fetch the Supabase Swift package automatically.
```

That's it. The bundle ID (`com.titanstack.mlbvaluebets`), deployment target
(iOS 17.0), SwiftUI previews, Supabase package dependency, asset catalog,
dark-mode lock, portrait-only, and iPhone-only device family are all
pre-configured in `project.yml`.

### Regenerating the project
If `MLBValueBets.xcodeproj` ever gets corrupted or out of sync after adding
files, just delete it and run `xcodegen generate` again. The `.xcodeproj` is
gitignored — the only source of truth is `project.yml` + the files under
`MLBValueBets/`.

### Setting your signing team
First build will fail with "Signing for 'MLBValueBets' requires a development
team." In Xcode, select the project → Signing & Capabilities → pick your team
from the dropdown. This lives in your local `.xcodeproj` and is **not**
committed.

## Configuration

Edit `MLBValueBets/Core/Utilities/Config.swift` if you need to point at a
different backend. The Supabase anon key there is **public** (same key used in
the web frontend) — it's safe to commit.

## Phase 1 scope (this repo)

- Email/password sign-in against Supabase
- Dashboard with live record strip + top picks
- Full picks list with market filter
- Pick detail with edge, EV, Kelly, sharp/pinnacle signals
- Locked cards for free-tier users (blurred, no upgrade link)
- Settings: account info, sign out, static "manage on mlbvaluebets.com" text

## Deferred to Phase 2+

In-app subscriptions (RevenueCat), push notifications, home-screen widget,
offline caching, deep linking, share sheet, Watch app.

## App Store compliance

This ships as a **Reader App** (Guideline 3.1.3(a)). Strict rules enforced in
code review:

- No "Subscribe" / "Upgrade" buttons anywhere
- No tappable links to payment pages
- No signup flow inside the app
- Pricing is only referenced via static text pointing users to the website
