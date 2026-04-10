//
//  BrandLookup.swift
//  MLBValueBets
//
//  Brand colors and icons for markets, sportsbooks, and MLB teams.
//  Used by PickCard to give each overline a distinct visual identity
//  instead of everything being uniform blue.
//

import SwiftUI

// MARK: - Market Colors

/// Each market type gets a distinct color so the eye can instantly
/// distinguish moneyline from total from runline in a list.
enum MarketBrand {
    static func color(for market: String) -> Color {
        switch market.lowercased() {
        case let m where m.contains("moneyline"):
            return Color.brandBlue
        case let m where m.contains("total"):
            return Color.brandAmber
        case let m where m.contains("run"), let m where m.contains("spread"):
            return Color.brandPurple
        default:
            return Color.brandBlue
        }
    }
}

// MARK: - Sportsbook Brand Colors + SF Symbols

/// Each major sportsbook gets its real brand color, an SF Symbol fallback,
/// and the asset catalog name for the bundled logo PNG.
struct BookBrand {
    let color: Color
    let icon: String        // SF Symbol fallback
    let assetName: String?  // Asset catalog image name (nil = use SF Symbol)

    static func brand(for bookName: String?) -> BookBrand {
        guard let name = bookName?.lowercased() else {
            return BookBrand(color: .brandTextSecondary, icon: "building.columns", assetName: nil)
        }
        switch name {
        case let n where n.contains("fanduel"):
            return BookBrand(
                color: Color(hex: 0x1493FF),
                icon: "diamond.fill",
                assetName: "fanduel"
            )
        case let n where n.contains("draftkings"):
            return BookBrand(
                color: Color(hex: 0x53D769),
                icon: "crown.fill",
                assetName: "draftkings"
            )
        case let n where n.contains("betmgm"):
            return BookBrand(
                color: Color(hex: 0xBFA053),
                icon: "star.fill",
                assetName: "betmgm"
            )
        case let n where n.contains("caesars"):
            return BookBrand(
                color: Color(hex: 0xC41230),
                icon: "laurel.leading",
                assetName: "caesars"
            )
        case let n where n.contains("pinnacle"):
            return BookBrand(
                color: Color(hex: 0x2D5F9A),
                icon: "triangle.fill",
                assetName: "pinnacle"
            )
        case let n where n.contains("pointsbet"):
            return BookBrand(
                color: Color(hex: 0xFF6B00),
                icon: "bolt.fill",
                assetName: "pointsbet"
            )
        case let n where n.contains("bet365"):
            return BookBrand(
                color: Color(hex: 0x027B5B),
                icon: "circle.fill",
                assetName: "bet365"
            )
        default:
            return BookBrand(color: .brandTextSecondary, icon: "building.columns", assetName: nil)
        }
    }
}

// MARK: - MLB Team Abbreviations + Colors

/// Maps full team names (as they appear in the `game` and `side` fields)
/// to their standard 2-3 letter abbreviation and primary brand color.
struct TeamBrand {
    let abbreviation: String
    let color: Color
    /// Asset catalog image name matching the Teams/ folder in Assets.xcassets.
    var assetName: String { abbreviation }

    /// Attempts to find a team brand by searching for the team city/name
    /// inside the given string (typically `pick.side`).
    static func brand(for teamString: String) -> TeamBrand? {
        let lower = teamString.lowercased()
        for (key, brand) in lookup {
            if lower.contains(key) {
                return brand
            }
        }
        return nil
    }

    // Lookup keyed by lowercase team name fragment → (abbreviation, primary color).
    // Colors are each team's primary brand color from their official guidelines.
    // Asset catalog images are stored as Teams/{abbreviation}.imageset/
    private static let lookup: [(String, TeamBrand)] = [
        // AL East
        ("yankees",      TeamBrand(abbreviation: "NYY", color: Color(hex: 0x003087))),
        ("red sox",      TeamBrand(abbreviation: "BOS", color: Color(hex: 0xBD3039))),
        ("blue jays",    TeamBrand(abbreviation: "TOR", color: Color(hex: 0x134A8E))),
        ("rays",         TeamBrand(abbreviation: "TB",  color: Color(hex: 0x092C5C))),
        ("orioles",      TeamBrand(abbreviation: "BAL", color: Color(hex: 0xDF4601))),
        // AL Central
        ("guardians",    TeamBrand(abbreviation: "CLE", color: Color(hex: 0x00385D))),
        ("twins",        TeamBrand(abbreviation: "MIN", color: Color(hex: 0x002B5C))),
        ("white sox",    TeamBrand(abbreviation: "CWS", color: Color(hex: 0x27251F))),
        ("royals",       TeamBrand(abbreviation: "KC",  color: Color(hex: 0x004687))),
        ("tigers",       TeamBrand(abbreviation: "DET", color: Color(hex: 0x0C2C56))),
        // AL West
        ("astros",       TeamBrand(abbreviation: "HOU", color: Color(hex: 0xEB6E1F))),
        ("rangers",      TeamBrand(abbreviation: "TEX", color: Color(hex: 0x003278))),
        ("mariners",     TeamBrand(abbreviation: "SEA", color: Color(hex: 0x0C2C56))),
        ("athletics",    TeamBrand(abbreviation: "OAK", color: Color(hex: 0x003831))),
        ("angels",       TeamBrand(abbreviation: "LAA", color: Color(hex: 0xBA0021))),
        // NL East
        ("braves",       TeamBrand(abbreviation: "ATL", color: Color(hex: 0xCE1141))),
        ("phillies",     TeamBrand(abbreviation: "PHI", color: Color(hex: 0xE81828))),
        ("mets",         TeamBrand(abbreviation: "NYM", color: Color(hex: 0x002D72))),
        ("marlins",      TeamBrand(abbreviation: "MIA", color: Color(hex: 0x00A3E0))),
        ("nationals",    TeamBrand(abbreviation: "WSH", color: Color(hex: 0xAB0003))),
        // NL Central
        ("brewers",      TeamBrand(abbreviation: "MIL", color: Color(hex: 0xFFC52F))),
        ("cubs",         TeamBrand(abbreviation: "CHC", color: Color(hex: 0x0E3386))),
        ("cardinals",    TeamBrand(abbreviation: "STL", color: Color(hex: 0xC41E3A))),
        ("reds",         TeamBrand(abbreviation: "CIN", color: Color(hex: 0xC6011F))),
        ("pirates",      TeamBrand(abbreviation: "PIT", color: Color(hex: 0x27251F))),
        // NL West
        ("dodgers",      TeamBrand(abbreviation: "LAD", color: Color(hex: 0x005A9C))),
        ("padres",       TeamBrand(abbreviation: "SD",  color: Color(hex: 0x2F241D))),
        ("giants",       TeamBrand(abbreviation: "SF",  color: Color(hex: 0xFD5A1E))),
        ("diamondbacks", TeamBrand(abbreviation: "ARI", color: Color(hex: 0xA71930))),
        ("rockies",      TeamBrand(abbreviation: "COL", color: Color(hex: 0x33006F))),
    ]
}
