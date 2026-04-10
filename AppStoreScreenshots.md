# App Store Screenshots — Value Bets

## Device Targets

| Device Class        | Resolution  | Required By |
|---------------------|-------------|-------------|
| iPhone 6.7"         | 1290 × 2796 | App Store (mandatory) |
| iPhone 6.5"         | 1284 × 2778 | App Store (mandatory) |
| iPhone 5.5"         | 1242 × 2208 | App Store (if supporting SE) |

Primary screenshots target **iPhone 15 Pro Max** (6.7") via snapshot tests.

---

## 6 Screenshots

### 1. Dashboard — Pro Tier Loaded
**Screen**: `DashboardView` with `.mockPro` response + `.mockRecord`
**Shows**: Hero title, PRO badge, live record strip (W-L, Win %, ROI), top 3 pick cards with edge colors, blue atmospheric glow
**Caption**: "Model-backed MLB picks, updated daily."

### 2. Pick Detail — High Edge
**Screen**: `PickDetailView` with `.mockHighEdge`
**Shows**: Full edge breakdown (EDGE, EV, fair odds, model prob, Kelly %, confidence), Sharp + Pinnacle signal rows, recommended bet panel with large odds display
**Caption**: "See the edge the market missed."

### 3. All Picks — Filter Bar
**Screen**: `PicksListView` with `.mockWideList`, `selectedMarket = .all`
**Shows**: Animated filter chips (All / Moneyline / Total / Run Line), scrollable pick card list mixing markets, team logos, sportsbook icons
**Caption**: "Filter by moneyline, totals, or run line."

### 4. History — Settled Picks
**Screen**: `HistoryView` with `.mockHistory`
**Shows**: "LAST 7 DAYS" summary header with total record, date-grouped sections with mini record strips, settled outcome badges (win green / loss red)
**Caption**: "Track every pick. Full transparency."

### 5. Dashboard — Free Tier
**Screen**: `DashboardView` with `.mockFree` response
**Shows**: FREE badge, mix of unlocked + locked pick cards (blurred PRO picks), tier distinction visible
**Caption**: "Start free — upgrade when you're ready."

### 6. Share Card
**Screen**: `SharePickView` with `.mockHighEdge`
**Shows**: Branded share card with VALUE BETS header, matchup, side + odds, stats strip, signal chips, "Download the app" CTA
**Caption**: "Share picks with friends."

---

## Implementation

All screenshots are generated via `AppStoreScreenshotTests.swift` using swift-snapshot-testing.

**Device config**: `.iPhone15ProMax` (6.7" — 1290x2796)

**How to run**:
1. Set `isRecording = true` in test setUp
2. Push to CI (GitHub Actions macOS runner)
3. Download `snapshot-pngs` artifact
4. Screenshots are in `MLBValueBetsTests/__Snapshots__/AppStoreScreenshotTests/`
5. Add device frame overlays using Apple's marketing resources or a tool like `fastlane frameit`

---

## Screenshot Text Overlay Guidelines

App Store screenshots benefit from short marketing text overlaid above each device frame. Suggested copy:

| # | Overlay Text |
|---|-------------|
| 1 | Find the bets the market got wrong |
| 2 | Edge, EV & Kelly — every stat that matters |
| 3 | Moneyline, totals & run line picks daily |
| 4 | Full transparency on every settled pick |
| 5 | Free tier included — no credit card needed |
| 6 | Share your favorite picks instantly |

---

## Notes
- All screenshots use `.preferredColorScheme(.dark)` — the app is dark-only
- Font rendering requires custom fonts registered via `FontLoader.registerCustomFonts()`
- Staggered animations are auto-disabled in test env (`StaggeredAppearance` detects `XCTestConfigurationFilePath`)
- Share card (screenshot 6) renders at 360pt width — may need upscaling for App Store requirements
