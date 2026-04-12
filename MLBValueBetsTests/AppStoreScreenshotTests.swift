//
//  AppStoreScreenshotTests.swift
//  MLBValueBetsTests
//
//  Generates 6.7" (iPhone 15 Pro Max) screenshots for the App Store listing.
//  Run with `isRecording = true` to capture PNGs, then download from CI
//  artifacts and add device frames for the final listing.
//
//  These tests are separate from ViewSnapshotTests because they use a larger
//  device config and are intended for marketing, not regression.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MLBValueBets

@MainActor
final class AppStoreScreenshotTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        FontLoader.registerCustomFonts()

        // Flip to true to capture screenshots in CI.
        // Download from the "snapshot-pngs" artifact.
        isRecording = false
    }

    // iPhone 15 Pro Max — 6.7" display (1290×2796 @ 3x = 430×932 pt)
    private var deviceConfig: ViewImageConfig {
        ViewImageConfig(
            safeArea: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
            size: CGSize(width: 430, height: 932),
            traits: UITraitCollection(traitsFrom: [
                UITraitCollection(userInterfaceStyle: .dark),
                UITraitCollection(displayScale: 3.0),
            ])
        )
    }

    // MARK: - 1. Dashboard Pro Loaded

    func test_screenshot_01_dashboard_pro() {
        let vm = DashboardViewModel()
        vm.todayResponse = .mockPro
        vm.liveRecord = .mockRecord
        vm.isLoading = false

        let auth = AuthViewModel()
        auth.isSignedIn = true
        auth.currentUser = .mockPro

        let view = DashboardView(vm: vm)
            .environment(auth)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: deviceConfig)
            )
        )
    }

    // MARK: - 2. Pick Detail High Edge

    func test_screenshot_02_pickDetail_highEdge() {
        let view = NavigationStack {
            PickDetailView(pick: .mockHighEdge)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: deviceConfig)
            )
        )
    }

    // MARK: - 3. All Picks — All Filter

    func test_screenshot_03_picksListView_allFilter() {
        let vm = PicksViewModel()
        vm.response = .mockWideList
        vm.selectedMarket = .all
        vm.isLoading = false

        let view = NavigationStack {
            PicksListView(vm: vm)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: deviceConfig)
            )
        )
    }

    // MARK: - 4. History Loaded

    func test_screenshot_04_historyView_loaded() {
        let vm = HistoryViewModel()
        vm.allPicks = .mockHistory
        vm.isLoading = false

        let view = NavigationStack {
            HistoryView(vm: vm)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: deviceConfig)
            )
        )
    }

    // MARK: - 5. Dashboard Free Tier

    func test_screenshot_05_dashboard_free() {
        let vm = DashboardViewModel()
        vm.todayResponse = .mockFree
        vm.liveRecord = .mockRecord
        vm.isLoading = false

        let auth = AuthViewModel()
        auth.isSignedIn = true
        auth.currentUser = .mockFree

        let view = DashboardView(vm: vm)
            .environment(auth)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: deviceConfig)
            )
        )
    }

}
