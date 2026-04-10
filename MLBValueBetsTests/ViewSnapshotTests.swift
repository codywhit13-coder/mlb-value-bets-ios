//
//  ViewSnapshotTests.swift
//  MLBValueBetsTests
//
//  Renders each visual component in the iOS Simulator and saves a PNG to
//  __Snapshots__/ViewSnapshotTests/. On first CI run these tests "fail"
//  because no baselines exist yet — that's expected. The PNGs written during
//  that first run are uploaded as a GitHub Actions artifact, at which point
//  we can review them from Windows and commit the baselines.
//
//  Subsequent runs compare against committed baselines and fail loudly on
//  any visual regression.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MLBValueBets

@MainActor
final class ViewSnapshotTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        // The test bundle hosts MLBValueBets via TEST_HOST, but tests render
        // SwiftUI views directly without going through App.init — so we have
        // to register the bundled .ttf files ourselves before any
        // `Font.custom(...)` lookup runs. Idempotent.
        FontLoader.registerCustomFonts()

        // TEMPORARY: regenerate baselines in CI after the design system
        // overhaul. With this on, every test "fails" but writes the new PNG
        // to MLBValueBetsTests/__Snapshots__/, which the workflow's
        // "Upload snapshot PNGs" step then bundles into the artifact. We
        // download that, commit the PNGs, and flip this back to false.
        isRecording = true
    }

    // MARK: - PickCard

    func test_PickCard_highEdge_sharp_pinnacle() {
        let view = PickCard(pick: .mockHighEdge)
            .frame(width: 360)
            .padding(16)
            .background(Color.brandBackground)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .sizeThatFits
            )
        )
    }

    func test_PickCard_mediumEdge_totals() {
        let view = PickCard(pick: .mockMediumEdge)
            .frame(width: 360)
            .padding(16)
            .background(Color.brandBackground)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .sizeThatFits
            )
        )
    }

    func test_PickCard_settledWin_runline() {
        let view = PickCard(pick: .mockRunlineWin)
            .frame(width: 360)
            .padding(16)
            .background(Color.brandBackground)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .sizeThatFits
            )
        )
    }

    // MARK: - LockedPickCard

    func test_LockedPickCard() {
        let view = LockedPickCard(pick: .mockLocked)
            .frame(width: 360)
            .padding(16)
            .background(Color.brandBackground)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .sizeThatFits
            )
        )
    }

    // MARK: - PickDetailView (full screen, iPhone 13 Pro portrait)

    func test_PickDetailView_highEdge() {
        let view = NavigationStack {
            PickDetailView(pick: .mockHighEdge)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_PickDetailView_settledWin() {
        let view = NavigationStack {
            PickDetailView(pick: .mockRunlineWin)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_PickDetailView_mediumEdge() {
        let view = NavigationStack {
            PickDetailView(pick: .mockMediumEdge)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    // MARK: - LoginView (full screen, iPhone 13 Pro portrait)

    func test_LoginView_empty() {
        let vm = AuthViewModel()
        // Ensure a clean initial state regardless of any async session check.
        vm.email = ""
        vm.password = ""
        vm.errorMessage = nil
        vm.isWorking = false

        let view = LoginView(vm: vm)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_LoginView_errorState() {
        let vm = AuthViewModel()
        vm.email = "user@example.com"
        vm.password = "wrongpass"
        vm.errorMessage = AuthError.invalidCredentials.errorDescription
        vm.isWorking = false

        let view = LoginView(vm: vm)
            .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    // MARK: - DashboardView

    func test_DashboardView_freeTier_loaded() {
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
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_DashboardView_proTier_loaded() {
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
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    // MARK: - PicksListView

    func test_PicksListView_allFilter() {
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
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_PicksListView_totalsFilter() {
        let vm = PicksViewModel()
        vm.response = .mockWideList
        vm.selectedMarket = .total
        vm.isLoading = false

        let view = NavigationStack {
            PicksListView(vm: vm)
        }
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    // MARK: - SettingsView

    func test_SettingsView_freeTier() {
        let auth = AuthViewModel()
        auth.isSignedIn = true
        auth.currentUser = .mockFree

        let view = NavigationStack {
            SettingsView()
        }
        .environment(auth)
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }

    func test_SettingsView_proTier() {
        let auth = AuthViewModel()
        auth.isSignedIn = true
        auth.currentUser = .mockPro

        let view = NavigationStack {
            SettingsView()
        }
        .environment(auth)
        .preferredColorScheme(.dark)

        assertSnapshot(
            of: view,
            as: .image(
                perceptualPrecision: 0.95,
                layout: .device(config: .iPhone13Pro)
            )
        )
    }
}
