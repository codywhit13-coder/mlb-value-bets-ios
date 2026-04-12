//
//  PicksViewModel.swift
//  MLBValueBets
//

import Foundation
import Observation

@Observable
@MainActor
final class PicksViewModel {

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
    var response: PicksResponse? = nil
    var selectedCategory: Category = .valueBets
    var selectedMarket: MarketFilter = .all
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false

    /// Formatted date for display — e.g. "FRIDAY, APR 11"
    var displayDate: String? {
        guard let dateStr = response?.date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateStr) else { return dateStr }
        let display = DateFormatter()
        display.dateFormat = "EEEE, MMM d"
        return display.string(from: date).uppercased()
    }

    private var allBets: [Pick] {
        response?.valueBets ?? []
    }

    /// Category counts (before market filter)
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

    // MARK: - Actions

    func load() async {
        // Show cached data immediately while the network request runs
        if response == nil,
           let cached = PicksCacheService.load(PicksResponse.self, forKey: PicksCacheService.todayPicksKey) {
            self.response = cached.data
            self.lastCachedAt = cached.cachedAt
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let fresh = try await PicksService.shared.fetchToday()
            self.response = fresh
            self.lastCachedAt = nil
            PicksCacheService.save(fresh, forKey: PicksCacheService.todayPicksKey)
        } catch {
            if let apiErr = error as? APIError, apiErr.isSessionExpired {
                self.isSessionExpired = true
                return
            }
            if self.response == nil {
                if let apiErr = error as? APIError {
                    self.errorMessage = apiErr.errorDescription
                } else {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func refresh() async { await load() }
}
