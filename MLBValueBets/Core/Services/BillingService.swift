//
//  BillingService.swift
//  MLBValueBets
//
//  Read-only billing status fetcher.
//  This app is a "Reader App" — no checkout or upgrade is triggered from iOS.
//  Users upgrade on mlbvaluebets.com; the app only reads their current tier.
//

import Foundation

final class BillingService {
    static let shared = BillingService()
    private init() {}

    /// GET /api/billing/status — current subscription tier for signed-in user.
    func fetchStatus() async throws -> BillingStatus {
        try await APIClient.shared.get("/api/billing/status", as: BillingStatus.self)
    }
}
