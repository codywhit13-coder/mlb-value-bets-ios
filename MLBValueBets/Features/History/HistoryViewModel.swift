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
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false

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
        // Show cached data immediately while the network request runs
        if allPicks.isEmpty,
           let cached = PicksCacheService.load([Pick].self, forKey: PicksCacheService.historyKey) {
            self.allPicks = cached.data
            self.lastCachedAt = cached.cachedAt
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fresh = try await PicksService.shared.fetchHistory(days: 7)
            self.allPicks = fresh
            self.lastCachedAt = nil
            PicksCacheService.save(fresh, forKey: PicksCacheService.historyKey)
        } catch {
            if let apiErr = error as? APIError, apiErr.isSessionExpired {
                self.isSessionExpired = true
                return
            }
            if self.allPicks.isEmpty {
                if let apiErr = error as? APIError {
                    self.errorMessage = apiErr.errorDescription
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
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
