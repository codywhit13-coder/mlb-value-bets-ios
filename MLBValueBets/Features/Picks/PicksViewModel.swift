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

    // MARK: - Filter

    enum MarketFilter: String, CaseIterable, Identifiable {
        case all       = "All"
        case moneyline = "Moneyline"
        case total     = "Total"
        case runline   = "Run Line"
        var id: String { rawValue }
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
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            self.response = try await PicksService.shared.fetchToday()
        } catch let err as APIError {
            self.errorMessage = err.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    func refresh() async { await load() }
}
