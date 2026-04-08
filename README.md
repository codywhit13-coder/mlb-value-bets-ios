# MLB Value Bets — iOS

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

## Mac setup (one time)

1. Install Xcode 15+ from the Mac App Store.
2. Clone this repo:
   ```bash
   git clone https://github.com/<you>/mlb-value-bets-ios.git
   cd mlb-value-bets-ios
   ```
3. Open Xcode → **File → New → Project** → iOS → App:
   - Product Name: `MLBValueBets`
   - Bundle ID: `com.titanstack.mlbvaluebets`
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None
   - **Save into this repo folder** (next to the existing `MLBValueBets/` tree).
4. In Finder, delete the empty `MLBValueBets/` Xcode just created and drag the
   existing `MLBValueBets/` folder from the repo into the Xcode project
   navigator (choose **Create groups**, uncheck "Copy items if needed").
5. **File → Add Package Dependencies** → add:
   - `https://github.com/supabase/supabase-swift` (pick "Supabase" product)
6. Set the iOS deployment target to **17.0**.
7. Build ⌘B — should compile clean.
8. Run on the iPhone 15 Pro simulator.

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
