//
//  Profile.swift
//  MLBValueBets
//
//  Subscription status for the currently signed-in user.
//  Returned by GET /api/billing/status.
//

import Foundation

struct BillingStatus: Codable {
    let subscriptionTier: String   // "free" | "pro"
    let isPro: Bool
}

/// Convenience struct assembled from Supabase Auth user + /api/billing/status.
struct UserProfile: Identifiable, Hashable {
    let id: String        // Supabase UUID
    let email: String
    let tier: Tier

    enum Tier: String, Codable {
        case free, pro

        var displayName: String {
            switch self {
            case .free: return "Free"
            case .pro:  return "Pro"
            }
        }
    }

    var isPro: Bool { tier == .pro }
}
