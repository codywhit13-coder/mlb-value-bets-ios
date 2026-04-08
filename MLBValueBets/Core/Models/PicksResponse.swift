//
//  PicksResponse.swift
//  MLBValueBets
//
//  Mirrors `PicksResponse` in web/models/schemas.py.
//

import Foundation

struct PicksResponse: Codable {
    let date: String           // "2026-04-08"
    let generatedAt: String    // ISO 8601
    let valueBets: [Pick]
    let tier: String           // "free" | "pro"
    let totalBets: Int         // visible to this user
    let totalBetsAll: Int      // before gating
    let totalBets5Pct: Int     // edge >= 5%
    let gamesToday: Int

    var isPro: Bool { tier.lowercased() == "pro" }
    var hiddenCount: Int { max(0, totalBetsAll - totalBets) }
}
