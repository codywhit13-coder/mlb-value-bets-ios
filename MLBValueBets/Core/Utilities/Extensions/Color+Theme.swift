//
//  Color+Theme.swift
//  MLBValueBets
//
//  Brand colors matching the web frontend (frontend/src/config/constants.ts).
//

import SwiftUI

extension Color {
    // MARK: - Brand
    static let brandBackground = Color(red: 0.04, green: 0.05, blue: 0.08)    // near-black navy
    static let brandSurface    = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let brandBorder     = Color.white.opacity(0.10)

    // MARK: - Accents
    static let brandAccent = Color(red: 0.13, green: 0.77, blue: 0.37)  // green #22C55E (high edge)
    static let brandAmber  = Color(red: 0.98, green: 0.75, blue: 0.14)  // amber (medium edge, sharp signal)
    static let brandPurple = Color(red: 0.66, green: 0.33, blue: 0.97)  // #A855F7 (Pinnacle confirms)

    // MARK: - Outcomes
    static let winGreen  = Color(red: 0.13, green: 0.77, blue: 0.37)
    static let lossRed   = Color(red: 0.94, green: 0.27, blue: 0.27)
    static let pushGray  = Color.white.opacity(0.40)

    // MARK: - Tier badges
    static let freeBadge = Color.white.opacity(0.15)
    static let proBadge  = Color(red: 0.98, green: 0.75, blue: 0.14)

    // MARK: - Text
    static let brandTextPrimary   = Color.white
    static let brandTextSecondary = Color.white.opacity(0.60)
    static let brandTextMuted     = Color.white.opacity(0.40)

    // MARK: - Helpers

    /// Returns the edge color based on confidence tier, matching the web design.
    static func edgeColor(for tier: Pick.ConfidenceTier) -> Color {
        switch tier {
        case .high:   return .brandAccent
        case .medium: return .brandAmber
        case .low:    return .brandTextMuted
        case .none:   return .brandTextMuted
        }
    }

    /// Returns a color for a pick outcome (settled picks only).
    static func outcomeColor(for outcome: String?) -> Color {
        switch outcome?.lowercased() {
        case "win":  return .winGreen
        case "loss": return .lossRed
        case "push": return .pushGray
        default:     return .brandTextSecondary
        }
    }
}
