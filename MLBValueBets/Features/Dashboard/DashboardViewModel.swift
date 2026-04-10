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
    var lastCachedAt: Date? = nil
    var isSessionExpired: Bool = false

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
