//
//  AccessibilityHelpers.swift
//  MLBValueBets
//
//  Centralized VoiceOver helpers that generate meaningful accessibility
//  labels from Pick model data. Keeps accessibility logic in one place
//  so PickCard, PickDetailView, and SharePickView all read identically.
//

import SwiftUI

// MARK: - Pick accessibility

extension Pick {

    /// Full VoiceOver description for a pick card.
    /// Example: "New York Yankees moneyline, plus 108 on FanDuel.
    ///           Edge 12.5%, EV 6.2%, high confidence. Sharp signal, Pinnacle confirms."
    var accessibilityLabel: String {
        var parts: [String] = []

        // Core pick
        parts.append("\(side) \(market)")

        // Odds
        if let odds = bookOdds {
            parts.append(odds > 0 ? "plus \(odds)" : "minus \(abs(odds))")
        }

        // Book
        if let book = book {
            parts.append("on \(book)")
        }

        // Stats
        if let edge = edgePct {
            parts.append(String(format: "Edge %.1f percent", edge))
        }
        if let ev = evPct {
            parts.append(String(format: "EV %.1f percent", ev))
        }

        // Confidence
        let tier = confidenceTier
        if tier != .none {
            parts.append("\(tier.rawValue) confidence")
        }

        // Signals
        if sharpSignal {
            parts.append("Sharp line move")
        }
        if pinnacleConfirms == true {
            parts.append("Pinnacle confirms")
        }

        // Outcome
        if let outcome = outcome {
            parts.append("Result: \(outcome)")
        }

        return parts.joined(separator: ", ")
    }

    /// Short VoiceOver hint for navigation context.
    var accessibilityHint: String {
        if isSettled {
            return "Double tap to view settled pick details"
        }
        return "Double tap to view pick details"
    }
}

// MARK: - Live record accessibility

extension LivePerformance {
    /// VoiceOver label for the record strip.
    var accessibilityLabel: String {
        var parts: [String] = []
        parts.append("Season record: \(wins) wins, \(losses) losses")
        if pushes > 0 {
            parts.append("\(pushes) pushes")
        }
        parts.append(String(format: "Win rate %.0f percent", winRate * 100))
        if let roi = roi {
            parts.append(String(format: "ROI %+.1f percent", roi * 100))
        }
        return parts.joined(separator: ", ")
    }
}
