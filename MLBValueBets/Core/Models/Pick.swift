//
//  Pick.swift
//  MLBValueBets
//
//  Mirrors `BetCandidate` in web/models/schemas.py on the backend.
//  Decoded with `.convertFromSnakeCase` so Swift camelCase matches Python snake_case.
//

import Foundation

struct Pick: Codable, Identifiable, Hashable {

    // MARK: - Identity
    /// A client-side stable ID built from (game, market, side).
    /// The backend doesn't send a pick ID on this endpoint, so we derive one.
    var id: String { "\(game)|\(market)|\(side)" }

    // MARK: - Core fields
    let game: String           // "Milwaukee Brewers @ Boston Red Sox"
    let market: String         // "moneyline" | "total" | "runline"
    let side: String           // "Milwaukee Brewers" or "O 7.5" or "Colorado Rockies +1.5"

    let modelProb: Double
    let impliedProb: Double?
    let edgePct: Double?
    let fairOdds: Int
    let bookOdds: Int?
    let kellyFraction: Double

    // MARK: - Signals
    let lineMove: Int?
    let sharpSignal: Bool
    let crossBookSpread: Double?
    let pinnacleEdge: Double?
    let pinnacleConfirms: Bool?
    let confidence: String?    // "high" | "medium" | "low" | nil
    let book: String?          // "FanDuel", "BetMGM", etc.

    // MARK: - State
    let outcome: String?       // "win" | "loss" | "push" | nil
    let locked: Bool           // true = free-tier redacted
    let valueBet: Bool         // true = edge >= 10%
    let gameTime: String?      // ISO 8601 UTC
    let closingOdds: Int?
    let clvPct: Double?
    let evPct: Double?
    let breakEvenPct: Double?  // win % needed to break even at book odds (raw, pre-devig)
    let modelTotal: Double?    // Totals only: predicted run total
    let lineupConfirmed: Bool? // true = both lineups posted (nil defaults to true)

    // MARK: - Convenience

    /// Break-even win rate at these odds.
    /// Uses the stored field when available; otherwise computes from bookOdds
    /// (mirrors the web PickCard fallback formula).
    var breakEven: Double? {
        if let stored = breakEvenPct { return stored }
        guard let odds = bookOdds.map(Double.init) else { return nil }
        return odds < 0
            ? abs(odds) / (abs(odds) + 100) * 100
            : 100   / (odds      + 100) * 100
    }

    var isSettled: Bool { outcome != nil }
    var isWin: Bool { outcome == "win" }
    var isLoss: Bool { outcome == "loss" }
    var isPush: Bool { outcome == "push" }

    /// Confidence tier derived from raw edge (matches frontend logic).
    var confidenceTier: ConfidenceTier {
        if let c = confidence?.lowercased() {
            switch c {
            case "high":   return .high
            case "medium": return .medium
            case "low":    return .low
            default: break
            }
        }
        guard let e = edgePct else { return .none }
        if e >= 10 { return .high }
        if e >= 7.5 { return .medium }
        if e >= 5 { return .low }
        return .none
    }

    enum ConfidenceTier: String {
        case high, medium, low, none
    }
}
