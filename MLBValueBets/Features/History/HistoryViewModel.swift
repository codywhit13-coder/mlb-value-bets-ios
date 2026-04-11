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

    // MARK: - Filters

    enum ConfidenceFilter: String, CaseIterable, Identifiable {
        case high   = "High"
        case medium = "Medium"
        case low    = "Low"

        var id: String { rawValue }

        var edgeRange: ClosedRange<Double> {
            switch self {
            case .high:   return 10...Double.infinity
            case .medium: return 7.5...9.999999
            case .low:    return 5...7.499999
            }
        }

        var subtitle: String {
            switch self {
            case .high:   return "≥10% Edge"
            case .medium: return "7.5–10%"
            case .low:    return "5–7.5%"
            }
        }

        func matches(_ pick: Pick) -> Bool {
            let edge = pick.edgePct ?? 0
            return edgeRange.contains(edge)
        }
    }

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var allPicks: [Pick] = []
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false
    var selectedConfidence: ConfidenceFilter = .high
    var selectedDate: String? = nil  // nil = auto-select most recent
    var isPro: Bool = false

    /// History depth: free = 7 days, pro = 90 days.
    private var historyDays: Int { isPro ? 90 : 7 }

    var historyRangeLabel: String { isPro ? "LAST 90 DAYS" : "LAST 7 DAYS" }

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

    /// Picks filtered by the active confidence tier.
    var filteredPicks: [Pick] {
        allPicks.filter { selectedConfidence.matches($0) }
    }

    // MARK: - Date navigation

    /// All unique dates that have picks (from ALL picks, independent of
    /// the confidence filter so date navigation stays stable).
    /// Sorted most-recent first.
    var availableDates: [String] {
        let dates = Set(allPicks.compactMap { pick -> String? in
            guard let gt = pick.gameTime, gt.count >= 10 else { return nil }
            return String(gt.prefix(10))
        })
        return dates.sorted(by: >)
    }

    /// The currently effective date — selected date if valid, otherwise most recent.
    var effectiveDate: String? {
        if let s = selectedDate, availableDates.contains(s) { return s }
        return availableDates.first
    }

    private var currentDateIndex: Int {
        guard let d = effectiveDate else { return 0 }
        return availableDates.firstIndex(of: d) ?? 0
    }

    var currentDateDisplay: String {
        guard let date = effectiveDate else { return "—" }
        return Self.formatSectionDate(date)
    }

    var canGoEarlier: Bool {
        currentDateIndex < availableDates.count - 1
    }

    var canGoLater: Bool {
        currentDateIndex > 0
    }

    func goToEarlierDate() {
        let idx = currentDateIndex
        if idx < availableDates.count - 1 {
            selectedDate = availableDates[idx + 1]
        }
    }

    func goToLaterDate() {
        let idx = currentDateIndex
        if idx > 0 {
            selectedDate = availableDates[idx - 1]
        }
    }

    /// Navigate to a calendar-picked date. Snaps to the nearest available
    /// date if the exact date has no picks.
    func selectDate(_ date: Date) {
        let str = Self.parseFormatter.string(from: date)
        if availableDates.contains(str) {
            selectedDate = str
        } else {
            selectedDate = availableDates.min(by: {
                guard let a = Self.parseFormatter.date(from: $0),
                      let b = Self.parseFormatter.date(from: $1) else { return false }
                return abs(a.timeIntervalSince(date)) < abs(b.timeIntervalSince(date))
            })
        }
    }

    var effectiveDateAsDate: Date? {
        guard let d = effectiveDate else { return nil }
        return Self.parseFormatter.date(from: d)
    }

    var calendarDateRange: ClosedRange<Date>? {
        guard let oldest = availableDates.last,
              let newest = availableDates.first,
              let minDate = Self.parseFormatter.date(from: oldest),
              let maxDate = Self.parseFormatter.date(from: newest) else { return nil }
        return minDate...maxDate
    }

    /// Picks for the selected date, filtered by confidence.
    var currentDatePicks: [Pick] {
        guard let date = effectiveDate else { return [] }
        return filteredPicks.filter { pick in
            guard let gt = pick.gameTime, gt.count >= 10 else { return false }
            return String(gt.prefix(10)) == date
        }
    }

    /// Section for the current date (nil when no picks match).
    var currentSection: DaySection? {
        guard let date = effectiveDate else { return nil }
        let picks = currentDatePicks
        guard !picks.isEmpty else { return nil }
        return DaySection(
            date: date,
            displayDate: Self.formatSectionDate(date),
            picks: picks
        )
    }

    var totalWins: Int { filteredPicks.filter { $0.isWin }.count }
    var totalLosses: Int { filteredPicks.filter { $0.isLoss }.count }
    var totalPushes: Int { filteredPicks.filter { $0.isPush }.count }

    var totalRecord: String {
        if totalPushes > 0 { return "\(totalWins)-\(totalLosses)-\(totalPushes)" }
        return "\(totalWins)-\(totalLosses)"
    }

    var totalWinRate: Double {
        let decisive = totalWins + totalLosses
        guard decisive > 0 else { return 0 }
        return Double(totalWins) / Double(decisive) * 100
    }

    /// Count of settled picks per confidence tier (for badge display).
    func count(for filter: ConfidenceFilter) -> Int {
        allPicks.filter { filter.matches($0) && $0.isSettled }.count
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
            let fresh = try await PicksService.shared.fetchHistory(days: historyDays)
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
