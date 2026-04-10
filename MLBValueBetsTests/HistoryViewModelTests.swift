//
//  HistoryViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for HistoryViewModel date grouping, section record display,
//  totalRecord formatting, and confidence filtering.
//

import XCTest
@testable import MLBValueBets

@MainActor
final class HistoryViewModelTests: XCTestCase {

    private var vm: HistoryViewModel!

    override func setUp() {
        super.setUp()
        vm = HistoryViewModel()
    }

    // MARK: - Confidence filter

    func test_filter_high_returnsOnlyHighEdge() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .high
        // Only mockSettledHighConf (11.3%) qualifies
        XCTAssertEqual(vm.filteredPicks.count, 1)
        XCTAssertEqual(vm.filteredPicks.first?.side, "Los Angeles Dodgers")
    }

    func test_filter_medium_returnsMediumEdge() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .medium
        // mockRunlineWin (8.63%) qualifies
        XCTAssertEqual(vm.filteredPicks.count, 1)
    }

    func test_filter_low_returnsLowEdge() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        // mockSettledLoss (5.4%), mockSettledWinDay2 (7.0%), mockSettledPush (5.6%)
        XCTAssertEqual(vm.filteredPicks.count, 3)
    }

    func test_count_perFilter() {
        vm.allPicks = .mockHistory
        XCTAssertEqual(vm.count(for: .high), 1)
        XCTAssertEqual(vm.count(for: .medium), 1)
        XCTAssertEqual(vm.count(for: .low), 3)
    }

    // MARK: - sections grouping (uses low filter for multi-day spread)

    func test_sections_groupsByDate() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low  // 3 picks across 2 days
        XCTAssertEqual(vm.sections.count, 2, "3 low picks across 2 dates should produce 2 sections")
    }

    func test_sections_sortedMostRecentFirst() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        let sections = vm.sections
        XCTAssertGreaterThan(
            sections[0].date, sections[1].date,
            "First section should have a more recent date than the second"
        )
    }

    func test_sections_correctPickCountPerDay() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low

        // Apr 8: mockSettledLoss (5.4%) = 1 low pick
        let apr8 = sections(for: "2026-04-08")
        XCTAssertNotNil(apr8)
        XCTAssertEqual(apr8?.picks.count, 1)

        // Apr 7: mockSettledWinDay2 (7.0%) + mockSettledPush (5.6%) = 2 low picks
        let apr7 = sections(for: "2026-04-07")
        XCTAssertNotNil(apr7)
        XCTAssertEqual(apr7?.picks.count, 2)
    }

    func test_sections_empty_returnsEmpty() {
        vm.allPicks = []
        XCTAssertTrue(vm.sections.isEmpty)
    }

    func test_sections_nilGameTime_groupedAsUnknown() {
        let noTimePick = Pick(
            game: "Team A @ Team B",
            market: "moneyline",
            side: "Team A",
            modelProb: 0.55,
            impliedProb: 0.50,
            edgePct: 12.0,
            fairOdds: -120,
            bookOdds: 105,
            kellyFraction: 0.02,
            lineMove: nil,
            sharpSignal: false,
            crossBookSpread: nil,
            pinnacleEdge: nil,
            pinnacleConfirms: nil,
            confidence: nil,
            book: nil,
            outcome: "win",
            locked: false,
            valueBet: false,
            gameTime: nil,
            closingOdds: nil,
            clvPct: nil,
            evPct: nil,
            modelTotal: nil
        )
        vm.allPicks = [noTimePick]
        vm.selectedConfidence = .high
        let sections = vm.sections
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].date, "Unknown")
    }

    // MARK: - DaySection.displayRecord

    func test_daySection_displayRecord_withPushes() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        // Apr 7 has 1W 0L 1P (low picks only)
        let apr7 = sections(for: "2026-04-07")
        XCTAssertNotNil(apr7)
        XCTAssertEqual(apr7?.displayRecord, "1W 0L 1P")
    }

    func test_daySection_displayRecord_noPushes() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        // Apr 8 has 0W 1L (low picks only — just the loss)
        let apr8 = sections(for: "2026-04-08")
        XCTAssertNotNil(apr8)
        XCTAssertEqual(apr8?.displayRecord, "0W 1L")
    }

    func test_daySection_winsLossesPushes_counts() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low

        let apr8 = sections(for: "2026-04-08")!
        XCTAssertEqual(apr8.wins, 0)
        XCTAssertEqual(apr8.losses, 1)
        XCTAssertEqual(apr8.pushes, 0)

        let apr7 = sections(for: "2026-04-07")!
        XCTAssertEqual(apr7.wins, 1)
        XCTAssertEqual(apr7.losses, 0)
        XCTAssertEqual(apr7.pushes, 1)
    }

    // MARK: - totalRecord

    func test_totalRecord_highFilter() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .high
        // 1 high pick: mockSettledHighConf (win)
        XCTAssertEqual(vm.totalRecord, "1-0")
    }

    func test_totalRecord_lowFilter_withPushes() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        // 3 low picks: 1W 1L 1P
        XCTAssertEqual(vm.totalRecord, "1-1-1")
    }

    func test_totalRecord_noPushes() {
        vm.allPicks = [.mockRunlineWin, .mockSettledLoss]
        vm.selectedConfidence = .medium
        // mockRunlineWin (8.63%) is medium, mockSettledLoss (5.4%) is low
        XCTAssertEqual(vm.totalRecord, "1-0")
    }

    func test_totalRecord_empty() {
        vm.allPicks = []
        XCTAssertEqual(vm.totalRecord, "0-0")
    }

    // MARK: - Helpers

    private func sections(for date: String) -> HistoryViewModel.DaySection? {
        vm.sections.first { $0.date == date }
    }
}
