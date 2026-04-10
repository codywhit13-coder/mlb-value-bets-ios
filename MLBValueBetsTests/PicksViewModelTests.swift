//
//  PicksViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for PicksViewModel.filteredPicks — pure synchronous computed
//  property tests. No network, no simulator needed.
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

    // MARK: - .all filter

    func test_filteredPicks_all_returnsAllPicks() {
        vm.response = .mockWideList   // 4 picks: ML, total, runline, ML(locked)
        vm.selectedMarket = .all
        XCTAssertEqual(vm.filteredPicks.count, 4)
    }

    // MARK: - .moneyline filter

    func test_filteredPicks_moneyline_filtersCorrectly() {
        vm.response = .mockWideList
        vm.selectedMarket = .moneyline

        // mockHighEdge (moneyline) + mockLocked (moneyline) = 2
        XCTAssertEqual(vm.filteredPicks.count, 2)
        for pick in vm.filteredPicks {
            XCTAssertTrue(
                pick.market.lowercased().contains("moneyline"),
                "Expected moneyline market, got '\(pick.market)'"
            )
        }
    }

    // MARK: - .total filter

    func test_filteredPicks_total_filtersCorrectly() {
        vm.response = .mockWideList
        vm.selectedMarket = .total

        // mockMediumEdge (total) = 1
        XCTAssertEqual(vm.filteredPicks.count, 1)
        XCTAssertTrue(vm.filteredPicks[0].market.lowercased().contains("total"))
    }

    // MARK: - .runline filter

    func test_filteredPicks_runline_filtersCorrectly() {
        vm.response = .mockWideList
        vm.selectedMarket = .runline

        // mockRunlineWin (runline) = 1
        XCTAssertEqual(vm.filteredPicks.count, 1)
        let m = vm.filteredPicks[0].market.lowercased()
        XCTAssertTrue(
            m.contains("run") || m.contains("spread"),
            "Expected runline/spread market, got '\(m)'"
        )
    }

    // MARK: - Empty / nil response

    func test_filteredPicks_emptyResponse_returnsEmpty() {
        vm.response = .mockEmpty
        vm.selectedMarket = .all
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }

    func test_filteredPicks_nilResponse_returnsEmpty() {
        // response is nil by default
        XCTAssertNil(vm.response)
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }

    // MARK: - Filter switching

    func test_filteredPicks_switchingFilters_updatesResults() {
        vm.response = .mockWideList

        vm.selectedMarket = .all
        let allCount = vm.filteredPicks.count

        vm.selectedMarket = .moneyline
        let mlCount = vm.filteredPicks.count

        vm.selectedMarket = .total
        let totalCount = vm.filteredPicks.count

        vm.selectedMarket = .runline
        let runlineCount = vm.filteredPicks.count

        // Sum of individual filters should equal all
        // (except if a pick matches multiple filters — our data doesn't)
        XCTAssertEqual(mlCount + totalCount + runlineCount, allCount)
    }
}
