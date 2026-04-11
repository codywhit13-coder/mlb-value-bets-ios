//
//  Color+Theme.swift
//  MLBValueBets
//
//  Brand colors — canonical hex values from frontend/src/index.css.
//  Every color here must stay in sync with the web so the iOS app and
//  mlbvaluebets.com feel like the same product.
//
//  Web source of truth:
//    --navy-deep:   #060D1A
//    --navy-mid:    #0A1628
//    --navy-card:   #0D1F38
//    --navy-border: #162840
//    --navy-hover:  #1A2E4A
//    --blue:        #1E6FFF
//    --blue-dim:    #1558CC
//    --amber:       #F5A623
//    --amber-dim:   #C4841B
//    --green:       #22C55E
//    --red:         #EF4444
//

import SwiftUI

extension Color {

    // MARK: - Backgrounds (navy family)
    //
    // `brandBackground` is the deepest — the body fill behind everything.
    // `brandSurface` is one step up — card fills, elevated containers.
    // `brandSurfaceMid` sits between — used for section strips.
    // `brandBorder` is the thin hairline separating cards from the bg.
    // `brandHover` is a hover/press highlight, one step brighter than card.

    static let brandBackground  = Color(hex: 0x060D1A)   // --navy-deep
    static let brandSurfaceMid  = Color(hex: 0x0A1628)   // --navy-mid
    static let brandSurface     = Color(hex: 0x0D1F38)   // --navy-card
    static let brandBorder      = Color(hex: 0x162840)   // --navy-border
    static let brandHover       = Color(hex: 0x1A2E4A)   // --navy-hover

    // MARK: - Primary accent (blue)
    //
    // THIS IS THE MISSING PIECE. The web's "light source" in every radial
    // glow, its CTA color, its focus ring, its section-label overlines —
    // all brand-blue. The iOS app was previously navy + green + amber with
    // zero blue, which is why it looked flat.

    static let brandBlue      = Color(hex: 0x1E6FFF)   // --blue
    static let brandBlueDim   = Color(hex: 0x1558CC)   // --blue-dim
    static let brandBlueGlow  = Color(hex: 0x1E6FFF).opacity(0.18)  // --blue-glow

    // MARK: - Secondary accent (amber)
    //
    // Used for PRO tier badge, Sharp signal chip, bottom-right radial glow,
    // and as the "high confidence" marker on edge stats.

    static let brandAmber     = Color(hex: 0xF5A623)   // --amber
    static let brandAmberDim  = Color(hex: 0xC4841B)   // --amber-dim
    static let brandAmberGlow = Color(hex: 0xF5A623).opacity(0.15)  // --amber-glow

    // MARK: - Legacy alias
    //
    // `brandAccent` was the old name for "whatever green means now" when the
    // app had no blue. Keep as alias to winGreen so existing call sites
    // that reference `.brandAccent` still compile. New code should prefer
    // `.brandBlue` (for CTAs/active state) or `.winGreen` (for outcomes).

    static let brandAccent    = Color(hex: 0x22C55E)
    static let brandGold      = Color(hex: 0xD4AF37)   // Totals (O/U) market accent
    static let brandPurple    = Color(hex: 0xA855F7)   // Pinnacle confirms chip

    // MARK: - Outcomes

    static let winGreen  = Color(hex: 0x22C55E)        // --green
    static let lossRed   = Color(hex: 0xEF4444)        // --red
    static let pushGray  = Color.white.opacity(0.40)

    // MARK: - Tier badges

    static let freeBadge = Color.white.opacity(0.12)
    static let proBadge  = Color(hex: 0xF5A623)

    // MARK: - Text

    static let brandTextPrimary   = Color.white
    static let brandTextSecondary = Color.white.opacity(0.60)
    static let brandTextMuted     = Color.white.opacity(0.40)
    static let brandTextFaint     = Color.white.opacity(0.25)

    // MARK: - Helpers

    /// Edge color based on confidence tier, matching the web's PickCard.tsx:
    ///   high   → #22C55E (green)
    ///   medium → var(--amber) = #F5A623
    ///   low    → rgba(255,255,255,0.40)
    static func edgeColor(for tier: Pick.ConfidenceTier) -> Color {
        switch tier {
        case .high:   return .winGreen
        case .medium: return .brandAmber
        case .low:    return .brandTextMuted
        case .none:   return .brandTextMuted
        }
    }

    /// Outcome color for settled picks.
    static func outcomeColor(for outcome: String?) -> Color {
        switch outcome?.lowercased() {
        case "win":  return .winGreen
        case "loss": return .lossRed
        case "push": return .pushGray
        default:     return .brandTextSecondary
        }
    }

    // MARK: - Hex initializer
    //
    // Takes a 24-bit RGB integer literal (e.g. 0x1E6FFF) and returns an
    // sRGB Color. Using a single numeric literal keeps brand values visually
    // identical to CSS (#1E6FFF) without fighting with `Color(red:green:blue:)`
    // precision or guessing decimal conversions.

    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8)  & 0xFF) / 255.0
        let b = Double( hex        & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }
}
