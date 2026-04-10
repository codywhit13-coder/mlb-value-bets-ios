//
//  SharePickService.swift
//  MLBValueBets
//
//  Renders a SharePickView to a UIImage and presents the system share sheet.
//  Uses ImageRenderer (iOS 16+) for offscreen rendering.
//
//  Usage from PickDetailView:
//      Button { SharePickService.share(pick) } label: { ... }
//

import SwiftUI
import UIKit

@MainActor
enum SharePickService {

    /// Renders the pick as a branded PNG and presents UIActivityViewController.
    static func share(_ pick: Pick) {
        guard let image = renderImage(for: pick) else { return }

        let shareText = shareCaption(for: pick)
        let items: [Any] = [image, shareText]

        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )

        // Exclude low-value activity types
        activityVC.excludedActivityTypes = [
            .addToReadingList,
            .assignToContact,
            .openInIBooks,
            .print,
        ]

        // Present from the top-most view controller
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first,
              let rootVC = windowScene.windows.first?.rootViewController else {
            return
        }

        // Walk to the top-most presented VC
        var presenter = rootVC
        while let next = presenter.presentedViewController {
            presenter = next
        }

        // iPad popover anchor (required to avoid crash)
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX,
                y: presenter.view.bounds.midY,
                width: 0, height: 0
            )
            popover.permittedArrowDirections = []
        }

        presenter.present(activityVC, animated: true)
    }

    // MARK: - Image rendering

    /// Renders SharePickView at 2x scale for retina-quality PNG output.
    private static func renderImage(for pick: Pick) -> UIImage? {
        let view = SharePickView(pick: pick)
            .frame(width: SharePickView.renderWidth)

        let renderer = ImageRenderer(content: view)
        renderer.scale = UIScreen.main.scale
        renderer.proposedSize = ProposedViewSize(
            width: SharePickView.renderWidth,
            height: nil
        )

        return renderer.uiImage
    }

    // MARK: - Share text

    /// Plain-text caption accompanying the shared image.
    private static func shareCaption(for pick: Pick) -> String {
        var parts: [String] = []

        // Matchup
        parts.append(pick.game)

        // The pick itself
        let odds = pick.bookOdds.map(formatOdds) ?? ""
        parts.append("\(pick.side) \(odds)".trimmingCharacters(in: .whitespaces))

        // Edge stat if available
        if let edge = pick.edgePct {
            parts.append(String(format: "+%.1f%% edge", edge))
        }

        // Attribution
        parts.append("via Value Bets — mlbvaluebets.com")

        return parts.joined(separator: "\n")
    }

    private static func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }
}
