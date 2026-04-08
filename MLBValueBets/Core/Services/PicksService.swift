//
//  PicksService.swift
//  MLBValueBets
//
//  Fetches picks from the Render-hosted backend.
//

import Foundation

final class PicksService {
    static let shared = PicksService()
    private init() {}

    /// GET /api/picks/today — today's picks, gated server-side by tier.
    /// Returns full PicksResponse including tier metadata for the dashboard.
    func fetchToday() async throws -> PicksResponse {
        try await APIClient.shared.get("/api/picks/today", as: PicksResponse.self)
    }

    /// GET /api/picks/{YYYY-MM-DD} — picks for a specific date.
    func fetchPicks(forDate dateString: String) async throws -> PicksResponse {
        try await APIClient.shared.get("/api/picks/\(dateString)", as: PicksResponse.self)
    }

    /// GET /api/picks/history?days=N — settled historical picks.
    /// Free tier: backend caps at 7 days. Pro tier: up to 90 days.
    func fetchHistory(days: Int = 7) async throws -> [Pick] {
        try await APIClient.shared.get("/api/picks/history?days=\(days)", as: [Pick].self)
    }
}
