//
//  MockData.swift
//  MLBValueBetsTests
//
//  Hand-crafted Pick fixtures exercising each visual state:
//  high/medium edge, unlocked/locked, upcoming/settled, with/without signals.
//

import Foundation
@testable import MLBValueBets

extension Pick {

    /// High-edge unlocked pick with sharp + pinnacle signals. The "hero" case.
    static let mockHighEdge = Pick(
        game: "New York Yankees @ Boston Red Sox",
        market: "moneyline",
        side: "New York Yankees",
        modelProb: 0.604,
        impliedProb: 0.479,
        edgePct: 12.54,
        fairOdds: -153,
        bookOdds: 108,
        kellyFraction: 0.0424,
        lineMove: 7,
        sharpSignal: true,
        crossBookSpread: 12.5,
        pinnacleEdge: 2.1,
        pinnacleConfirms: true,
        confidence: "high",
        book: "FanDuel",
        outcome: nil,
        locked: false,
        valueBet: true,
        gameTime: "2026-04-09T23:05:00Z",
        closingOdds: nil,
        clvPct: nil,
        evPct: 6.18,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// Medium-edge totals pick, no sharp signal. The "common" case.
    static let mockMediumEdge = Pick(
        game: "Los Angeles Dodgers @ San Francisco Giants",
        market: "total",
        side: "O 8.5",
        modelProb: 0.538,
        impliedProb: 0.476,
        edgePct: 6.25,
        fairOdds: -117,
        bookOdds: 105,
        kellyFraction: 0.0125,
        lineMove: 2,
        sharpSignal: false,
        crossBookSpread: 5.0,
        pinnacleEdge: 0.8,
        pinnacleConfirms: false,
        confidence: "medium",
        book: "DraftKings",
        outcome: nil,
        locked: false,
        valueBet: false,
        gameTime: "2026-04-09T22:40:00Z",
        closingOdds: nil,
        clvPct: nil,
        evPct: 2.95,
        modelTotal: 9.1,
        lineupConfirmed: true
    )

    /// Settled winning runline pick. Exercises the outcome + CLV code path.
    static let mockRunlineWin = Pick(
        game: "Houston Astros @ Colorado Rockies",
        market: "runline",
        side: "Colorado Rockies +1.5",
        modelProb: 0.657,
        impliedProb: 0.571,
        edgePct: 8.63,
        fairOdds: -191,
        bookOdds: -135,
        kellyFraction: 0.0312,
        lineMove: 4,
        sharpSignal: true,
        crossBookSpread: 8.0,
        pinnacleEdge: 1.5,
        pinnacleConfirms: true,
        confidence: "high",
        book: "BetMGM",
        outcome: "win",
        locked: false,
        valueBet: true,
        gameTime: "2026-04-08T20:10:00Z",
        closingOdds: -128,
        clvPct: 2.73,
        evPct: 4.55,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// Second moneyline pick for free-tier dashboard (2 ML picks visible).
    static let mockMLSecond = Pick(
        game: "Houston Astros @ Texas Rangers",
        market: "moneyline",
        side: "Houston Astros",
        modelProb: 0.571,
        impliedProb: 0.503,
        edgePct: 6.8,
        fairOdds: -133,
        bookOdds: -101,
        kellyFraction: 0.022,
        lineMove: 4,
        sharpSignal: true,
        crossBookSpread: 7.0,
        pinnacleEdge: 1.0,
        pinnacleConfirms: false,
        confidence: "medium",
        book: "BetMGM",
        outcome: nil,
        locked: false,
        valueBet: false,
        gameTime: "2026-04-10T00:05:00Z",
        closingOdds: nil,
        clvPct: nil,
        evPct: 3.1,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// Free-tier locked pick. Detail fields are redacted/nil by the backend.
    static let mockLocked = Pick(
        game: "Philadelphia Phillies @ Atlanta Braves",
        market: "moneyline",
        side: "REDACTED",
        modelProb: 0.0,
        impliedProb: nil,
        edgePct: nil,
        fairOdds: 0,
        bookOdds: nil,
        kellyFraction: 0,
        lineMove: nil,
        sharpSignal: false,
        crossBookSpread: nil,
        pinnacleEdge: nil,
        pinnacleConfirms: nil,
        confidence: nil,
        book: nil,
        outcome: nil,
        locked: true,
        valueBet: false,
        gameTime: "2026-04-09T23:20:00Z",
        closingOdds: nil,
        clvPct: nil,
        evPct: nil,
        modelTotal: nil,
        lineupConfirmed: true
    )
}

extension LivePerformance {
    static let mockRecord = LivePerformance(
        wins: 127,
        losses: 94,
        pushes: 6,
        roi: 0.087,
        unitsProfit: 19.4,
        totalBets: 227,
        startDate: "2026-03-27",
        endDate: "2026-04-08"
    )
}

// MARK: - PicksResponse fixtures for full-screen tests

extension PicksResponse {

    /// Free-tier response — 4 picks from backend (2 ML unlocked + 1 total + 1 locked).
    /// Dashboard filters to top 2 ML picks only. Exercises the DashboardView
    /// tier badge, hidden count, and the free-tier moneyline-only restriction.
    static let mockFree = PicksResponse(
        date: "2026-04-09",
        generatedAt: "2026-04-09T10:30:00Z",
        valueBets: [
            .mockHighEdge,     // ML — shown on free dashboard
            .mockMLSecond,     // ML — shown on free dashboard
            .mockMediumEdge,   // Total — hidden on free dashboard
            .mockLocked        // Locked — hidden on free dashboard
        ],
        tier: "free",
        totalBets: 4,
        totalBetsAll: 8,
        totalBets5Pct: 2,
        gamesToday: 12
    )

    /// Pro-tier response — all picks visible, no locked placeholders.
    /// Exercises the "PRO" tier badge and the full unlocked list.
    static let mockPro = PicksResponse(
        date: "2026-04-09",
        generatedAt: "2026-04-09T10:30:00Z",
        valueBets: [
            .mockHighEdge,
            .mockMediumEdge,
            .mockRunlineWin
        ],
        tier: "pro",
        totalBets: 3,
        totalBetsAll: 3,
        totalBets5Pct: 2,
        gamesToday: 12
    )

    /// Wide list for PicksListView — 4 picks spanning all markets so the
    /// filter bar (All / Moneyline / Total / Run Line) is meaningful.
    static let mockWideList = PicksResponse(
        date: "2026-04-09",
        generatedAt: "2026-04-09T10:30:00Z",
        valueBets: [
            .mockHighEdge,     // moneyline, unlocked
            .mockMediumEdge,   // total, unlocked
            .mockRunlineWin,   // runline, settled win
            .mockLocked        // moneyline, locked
        ],
        tier: "free",
        totalBets: 4,
        totalBetsAll: 9,
        totalBets5Pct: 3,
        gamesToday: 12
    )

    /// Empty response — no picks today. Used by the empty-state snapshot
    /// tests on DashboardView and PicksListView.
    static let mockEmpty = PicksResponse(
        date: "2026-04-09",
        generatedAt: "2026-04-09T10:30:00Z",
        valueBets: [],
        tier: "free",
        totalBets: 0,
        totalBetsAll: 0,
        totalBets5Pct: 0,
        gamesToday: 0
    )
}

// MARK: - Settled picks for HistoryView

extension Pick {
    /// Settled loss — for history list diversity.
    static let mockSettledLoss = Pick(
        game: "Chicago Cubs @ Milwaukee Brewers",
        market: "moneyline",
        side: "Chicago Cubs",
        modelProb: 0.542,
        impliedProb: 0.488,
        edgePct: 5.4,
        fairOdds: -118,
        bookOdds: 105,
        kellyFraction: 0.018,
        lineMove: 3,
        sharpSignal: false,
        crossBookSpread: 6.0,
        pinnacleEdge: 0.5,
        pinnacleConfirms: false,
        confidence: "low",
        book: "DraftKings",
        outcome: "loss",
        locked: false,
        valueBet: false,
        gameTime: "2026-04-08T23:10:00Z",
        closingOdds: 110,
        clvPct: -1.2,
        evPct: 1.8,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// Settled push — for history list diversity.
    static let mockSettledPush = Pick(
        game: "San Diego Padres @ Arizona Diamondbacks",
        market: "runline",
        side: "Arizona Diamondbacks +1.5",
        modelProb: 0.612,
        impliedProb: 0.556,
        edgePct: 5.6,
        fairOdds: -158,
        bookOdds: -125,
        kellyFraction: 0.020,
        lineMove: 2,
        sharpSignal: false,
        crossBookSpread: 4.0,
        pinnacleEdge: 0.3,
        pinnacleConfirms: false,
        confidence: "medium",
        book: "FanDuel",
        outcome: "push",
        locked: false,
        valueBet: false,
        gameTime: "2026-04-07T01:40:00Z",
        closingOdds: -120,
        clvPct: 1.5,
        evPct: 2.2,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// High-confidence settled win for history filter testing.
    static let mockSettledHighConf = Pick(
        game: "Los Angeles Dodgers @ San Francisco Giants",
        market: "moneyline",
        side: "Los Angeles Dodgers",
        modelProb: 0.648,
        impliedProb: 0.535,
        edgePct: 11.3,
        fairOdds: -184,
        bookOdds: -115,
        kellyFraction: 0.038,
        lineMove: 6,
        sharpSignal: true,
        crossBookSpread: 12.0,
        pinnacleEdge: 2.1,
        pinnacleConfirms: true,
        confidence: "high",
        book: "FanDuel",
        outcome: "win",
        locked: false,
        valueBet: true,
        gameTime: "2026-04-08T02:10:00Z",
        closingOdds: -130,
        clvPct: 4.5,
        evPct: 5.8,
        modelTotal: nil,
        lineupConfirmed: true
    )

    /// Second win on a different day for multi-day grouping.
    static let mockSettledWinDay2 = Pick(
        game: "Tampa Bay Rays @ Baltimore Orioles",
        market: "moneyline",
        side: "Tampa Bay Rays",
        modelProb: 0.580,
        impliedProb: 0.510,
        edgePct: 7.0,
        fairOdds: -138,
        bookOdds: -104,
        kellyFraction: 0.025,
        lineMove: 5,
        sharpSignal: true,
        crossBookSpread: 9.0,
        pinnacleEdge: 1.2,
        pinnacleConfirms: true,
        confidence: "medium",
        book: "BetMGM",
        outcome: "win",
        locked: false,
        valueBet: true,
        gameTime: "2026-04-07T23:05:00Z",
        closingOdds: -110,
        clvPct: 2.1,
        evPct: 3.6,
        modelTotal: nil,
        lineupConfirmed: true
    )
}

/// Mock history arrays for snapshot tests
extension Array where Element == Pick {
    /// Three days of settled picks across all confidence tiers.
    static let mockHistory: [Pick] = [
        // Day 1: April 8 — 2W 1L (high + medium + low)
        .mockSettledHighConf,  // 11.3% edge → high, win
        .mockRunlineWin,       // 8.63% edge → medium, win
        .mockSettledLoss,      // 5.4% edge  → low, loss
        // Day 2: April 7 — 1W 1P
        .mockSettledWinDay2,   // 7.0% edge  → low, win
        .mockSettledPush,      // 5.6% edge  → low, push
    ]
}

// MARK: - UserProfile fixtures for SettingsView + tier badges

extension UserProfile {

    static let mockFree = UserProfile(
        id: "00000000-0000-0000-0000-000000000001",
        email: "free.user@example.com",
        tier: .free
    )

    static let mockPro = UserProfile(
        id: "00000000-0000-0000-0000-000000000002",
        email: "pro.user@example.com",
        tier: .pro
    )
}
