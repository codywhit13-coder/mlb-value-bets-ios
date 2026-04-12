//
//  DeepLinkRouter.swift
//  MLBValueBets
//
//  Parses incoming `valuebets://` URLs and resolves them into navigation
//  destinations. Used by push notifications to deep-link users directly
//  into specific views.
//
//  Supported routes:
//    valuebets://picks       → Dashboard tab (legacy, redirects)
//    valuebets://history     → History tab
//    valuebets://settings    → Settings tab
//    valuebets://dashboard   → Dashboard tab (default)
//
//  Phase 2 TODO:
//    valuebets://pick?game=NYY+vs+BOS&market=moneyline → specific pick detail
//

import Foundation

@MainActor
@Observable
final class DeepLinkRouter {

    /// The tab to switch to when a deep link arrives.
    var selectedTab: Tab = .dashboard

    enum Tab: String, CaseIterable {
        case dashboard
        case history
        case settings
    }

    /// Parses a URL and updates the selected tab.
    /// Returns `true` if the URL was handled.
    @discardableResult
    func handle(_ url: URL) -> Bool {
        guard url.scheme == "valuebets" else { return false }

        let host = url.host() ?? url.path()
        switch host {
        case "picks":
            selectedTab = .dashboard
        case "history":
            selectedTab = .history
        case "settings":
            selectedTab = .settings
        case "dashboard", "":
            selectedTab = .dashboard
        default:
            #if DEBUG
            print("[DeepLink] Unrecognized route: \(url.absoluteString)")
            #endif
            return false
        }

        #if DEBUG
        print("[DeepLink] Navigating to: \(selectedTab.rawValue)")
        #endif
        return true
    }
}
