//
//  DashboardViewModelTests.swift
//  MLBValueBetsTests
//
//  Unit tests for DashboardViewModel derived properties: topPicks and
//  valueBetCount. Pure logic — no network, no simulator needed.
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

    // MARK: - topPicks

    func test_topPicks_returnsFirst3() {
        vm.todayResponse = .mockWideList  // 4 picks
        XCTAssertEqual(vm.topPicks.count, 3, "topPicks should cap at 3 from a response with 4")
    }

    func test_topPicks_preservesOrder() {
        vm.todayResponse = .mockWideList
        let topIDs = vm.topPicks.map(\.id)
        let allIDs = PicksResponse.mockWideList.valueBets.prefix(3).map(\.id)
        XCTAssertEqual(topIDs, Array(allIDs), "topPicks should be the first 3 in response order")
    }

    func test_topPicks_fewerThan3_returnsAll() {
        // mockPro has 3 picks — should return all 3
        vm.todayResponse = .mockPro
        XCTAssertEqual(vm.topPicks.count, 3)
    }

    func test_topPicks_emptyResponse_returnsEmpty() {
        vm.todayResponse = .mockEmpty
        XCTAssertTrue(vm.topPicks.isEmpty)
    }

    func test_topPicks_nilResponse_returnsEmpty() {
        XCTAssertNil(vm.todayResponse)
        XCTAssertTrue(vm.topPicks.isEmpty)
    }

    // MARK: - valueBetCount

    func test_valueBetCount_countsOnlyValueBets() {
        vm.todayResponse = .mockWideList
        // mockHighEdge.valueBet = true, mockMediumEdge = false,
        // mockRunlineWin = true, mockLocked = false
        // → 2 value bets
        XCTAssertEqual(vm.valueBetCount, 2)
    }

    func test_valueBetCount_emptyResponse_returnsZero() {
        vm.todayResponse = .mockEmpty
        XCTAssertEqual(vm.valueBetCount, 0)
    }

    func test_valueBetCount_nilResponse_returnsZero() {
        XCTAssertNil(vm.todayResponse)
        XCTAssertEqual(vm.valueBetCount, 0)
    }

    func test_valueBetCount_proResponse() {
        vm.todayResponse = .mockPro
        // mockHighEdge.valueBet = true, mockMediumEdge = false,
        // mockRunlineWin = true → 2
        XCTAssertEqual(vm.valueBetCount, 2)
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
        XCTAssertTrue(vm.topPicks.isEmpty)
        XCTAssertEqual(vm.valueBetCount, 0)
    }
}
