//
//  AppReviewService.swift
//  MLBValueBets
//
//  Requests an App Store review prompt after the user has opened the app
//  a meaningful number of times. Uses SKStoreReviewController which is
//  rate-limited by Apple (max 3 prompts per 365-day period).
//
//  Policy:
//    - First prompt after 5th app-open (user has seen the value by then)
//    - Track app opens via @AppStorage counter
//    - Only request once per version — reset counter on version change
//    - Never prompt during onboarding or on error screens
//

import StoreKit
import SwiftUI

@MainActor
enum AppReviewService {

    private static let appOpenCountKey = "appReview.openCount"
    private static let lastPromptedVersionKey = "appReview.lastVersion"

    /// Threshold: prompt after this many app opens.
    private static let promptThreshold = 5

    /// Call from DashboardView `.task` on each successful load.
    /// Increments the open counter and requests review if threshold is met.
    static func recordAppOpen() {
        let defaults = UserDefaults.standard
        let count = defaults.integer(forKey: appOpenCountKey) + 1
        defaults.set(count, forKey: appOpenCountKey)

        guard count >= promptThreshold else { return }

        // Only prompt once per app version
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
        let lastVersion = defaults.string(forKey: lastPromptedVersionKey)

        guard lastVersion != currentVersion else { return }

        // Request review via the modern scene-based API
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene }).first {
            SKStoreReviewController.requestReview(in: windowScene)
            defaults.set(currentVersion, forKey: lastPromptedVersionKey)
        }
    }

    /// Resets the open counter. Useful for testing.
    static func resetCounter() {
        UserDefaults.standard.removeObject(forKey: appOpenCountKey)
        UserDefaults.standard.removeObject(forKey: lastPromptedVersionKey)
    }
}
