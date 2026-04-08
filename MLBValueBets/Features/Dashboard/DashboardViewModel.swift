//
//  DashboardViewModel.swift
//  MLBValueBets
//

import Foundation
import Observation

@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - State
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var todayResponse: PicksResponse? = nil
    var liveRecord: LivePerformance? = nil

    // MARK: - Derived

    var topPicks: [Pick] {
        guard let bets = todayResponse?.valueBets else { return [] }
        // Show first 3 non-locked picks on the dashboard
        return Array(bets.prefix(3))
    }

    var valueBetCount: Int {
        todayResponse?.valueBets.filter { $0.valueBet }.count ?? 0
    }

    // MARK: - Actions

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        async let picksTask = PicksService.shared.fetchToday()
        async let liveTask  = PerformanceService.shared.fetchLive()

        do {
            self.todayResponse = try await picksTask
        } catch let err as APIError {
            self.errorMessage = err.errorDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }

        // Live record is non-fatal — show dashboard even if it fails
        self.liveRecord = try? await liveTask
    }

    func refresh() async {
        await load()
    }
}
