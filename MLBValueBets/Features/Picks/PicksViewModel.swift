//
//  PicksViewModel.swift
//  MLBValueBets
//

import Foundation
import Observation

@Observable
@MainActor
final class PicksViewModel {

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var response: PicksResponse? = nil
    var selectedMarket: MarketFilter = .all
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false

    // MARK: - Filter

    enum MarketFilter: String, CaseIterable, Identifiable {
        case all       = "All"
        case moneyline = "Moneyline"
        case total     = "Total"
        case runline   = "Run Line"
        var id: String { rawValue }
    }

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

    var filteredPicks: [Pick] {
        guard let bets = response?.valueBets else { return [] }
        switch selectedMarket {
        case .all:       return bets
        case .moneyline: return bets.filter { $0.market.lowercased().contains("moneyline") }
        case .total:     return bets.filter { $0.market.lowercased().contains("total") }
        case .runline:   return bets.filter {
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
