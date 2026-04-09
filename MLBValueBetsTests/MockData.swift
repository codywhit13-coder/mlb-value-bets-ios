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
        modelTotal: nil
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
        modelTotal: 9.1
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
        modelTotal: nil
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
        modelTotal: nil
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
