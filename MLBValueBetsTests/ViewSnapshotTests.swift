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

final class ViewSnapshotTests: XCTestCase {

    override class func setUp() {
        super.setUp()
        // Force consistent rendering across local + CI runs.
        // If you want to regenerate all baselines, set this to .all temporarily.
        // SnapshotTesting.isRecording = true
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
}
