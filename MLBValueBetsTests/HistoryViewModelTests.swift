//
//  HistoryViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for HistoryViewModel date grouping, section record display,
//  and totalRecord formatting. Pure logic — no network, no simulator needed.
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

    // MARK: - sections grouping

    func test_sections_groupsByDate() {
        vm.allPicks = .mockHistory  // 4 picks across 2 days
        XCTAssertEqual(vm.sections.count, 2, "4 picks across 2 dates should produce 2 sections")
    }

    func test_sections_sortedMostRecentFirst() {
        vm.allPicks = .mockHistory
        let sections = vm.sections
        XCTAssertGreaterThan(
            sections[0].date, sections[1].date,
            "First section should have a more recent date than the second"
        )
    }

    func test_sections_correctPickCountPerDay() {
        vm.allPicks = .mockHistory
        let sections = vm.sections

        // Apr 8: mockRunlineWin + mockSettledLoss = 2 picks
        let apr8 = sections.first { $0.date == "2026-04-08" }
        XCTAssertNotNil(apr8)
        XCTAssertEqual(apr8?.picks.count, 2)

        // Apr 7: mockSettledWinDay2 + mockSettledPush = 2 picks
        let apr7 = sections.first { $0.date == "2026-04-07" }
        XCTAssertNotNil(apr7)
        XCTAssertEqual(apr7?.picks.count, 2)
    }

    func test_sections_empty_returnsEmpty() {
        vm.allPicks = []
        XCTAssertTrue(vm.sections.isEmpty)
    }

    func test_sections_nilGameTime_groupedAsUnknown() {
        // A pick with nil gameTime should group under "Unknown"
        let noTimePick = Pick(
            game: "Team A @ Team B",
            market: "moneyline",
            side: "Team A",
            modelProb: 0.55,
            impliedProb: 0.50,
            edgePct: 6.0,
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
        let sections = vm.sections
        XCTAssertEqual(sections.count, 1)
        XCTAssertEqual(sections[0].date, "Unknown")
    }

    // MARK: - DaySection.displayRecord

    func test_daySection_displayRecord_withPushes() {
        vm.allPicks = .mockHistory
        // Apr 7 has 1W 0L 1P
        let apr7 = vm.sections.first { $0.date == "2026-04-07" }
        XCTAssertNotNil(apr7)
        XCTAssertEqual(apr7?.displayRecord, "1W 0L 1P")
    }

    func test_daySection_displayRecord_noPushes() {
        vm.allPicks = .mockHistory
        // Apr 8 has 1W 1L (no pushes)
        let apr8 = vm.sections.first { $0.date == "2026-04-08" }
        XCTAssertNotNil(apr8)
        XCTAssertEqual(apr8?.displayRecord, "1W 1L")
    }

    func test_daySection_winsLossesPushes_counts() {
        vm.allPicks = .mockHistory
        let apr8 = vm.sections.first { $0.date == "2026-04-08" }!
        XCTAssertEqual(apr8.wins, 1)
        XCTAssertEqual(apr8.losses, 1)
        XCTAssertEqual(apr8.pushes, 0)

        let apr7 = vm.sections.first { $0.date == "2026-04-07" }!
        XCTAssertEqual(apr7.wins, 1)
        XCTAssertEqual(apr7.losses, 0)
        XCTAssertEqual(apr7.pushes, 1)
    }

    // MARK: - totalRecord

    func test_totalRecord_withPushes() {
        vm.allPicks = .mockHistory  // 2W 1L 1P
        XCTAssertEqual(vm.totalRecord, "2-1-1")
    }

    func test_totalRecord_noPushes() {
        // Only picks with win/loss outcomes, no pushes
        vm.allPicks = [.mockRunlineWin, .mockSettledLoss]
        XCTAssertEqual(vm.totalRecord, "1-1")
    }

    func test_totalRecord_empty() {
        vm.allPicks = []
        XCTAssertEqual(vm.totalRecord, "0-0")
    }

    func test_totalRecord_allWins() {
        vm.allPicks = [.mockRunlineWin, .mockSettledWinDay2]
        XCTAssertEqual(vm.totalRecord, "2-0")
    }
}
