//
//  HistoryViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for HistoryViewModel confidence filtering, date navigation,
//  section records, and totalRecord formatting.
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

    // MARK: - Date navigation

    func test_availableDates_count() {
        vm.allPicks = .mockHistory
        // mockHistory has picks on 2026-04-07 and 2026-04-08
        XCTAssertEqual(vm.availableDates.count, 2)
    }

    func test_availableDates_sortedMostRecentFirst() {
        vm.allPicks = .mockHistory
        let dates = vm.availableDates
        XCTAssertGreaterThan(
            dates[0], dates[1],
            "First date should be more recent than the second"
        )
    }

    func test_effectiveDate_defaultsToMostRecent() {
        vm.allPicks = .mockHistory
        XCTAssertEqual(vm.effectiveDate, "2026-04-08")
    }

    func test_goToEarlierDate() {
        vm.allPicks = .mockHistory
        // Start at most recent (Apr 8)
        XCTAssertEqual(vm.effectiveDate, "2026-04-08")
        vm.goToEarlierDate()
        XCTAssertEqual(vm.effectiveDate, "2026-04-07")
    }

    func test_goToLaterDate() {
        vm.allPicks = .mockHistory
        vm.selectedDate = "2026-04-07"
        vm.goToLaterDate()
        XCTAssertEqual(vm.effectiveDate, "2026-04-08")
    }

    func test_canGoEarlier_atMostRecent() {
        vm.allPicks = .mockHistory
        XCTAssertTrue(vm.canGoEarlier, "Should be able to go earlier from most recent")
    }

    func test_canGoLater_atMostRecent() {
        vm.allPicks = .mockHistory
        XCTAssertFalse(vm.canGoLater, "Already at most recent date")
    }

    func test_canGoEarlier_atOldest() {
        vm.allPicks = .mockHistory
        vm.selectedDate = "2026-04-07"
        XCTAssertFalse(vm.canGoEarlier, "Already at oldest date")
    }

    func test_canGoLater_atOldest() {
        vm.allPicks = .mockHistory
        vm.selectedDate = "2026-04-07"
        XCTAssertTrue(vm.canGoLater, "Should be able to go later from oldest")
    }

    func test_availableDates_empty() {
        vm.allPicks = []
        XCTAssertTrue(vm.availableDates.isEmpty)
        XCTAssertNil(vm.effectiveDate)
    }

    // MARK: - currentSection (single-date view)

    func test_currentSection_correctPickCount_apr8() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        vm.selectedDate = "2026-04-08"
        // Apr 8: mockSettledLoss (5.4%) = 1 low pick
        XCTAssertNotNil(vm.currentSection)
        XCTAssertEqual(vm.currentSection?.picks.count, 1)
    }

    func test_currentSection_correctPickCount_apr7() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        vm.selectedDate = "2026-04-07"
        // Apr 7: mockSettledWinDay2 (7.0%) + mockSettledPush (5.6%) = 2 low picks
        XCTAssertNotNil(vm.currentSection)
        XCTAssertEqual(vm.currentSection?.picks.count, 2)
    }

    func test_currentSection_nil_whenEmpty() {
        vm.allPicks = []
        XCTAssertNil(vm.currentSection)
    }

    func test_currentSection_nil_whenNoConfidenceMatch() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .high
        vm.selectedDate = "2026-04-07"
        // Apr 7 has no high-confidence picks (only low picks on that date)
        XCTAssertNil(vm.currentSection)
    }

    // MARK: - DaySection.displayRecord

    func test_daySection_displayRecord_withPushes() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        vm.selectedDate = "2026-04-07"
        // Apr 7 has 1W 0L 1P (low picks only)
        XCTAssertEqual(vm.currentSection?.displayRecord, "1W 0L 1P")
    }

    func test_daySection_displayRecord_noPushes() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low
        vm.selectedDate = "2026-04-08"
        // Apr 8 has 0W 1L (low picks only — just the loss)
        XCTAssertEqual(vm.currentSection?.displayRecord, "0W 1L")
    }

    func test_daySection_winsLossesPushes_counts() {
        vm.allPicks = .mockHistory
        vm.selectedConfidence = .low

        vm.selectedDate = "2026-04-08"
        let apr8 = vm.currentSection!
        XCTAssertEqual(apr8.wins, 0)
        XCTAssertEqual(apr8.losses, 1)
        XCTAssertEqual(apr8.pushes, 0)

        vm.selectedDate = "2026-04-07"
        let apr7 = vm.currentSection!
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
}
