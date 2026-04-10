//
//  HistoryViewModel.swift
//  MLBValueBets
//
//  Fetches settled picks from /api/picks/history and groups them by
//  game date for the History tab.
//

import Foundation
import Observation

@Observable
@MainActor
final class HistoryViewModel {

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var allPicks: [Pick] = []

    // MARK: - Grouped by date

    /// A single day's section header data + picks.
    struct DaySection: Identifiable {
        let date: String       // "2026-04-08"
        let displayDate: String // "Tue, Apr 8"
        let picks: [Pick]
        var id: String { date }

        var wins: Int   { picks.filter { $0.isWin }.count }
        var losses: Int { picks.filter { $0.isLoss }.count }
        var pushes: Int { picks.filter { $0.isPush }.count }

        var displayRecord: String {
            if pushes > 0 { return "\(wins)W \(losses)L \(pushes)P" }
            return "\(wins)W \(losses)L"
        }

        /// Units profit for the day (1u flat bet model).
        var unitsProfit: Double {
            picks.reduce(0.0) { total, pick in
                guard let outcome = pick.outcome?.lowercased() else { return total }
                switch outcome {
                case "win":
                    // Positive odds: profit = odds/100. Negative: profit = 100/|odds|.
                    if let odds = pick.bookOdds {
                        if odds > 0 {
                            return total + Double(odds) / 100.0
                        } else {
                            return total + 100.0 / Double(abs(odds))
                        }
                    }
                    return total + 1.0  // Fallback to even money
                case "loss":
                    return total - 1.0
                default:
                    return total  // push = 0
                }
            }
        }
    }

    var sections: [DaySection] {
        let grouped = Dictionary(grouping: allPicks) { pick -> String in
            // Extract YYYY-MM-DD from gameTime, or "Unknown"
            guard let gt = pick.gameTime, gt.count >= 10 else { return "Unknown" }
            return String(gt.prefix(10))
        }

        return grouped
            .map { (dateStr, picks) in
                DaySection(
                    date: dateStr,
                    displayDate: Self.formatSectionDate(dateStr),
                    picks: picks
                )
            }
            .sorted { $0.date > $1.date }  // Most recent first
    }

    var totalRecord: String {
        let w = allPicks.filter { $0.isWin }.count
        let l = allPicks.filter { $0.isLoss }.count
        let p = allPicks.filter { $0.isPush }.count
        if p > 0 { return "\(w)-\(l)-\(p)" }
        return "\(w)-\(l)"
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            self.allPicks = try await PicksService.shared.fetchHistory(days: 7)
        } catch let err as APIError {
            self.errorMessage = err.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func refresh() async { await load() }

    // MARK: - Helpers

    private static let sectionFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM d"
        f.timeZone = TimeZone(identifier: "America/Chicago")
        return f
    }()

    private static let parseFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "America/Chicago")
        return f
    }()

    private static func formatSectionDate(_ isoDate: String) -> String {
        guard let date = parseFormatter.date(from: isoDate) else { return isoDate }
        return sectionFormatter.string(from: date)
    }
}
