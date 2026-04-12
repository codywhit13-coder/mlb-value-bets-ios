//
//  PicksViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for PicksViewModel.filteredPicks — category + market filtering.
//  Pure synchronous computed property tests. No network, no simulator needed.
//
//  Mock data reference (mockWideList):
//    mockHighEdge:   moneyline, edge 12.54%, confirmed → valueBets category
//    mockMediumEdge: total,     edge  6.25%, confirmed → todaysPicks category
//    mockRunlineWin: runline,   edge  8.63%, confirmed → todaysPicks category
//    mockLocked:     moneyline, edge  nil,   confirmed → no category (edge < 5)
//

import XCTest
@testable import MLBValueBets

@MainActor
final class PicksViewModelTests: XCTestCase {

    private var vm: PicksViewModel!

    override func setUp() {
        super.setUp()
        vm = PicksViewModel()
    }

    // MARK: - Category filtering

    func test_filteredPicks_valueBets_defaultCategory() {
        vm.response = .mockWideList
        vm.selectedMarket = .all
        // Default category is .valueBets → edge >= 10% + lineup confirmed
        // Only mockHighEdge qualifies (12.54%)
        XCTAssertEqual(vm.filteredPicks.count, 1)
        XCTAssertEqual(vm.filteredPicks.first?.market, "moneyline")
    }

    func test_filteredPicks_todaysPicks_category() {
        vm.response = .mockWideList
        vm.selectedCategory = .todaysPicks
        vm.selectedMarket = .all
        // edge 5–10% + confirmed: mockMediumEdge (6.25%) + mockRunlineWin (8.63%)
        XCTAssertEqual(vm.filteredPicks.count, 2)
    }

    func test_filteredPicks_preLineup_category() {
        vm.response = .mockWideList
        vm.selectedCategory = .preLineup
        vm.selectedMarket = .all
        // All mocks have lineupConfirmed=true → 0
        XCTAssertEqual(vm.filteredPicks.count, 0)
    }

    // MARK: - Category counts

    func test_valueBetCount() {
        vm.response = .mockWideList
        XCTAssertEqual(vm.valueBetCount, 1)
    }

    func test_todaysPicksCount() {
        vm.response = .mockWideList
        XCTAssertEqual(vm.todaysPicksCount, 2)
    }

    func test_preLineupCount() {
        vm.response = .mockWideList
        XCTAssertEqual(vm.preLineupCount, 0)
    }

    // MARK: - Market filter within todaysPicks (has multiple markets)

    func test_filteredPicks_todaysPicks_totalMarket() {
        vm.response = .mockWideList
        vm.selectedCategory = .todaysPicks
        vm.selectedMarket = .total
        // mockMediumEdge (total, 6.25%) = 1
        XCTAssertEqual(vm.filteredPicks.count, 1)
        XCTAssertTrue(vm.filteredPicks[0].market.lowercased().contains("total"))
    }

    func test_filteredPicks_todaysPicks_runlineMarket() {
        vm.response = .mockWideList
        vm.selectedCategory = .todaysPicks
        vm.selectedMarket = .runline
        // mockRunlineWin (runline, 8.63%) = 1
        XCTAssertEqual(vm.filteredPicks.count, 1)
        let m = vm.filteredPicks[0].market.lowercased()
        XCTAssertTrue(
            m.contains("run") || m.contains("spread"),
            "Expected runline/spread market, got '\(m)'"
        )
    }

    func test_filteredPicks_todaysPicks_moneylineMarket() {
        vm.response = .mockWideList
        vm.selectedCategory = .todaysPicks
        vm.selectedMarket = .moneyline
        // No today's picks are moneyline (mockHighEdge is edge>=10 → valueBets)
        XCTAssertEqual(vm.filteredPicks.count, 0)
    }

    // MARK: - Market filter sum equals all (within a category)

    func test_filteredPicks_marketFilterSum_equalsAll() {
        vm.response = .mockWideList
        vm.selectedCategory = .todaysPicks

        vm.selectedMarket = .all
        let allCount = vm.filteredPicks.count

        vm.selectedMarket = .moneyline
        let mlCount = vm.filteredPicks.count

        vm.selectedMarket = .total
        let totalCount = vm.filteredPicks.count

        vm.selectedMarket = .runline
        let runlineCount = vm.filteredPicks.count

        XCTAssertEqual(mlCount + totalCount + runlineCount, allCount)
    }

    // MARK: - Category switching

    func test_filteredPicks_switchingCategory_updatesResults() {
        vm.response = .mockWideList
        vm.selectedMarket = .all

        vm.selectedCategory = .valueBets
        XCTAssertEqual(vm.filteredPicks.count, 1)

        vm.selectedCategory = .todaysPicks
        XCTAssertEqual(vm.filteredPicks.count, 2)

        vm.selectedCategory = .preLineup
        XCTAssertEqual(vm.filteredPicks.count, 0)
    }

    // MARK: - Empty / nil response

    func test_filteredPicks_emptyResponse_returnsEmpty() {
        vm.response = .mockEmpty
        vm.selectedMarket = .all
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }

    func test_filteredPicks_nilResponse_returnsEmpty() {
        XCTAssertNil(vm.response)
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }
}
