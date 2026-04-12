//
//  DashboardViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for DashboardViewModel derived properties: filteredPicks,
//  category counts, and freePicks. Pure logic — no network, no simulator.
//

import XCTest
@testable import MLBValueBets

@MainActor
final class DashboardViewModelTests: XCTestCase {

    private var vm: DashboardViewModel!

    override func setUp() {
        super.setUp()
        vm = DashboardViewModel()
    }

    // MARK: - filteredPicks (category filtering)

    func test_filteredPicks_valueBets_defaultCategory() {
        vm.todayResponse = .mockPro
        // Default category is .valueBets → lineup confirmed + edge >= 10%
        // mockHighEdge: edge 12.54, confirmed → included
        // mockMediumEdge: edge 6.25, confirmed → excluded (edge < 10)
        // mockRunlineWin: edge 8.63, confirmed → excluded (edge < 10)
        XCTAssertEqual(vm.filteredPicks.count, 1)
        XCTAssertEqual(vm.filteredPicks.first?.id, Pick.mockHighEdge.id)
    }

    func test_filteredPicks_todaysPicks() {
        vm.todayResponse = .mockPro
        vm.selectedCategory = .todaysPicks
        // lineup confirmed + edge 5-10%
        // mockHighEdge: 12.54 → excluded (>= 10)
        // mockMediumEdge: 6.25 → included
        // mockRunlineWin: 8.63 → included
        XCTAssertEqual(vm.filteredPicks.count, 2)
    }

    func test_filteredPicks_emptyResponse() {
        vm.todayResponse = .mockEmpty
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }

    func test_filteredPicks_nilResponse() {
        XCTAssertNil(vm.todayResponse)
        XCTAssertTrue(vm.filteredPicks.isEmpty)
    }

    // MARK: - valueBetCount

    func test_valueBetCount_countsHighEdgeConfirmed() {
        vm.todayResponse = .mockPro
        // Only mockHighEdge has edge >= 10% + lineupConfirmed
        XCTAssertEqual(vm.valueBetCount, 1)
    }

    func test_valueBetCount_emptyResponse_returnsZero() {
        vm.todayResponse = .mockEmpty
        XCTAssertEqual(vm.valueBetCount, 0)
    }

    func test_valueBetCount_nilResponse_returnsZero() {
        XCTAssertNil(vm.todayResponse)
        XCTAssertEqual(vm.valueBetCount, 0)
    }

    // MARK: - liveRecord

    func test_liveRecord_nil_byDefault() {
        XCTAssertNil(vm.liveRecord)
    }

    func test_liveRecord_mockRecord_properties() {
        vm.liveRecord = .mockRecord
        XCTAssertEqual(vm.liveRecord?.wins, 127)
        XCTAssertEqual(vm.liveRecord?.losses, 94)
        XCTAssertEqual(vm.liveRecord?.pushes, 6)
    }

    // MARK: - Initial state

    func test_initialState_isClean() {
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
        XCTAssertNil(vm.todayResponse)
        XCTAssertNil(vm.liveRecord)
        XCTAssertTrue(vm.filteredPicks.isEmpty)
        XCTAssertEqual(vm.valueBetCount, 0)
    }
}
