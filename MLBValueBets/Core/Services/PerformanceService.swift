//
//  PerformanceService.swift
//  MLBValueBets
//
//  Fetches /api/performance/* endpoints. All are public (no auth).
//

import Foundation

final class PerformanceService {
    static let shared = PerformanceService()
    private init() {}

    /// GET /api/performance/summary — backtest W/L/ROI by market (public).
    func fetchSummary() async throws -> PerformanceSummary {
        try await APIClient.shared.get(
            "/api/performance/summary",
            as: PerformanceSummary.self,
            authenticated: false
        )
    }

    /// GET /api/performance/live — season-to-date record (public).
    func fetchLive() async throws -> LivePerformance {
        try await APIClient.shared.get(
            "/api/performance/live",
            as: LivePerformance.self,
            authenticated: false
        )
    }

    /// GET /api/performance/clv — closing line value stats (public).
    func fetchCLV() async throws -> CLVReport {
        try await APIClient.shared.get(
            "/api/performance/clv",
            as: CLVReport.self,
            authenticated: false
        )
    }
}
