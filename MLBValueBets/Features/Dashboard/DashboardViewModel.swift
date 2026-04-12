//
//  DashboardViewModel.swift
//  MLBValueBets
//

import Foundation
import Observation

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - Filter enums

    enum Category: String, CaseIterable, Identifiable {
        case valueBets    = "Value Bets"
        case todaysPicks  = "Today's Picks"
        case preLineup    = "Pre-Lineup"
        var id: String { rawValue }
    }

    enum MarketFilter: String, CaseIterable, Identifiable {
        case all       = "All"
        case moneyline = "Moneyline"
        case total     = "Total"
        case runline   = "Run Line"
        var id: String { rawValue }
    }

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var todayResponse: PicksResponse? = nil
    var liveRecord: LivePerformance? = nil
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false
    var selectedCategory: Category = .valueBets
    var selectedMarket: MarketFilter = .all

    // MARK: - Derived

    private var allBets: [Pick] {
        todayResponse?.valueBets ?? []
    }

    /// Whether the current user is Pro
    var isPro: Bool {
        todayResponse?.isPro ?? false
    }

    /// Category counts (before market filter, so tabs always show totals)
    var valueBetCount: Int {
        allBets.filter { ($0.lineupConfirmed ?? true) && ($0.edgePct ?? 0) >= 10 }.count
    }

    var todaysPicksCount: Int {
        allBets.filter {
            ($0.lineupConfirmed ?? true) && ($0.edgePct ?? 0) >= 5 && ($0.edgePct ?? 0) < 10
        }.count
    }

    var preLineupCount: Int {
        allBets.filter { !($0.lineupConfirmed ?? true) }.count
    }

    /// Picks filtered by category + market
    var filteredPicks: [Pick] {
        let bets = allBets
        let edge = { (p: Pick) -> Double in p.edgePct ?? 0 }

        // Category filter
        let byCategory: [Pick]
        switch selectedCategory {
        case .valueBets:
            byCategory = bets.filter { ($0.lineupConfirmed ?? true) && edge($0) >= 10 }
        case .todaysPicks:
            byCategory = bets.filter { ($0.lineupConfirmed ?? true) && edge($0) >= 5 && edge($0) < 10 }
        case .preLineup:
            byCategory = bets.filter { !($0.lineupConfirmed ?? true) }
        }

        // Market filter
        switch selectedMarket {
        case .all:       return byCategory
        case .moneyline: return byCategory.filter { $0.market.lowercased().contains("moneyline") }
        case .total:     return byCategory.filter { $0.market.lowercased().contains("total") }
        case .runline:   return byCategory.filter {
            let m = $0.market.lowercased()
            return m.contains("run") || m.contains("spread")
        }
        }
    }

    /// Free user picks — show unlocked + up to 3 locked teasers (no category filtering)
    var freePicks: [Pick] {
        let bets = allBets
        let unlocked = bets.filter { !$0.locked }
        let locked = Array(bets.filter { $0.locked }.prefix(3))
        return unlocked + locked
    }

    /// Formatted date for display — e.g. "WEDNESDAY, APR 9"
    var displayDate: String? {
        guard let dateStr = todayResponse?.date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let display = DateFormatter()
        display.dateFormat = "EEEE, MMM d"
        return display.string(from: date).uppercased()
    }

    // MARK: - Actions

    func load() async {
        // 1. Show cached data immediately while the network request runs
        if todayResponse == nil,
           let cached = PicksCacheService.load(PicksResponse.self, forKey: PicksCacheService.todayPicksKey) {
            self.todayResponse = cached.data
            self.lastCachedAt = cached.cachedAt
        }
        if liveRecord == nil,
           let cached = PicksCacheService.load(LivePerformance.self, forKey: PicksCacheService.liveRecordKey) {
            self.liveRecord = cached.data
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // 2. Fetch fresh data from network
        async let picksTask = PicksService.shared.fetchToday()
        async let liveTask  = PerformanceService.shared.fetchLive()

        do {
            let fresh = try await picksTask
            self.todayResponse = fresh
            self.lastCachedAt = nil  // data is fresh, hide stale banner
            PicksCacheService.save(fresh, forKey: PicksCacheService.todayPicksKey)
        } catch {
            if let apiErr = error as? APIError, apiErr.isSessionExpired {
                self.isSessionExpired = true
                return
            }
            // If we have cached data, suppress the error (stale banner shows instead)
            if self.todayResponse == nil {
                if let apiErr = error as? APIError {
                    self.errorMessage = apiErr.errorDescription
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        }

        // Live record is non-fatal — show dashboard even if it fails
        if let live = try? await liveTask {
            self.liveRecord = live
            PicksCacheService.save(live, forKey: PicksCacheService.liveRecordKey)
        }
    }

    func refresh() async {
        await load()
    }
}
