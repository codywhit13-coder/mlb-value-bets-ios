//
//  PickModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for Pick computed properties: confidenceTier, isSettled,
//  isWin/isLoss/isPush, and id derivation. Pure logic — no simulator needed.
//

import XCTest
@testable import MLBValueBets

@MainActor
final class PickModelTests: XCTestCase {

    // MARK: - Helper

    /// Builds a minimal Pick with only the fields under test set.
    /// All other fields use safe defaults.
    private func makePick(
        game: String = "Team A @ Team B",
        market: String = "moneyline",
        side: String = "Team A",
        edgePct: Double? = nil,
        confidence: String? = nil,
        outcome: String? = nil
    ) -> Pick {
        Pick(
            game: game,
            market: market,
            side: side,
            modelProb: 0.55,
            impliedProb: 0.50,
            edgePct: edgePct,
            fairOdds: -120,
            bookOdds: 105,
            kellyFraction: 0.02,
            lineMove: nil,
            sharpSignal: false,
            crossBookSpread: nil,
            pinnacleEdge: nil,
            pinnacleConfirms: nil,
            confidence: confidence,
            book: nil,
            outcome: outcome,
            locked: false,
            valueBet: false,
            gameTime: nil,
            closingOdds: nil,
            clvPct: nil,
            evPct: nil,
            modelTotal: nil,
            lineupConfirmed: true
        )
    }

    // MARK: - ID derivation

    func test_id_format() {
        let pick = makePick(game: "NYY @ BOS", market: "moneyline", side: "NYY")
        XCTAssertEqual(pick.id, "NYY @ BOS|moneyline|NYY")
    }

    func test_id_uniqueness_differentMarkets() {
        let ml = makePick(market: "moneyline", side: "Team A")
        let rl = makePick(market: "runline", side: "Team A")
        XCTAssertNotEqual(ml.id, rl.id)
    }

    // MARK: - confidenceTier from confidence string

    func test_confidenceTier_high_fromString() {
        let pick = makePick(edgePct: 3.0, confidence: "high")
        XCTAssertEqual(pick.confidenceTier, .high)
    }

    func test_confidenceTier_medium_fromString() {
        let pick = makePick(edgePct: 3.0, confidence: "medium")
        XCTAssertEqual(pick.confidenceTier, .medium)
    }

    func test_confidenceTier_low_fromString() {
        let pick = makePick(edgePct: 3.0, confidence: "low")
        XCTAssertEqual(pick.confidenceTier, .low)
    }

    func test_confidenceTier_string_overridesEdge() {
        // confidence string says "low" but edge is 15% (would be "high" by edge alone)
        let pick = makePick(edgePct: 15.0, confidence: "low")
        XCTAssertEqual(pick.confidenceTier, .low, "String-based confidence should take precedence over edgePct")
    }

    func test_confidenceTier_unknownString_fallsThrough() {
        // An unrecognized confidence string should fall through to edgePct logic
        let pick = makePick(edgePct: 12.0, confidence: "very_high")
        XCTAssertEqual(pick.confidenceTier, .high, "Unknown string should fall through to edgePct-based tier")
    }

    // MARK: - confidenceTier from edgePct thresholds

    func test_confidenceTier_high_fromEdge_exactly10() {
        let pick = makePick(edgePct: 10.0)
        XCTAssertEqual(pick.confidenceTier, .high)
    }

    func test_confidenceTier_high_fromEdge_above10() {
        let pick = makePick(edgePct: 14.5)
        XCTAssertEqual(pick.confidenceTier, .high)
    }

    func test_confidenceTier_medium_fromEdge_exactly7_5() {
        let pick = makePick(edgePct: 7.5)
        XCTAssertEqual(pick.confidenceTier, .medium)
    }

    func test_confidenceTier_medium_fromEdge_between7_5_and_10() {
        let pick = makePick(edgePct: 9.9)
        XCTAssertEqual(pick.confidenceTier, .medium)
    }

    func test_confidenceTier_low_fromEdge_exactly5() {
        let pick = makePick(edgePct: 5.0)
        XCTAssertEqual(pick.confidenceTier, .low)
    }

    func test_confidenceTier_low_fromEdge_between5_and_7_5() {
        let pick = makePick(edgePct: 6.0)
        XCTAssertEqual(pick.confidenceTier, .low)
    }

    func test_confidenceTier_none_fromEdge_below5() {
        let pick = makePick(edgePct: 4.9)
        XCTAssertEqual(pick.confidenceTier, .none)
    }

    func test_confidenceTier_none_fromEdge_zero() {
        let pick = makePick(edgePct: 0.0)
        XCTAssertEqual(pick.confidenceTier, .none)
    }

    func test_confidenceTier_none_nilEdge_nilConfidence() {
        let pick = makePick(edgePct: nil, confidence: nil)
        XCTAssertEqual(pick.confidenceTier, .none)
    }

    // MARK: - isSettled / isWin / isLoss / isPush

    func test_isSettled_true_win() {
        let pick = makePick(outcome: "win")
        XCTAssertTrue(pick.isSettled)
        XCTAssertTrue(pick.isWin)
        XCTAssertFalse(pick.isLoss)
        XCTAssertFalse(pick.isPush)
    }

    func test_isSettled_true_loss() {
        let pick = makePick(outcome: "loss")
        XCTAssertTrue(pick.isSettled)
        XCTAssertFalse(pick.isWin)
        XCTAssertTrue(pick.isLoss)
        XCTAssertFalse(pick.isPush)
    }

    func test_isSettled_true_push() {
        let pick = makePick(outcome: "push")
        XCTAssertTrue(pick.isSettled)
        XCTAssertFalse(pick.isWin)
        XCTAssertFalse(pick.isLoss)
        XCTAssertTrue(pick.isPush)
    }

    func test_isSettled_false_nil() {
        let pick = makePick(outcome: nil)
        XCTAssertFalse(pick.isSettled)
        XCTAssertFalse(pick.isWin)
        XCTAssertFalse(pick.isLoss)
        XCTAssertFalse(pick.isPush)
    }

    // MARK: - Existing mock data sanity checks

    func test_mockHighEdge_isHighTier() {
        XCTAssertEqual(Pick.mockHighEdge.confidenceTier, .high)
        XCTAssertFalse(Pick.mockHighEdge.isSettled)
    }

    func test_mockMediumEdge_isMediumTier() {
        XCTAssertEqual(Pick.mockMediumEdge.confidenceTier, .medium)
    }

    func test_mockRunlineWin_isSettledWin() {
        XCTAssertTrue(Pick.mockRunlineWin.isSettled)
        XCTAssertTrue(Pick.mockRunlineWin.isWin)
    }

    func test_mockLocked_hasNoneTier() {
        XCTAssertEqual(Pick.mockLocked.confidenceTier, .none)
        XCTAssertTrue(Pick.mockLocked.locked)
    }

    func test_mockSettledLoss_isLoss() {
        XCTAssertTrue(Pick.mockSettledLoss.isLoss)
    }

    func test_mockSettledPush_isPush() {
        XCTAssertTrue(Pick.mockSettledPush.isPush)
    }
}
