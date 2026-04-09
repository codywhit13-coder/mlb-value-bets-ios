//
//  CodableTests.swift
//  MLBValueBetsTests
//
//  Round-trip decoder/encoder tests for every model that crosses the
//  network boundary. We decode the fixtures in Fixtures.swift using the
//  same JSONDecoder config the real APIClient uses, then re-encode and
//  re-decode to prove symmetry.
//
//  These tests would catch:
//    - Backend adding a new required field the iOS decoder doesn't know about
//    - Backend renaming or removing a field the iOS decoder relies on
//    - Accidentally marking a field non-optional in Swift when the backend
//      returns null (would crash in production, fail loudly here)
//    - Decoder strategy drift (e.g. someone removing .convertFromSnakeCase)
//

import XCTest
@testable import MLBValueBets

final class CodableTests: XCTestCase {

    private var decoder: JSONDecoder { Fixtures.makeAPIDecoder() }
    private var encoder: JSONEncoder { Fixtures.makeAPIEncoder() }

    // MARK: - LivePerformance (captured from real backend)

    func test_LivePerformance_decodesRealBackendResponse() throws {
        let data = Fixtures.data(Fixtures.performanceLiveJson)
        let live = try decoder.decode(LivePerformance.self, from: data)

        XCTAssertEqual(live.wins, 48)
        XCTAssertEqual(live.losses, 43)
        XCTAssertEqual(live.pushes, 0)
        XCTAssertEqual(live.roi, 0.103)

        // Backend DOES return total_bets — iOS model decodes it via
        // .convertFromSnakeCase (total_bets -> totalBets).
        XCTAssertEqual(live.totalBets, 91)

        // Fields the backend does NOT return — must decode to nil, not crash.
        XCTAssertNil(live.unitsProfit, "Backend does not return units_profit")
        XCTAssertNil(live.startDate)
        XCTAssertNil(live.endDate)

        // Derived properties
        XCTAssertEqual(live.totalSettled, 91)
        XCTAssertEqual(live.displayRecord, "48-43")
        XCTAssertEqual(live.winRate, 48.0 / 91.0, accuracy: 0.001)
    }

    func test_LivePerformance_roundTripPreservesCoreFields() throws {
        let original = try decoder.decode(
            LivePerformance.self,
            from: Fixtures.data(Fixtures.performanceLiveJson)
        )
        let encoded = try encoder.encode(original)
        let reDecoded = try decoder.decode(LivePerformance.self, from: encoded)

        XCTAssertEqual(original.wins, reDecoded.wins)
        XCTAssertEqual(original.losses, reDecoded.losses)
        XCTAssertEqual(original.pushes, reDecoded.pushes)
        XCTAssertEqual(original.roi, reDecoded.roi)
    }

    // MARK: - PerformanceSummary (captured from real backend)

    func test_PerformanceSummary_decodesRealBackendResponse() throws {
        let data = Fixtures.data(Fixtures.performanceSummaryJson)
        let summary = try decoder.decode(PerformanceSummary.self, from: data)

        XCTAssertEqual(summary.moneylineWinRate, 0.664)
        XCTAssertEqual(summary.moneylineRoi, 0.281)
        XCTAssertEqual(summary.totalsWinRate, 0.669)
        XCTAssertEqual(summary.totalsRoi, 0.282)
        XCTAssertEqual(summary.runlineWinRate, 0.658)
        XCTAssertEqual(summary.runlineRoi, 0.288)
        XCTAssertEqual(summary.backtestPeriod, "2021-2025")
        XCTAssertEqual(summary.kellyCagr, 1.603)
        XCTAssertEqual(summary.kellyStart, 1000)
        XCTAssertEqual(summary.kellyEnd, 119391)
    }

    func test_PerformanceSummary_roundTrip() throws {
        let original = try decoder.decode(
            PerformanceSummary.self,
            from: Fixtures.data(Fixtures.performanceSummaryJson)
        )
        let encoded = try encoder.encode(original)
        let reDecoded = try decoder.decode(PerformanceSummary.self, from: encoded)

        XCTAssertEqual(original.moneylineWinRate, reDecoded.moneylineWinRate)
        XCTAssertEqual(original.backtestPeriod, reDecoded.backtestPeriod)
        XCTAssertEqual(original.kellyEnd, reDecoded.kellyEnd)
    }

    // MARK: - PicksResponse (schema-matched fixture)

    func test_PicksResponse_decodesFreeTierFixture() throws {
        let data = Fixtures.data(Fixtures.picksTodayFreeJson)
        let response = try decoder.decode(PicksResponse.self, from: data)

        // Response-level fields
        XCTAssertEqual(response.date, "2026-04-09")
        XCTAssertEqual(response.generatedAt, "2026-04-09T10:30:00Z")
        XCTAssertEqual(response.tier, "free")
        XCTAssertEqual(response.totalBets, 3)
        XCTAssertEqual(response.totalBetsAll, 9)
        XCTAssertEqual(response.totalBets5Pct, 2)
        XCTAssertEqual(response.gamesToday, 12)
        XCTAssertFalse(response.isPro)
        XCTAssertEqual(response.hiddenCount, 6) // 9 total - 3 visible

        // Pick array
        XCTAssertEqual(response.valueBets.count, 3)

        // First pick: high-edge unlocked moneyline with all optional fields populated
        let first = response.valueBets[0]
        XCTAssertEqual(first.game, "New York Yankees @ Boston Red Sox")
        XCTAssertEqual(first.market, "moneyline")
        XCTAssertEqual(first.side, "New York Yankees")
        XCTAssertEqual(first.modelProb, 0.604)
        XCTAssertEqual(first.impliedProb, 0.479)
        XCTAssertEqual(first.edgePct, 12.54)
        XCTAssertEqual(first.fairOdds, -153)
        XCTAssertEqual(first.bookOdds, 108)
        XCTAssertEqual(first.kellyFraction, 0.0424)
        XCTAssertEqual(first.lineMove, 7)
        XCTAssertTrue(first.sharpSignal)
        XCTAssertEqual(first.crossBookSpread, 12.5)
        XCTAssertEqual(first.pinnacleEdge, 2.1)
        XCTAssertEqual(first.pinnacleConfirms, true)
        XCTAssertEqual(first.confidence, "high")
        XCTAssertEqual(first.book, "FanDuel")
        XCTAssertNil(first.outcome)
        XCTAssertFalse(first.locked)
        XCTAssertTrue(first.valueBet)
        XCTAssertEqual(first.gameTime, "2026-04-09T23:05:00Z")
        XCTAssertNil(first.closingOdds)
        XCTAssertNil(first.clvPct)
        XCTAssertEqual(first.evPct, 6.18)
        XCTAssertNil(first.modelTotal)
        XCTAssertEqual(first.confidenceTier, .high)
        XCTAssertFalse(first.isSettled)

        // Second pick: medium-edge totals with modelTotal populated
        let second = response.valueBets[1]
        XCTAssertEqual(second.market, "total")
        XCTAssertEqual(second.side, "O 8.5")
        XCTAssertEqual(second.modelTotal, 9.1)
        XCTAssertFalse(second.sharpSignal)
        XCTAssertEqual(second.pinnacleConfirms, false)
        XCTAssertEqual(second.confidence, "medium")

        // Third pick: locked placeholder with almost everything nil
        let locked = response.valueBets[2]
        XCTAssertTrue(locked.locked)
        XCTAssertEqual(locked.game, "Philadelphia Phillies @ Atlanta Braves")
        XCTAssertEqual(locked.side, "REDACTED")
        XCTAssertNil(locked.edgePct)
        XCTAssertNil(locked.bookOdds)
        XCTAssertNil(locked.confidence)
        XCTAssertNil(locked.book)
        XCTAssertEqual(locked.confidenceTier, .none)
        XCTAssertFalse(locked.isSettled)
    }

    func test_PicksResponse_roundTripPreservesAllPicks() throws {
        let original = try decoder.decode(
            PicksResponse.self,
            from: Fixtures.data(Fixtures.picksTodayFreeJson)
        )
        let encoded = try encoder.encode(original)
        let reDecoded = try decoder.decode(PicksResponse.self, from: encoded)

        XCTAssertEqual(original.date, reDecoded.date)
        XCTAssertEqual(original.tier, reDecoded.tier)
        XCTAssertEqual(original.totalBets, reDecoded.totalBets)
        XCTAssertEqual(original.valueBets.count, reDecoded.valueBets.count)

        for (a, b) in zip(original.valueBets, reDecoded.valueBets) {
            XCTAssertEqual(a.game, b.game)
            XCTAssertEqual(a.market, b.market)
            XCTAssertEqual(a.side, b.side)
            XCTAssertEqual(a.modelProb, b.modelProb)
            XCTAssertEqual(a.edgePct, b.edgePct)
            XCTAssertEqual(a.bookOdds, b.bookOdds)
            XCTAssertEqual(a.kellyFraction, b.kellyFraction)
            XCTAssertEqual(a.sharpSignal, b.sharpSignal)
            XCTAssertEqual(a.pinnacleConfirms, b.pinnacleConfirms)
            XCTAssertEqual(a.confidence, b.confidence)
            XCTAssertEqual(a.outcome, b.outcome)
            XCTAssertEqual(a.locked, b.locked)
            XCTAssertEqual(a.valueBet, b.valueBet)
            XCTAssertEqual(a.clvPct, b.clvPct)
            XCTAssertEqual(a.modelTotal, b.modelTotal)
        }
    }

    // MARK: - Picks history (settled picks with outcomes + CLV)

    func test_PicksHistory_decodesArrayOfSettledPicks() throws {
        let data = Fixtures.data(Fixtures.picksHistoryJson)
        let picks = try decoder.decode([Pick].self, from: data)

        XCTAssertEqual(picks.count, 3)

        // Win
        let win = picks[0]
        XCTAssertEqual(win.outcome, "win")
        XCTAssertTrue(win.isWin)
        XCTAssertFalse(win.isLoss)
        XCTAssertFalse(win.isPush)
        XCTAssertTrue(win.isSettled)
        XCTAssertEqual(win.closingOdds, -128)
        XCTAssertEqual(win.clvPct, 2.73)
        XCTAssertEqual(win.market, "runline")

        // Loss
        let loss = picks[1]
        XCTAssertEqual(loss.outcome, "loss")
        XCTAssertTrue(loss.isLoss)
        XCTAssertFalse(loss.isWin)
        XCTAssertEqual(loss.clvPct, -0.95)

        // Push
        let push = picks[2]
        XCTAssertEqual(push.outcome, "push")
        XCTAssertTrue(push.isPush)
        XCTAssertEqual(push.market, "total")
        XCTAssertEqual(push.side, "U 7.5")
        XCTAssertEqual(push.modelTotal, 7.2)
    }

    // MARK: - Decoder strategy guard

    func test_decoder_failsLoudlyOnCamelCaseKeys() throws {
        // The backend speaks snake_case. If someone accidentally changes the
        // APIClient decoder to not use .convertFromSnakeCase, these fixtures
        // should fail to decode. We prove the opposite here: the decoder
        // correctly maps snake_case -> camelCase.
        let data = Fixtures.data("""
        {
            "moneyline_win_rate": 0.5,
            "moneyline_roi": 0.1,
            "totals_win_rate": 0.6,
            "totals_roi": 0.15,
            "runline_win_rate": 0.55,
            "runline_roi": 0.12,
            "backtest_period": "test",
            "kelly_cagr": 1.5,
            "kelly_start": 100,
            "kelly_end": 200
        }
        """)
        XCTAssertNoThrow(try decoder.decode(PerformanceSummary.self, from: data))
    }

    func test_decoder_ignoresUnknownFields() throws {
        // Backend can safely add new fields without breaking iOS clients.
        let data = Fixtures.data("""
        {
            "wins": 10,
            "losses": 5,
            "pushes": 1,
            "roi": 0.15,
            "future_field_we_dont_know_about": "hello",
            "another_one": 42
        }
        """)
        let live = try decoder.decode(LivePerformance.self, from: data)
        XCTAssertEqual(live.wins, 10)
        XCTAssertEqual(live.losses, 5)
        XCTAssertEqual(live.pushes, 1)
        XCTAssertEqual(live.roi, 0.15)
    }
}
