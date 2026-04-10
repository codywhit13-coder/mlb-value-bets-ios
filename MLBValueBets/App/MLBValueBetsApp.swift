//
//  MLBValueBetsApp.swift
//  MLBValueBets
//
//  App entry point. Initializes the auth view model and routes between
//  LoginView (signed out) and the main TabView (signed in).
//

import SwiftUI
import UIKit

@main
struct MLBValueBetsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var auth = AuthViewModel()
    @State private var router = DeepLinkRouter()

    init() {
        // Register Bebas Neue / Barlow / IBM Plex Mono with Core Text before
        // any view tries to resolve `Font.custom(...)`. Idempotent — also
        // called from ViewSnapshotTests.setUp because the test bundle hosts
        // this app via TEST_HOST and may not run App.init in every scenario.
        FontLoader.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(router)
                .preferredColorScheme(.dark)
                .tint(Color.brandBlue)
                .onOpenURL { url in
                    router.handle(url)
                }
        }
    }
}

// MARK: - AppDelegate (APNs callbacks)

final class AppDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Task { @MainActor in
            PushNotificationService.shared
                .didRegisterForRemoteNotifications(deviceToken: deviceToken)
        }
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Task { @MainActor in
            PushNotificationService.shared
                .didFailToRegisterForRemoteNotifications(error: error)
        }
    }
}

private struct RootView: View {
    @Environment(AuthViewModel.self) private var auth
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        ZStack {
            if !hasSeenOnboarding {
                OnboardingView {
                    withAnimation { hasSeenOnboarding = true }
                }
                .transition(.opacity)
            } else if auth.isSignedIn {
                MainTabView()
            } else {
                LoginView(vm: auth)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: auth.isSignedIn)
        .animation(.easeInOut(duration: 0.25), value: hasSeenOnboarding)
    }
}

private struct MainTabView: View {
    @Environment(DeepLinkRouter.self) private var router

    var body: some View {
        @Bindable var router = router
        TabView(selection: $router.selectedTab) {
            DashboardView()
                .tag(DeepLinkRouter.Tab.dashboard)
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            NavigationStack {
                PicksListView()
            }
            .tag(DeepLinkRouter.Tab.picks)
            .tabItem {
                Label("All Picks", systemImage: "list.bullet.rectangle")
            }
            NavigationStack {
                HistoryView()
            }
            .tag(DeepLinkRouter.Tab.history)
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            NavigationStack {
                SettingsView()
            }
            .tag(DeepLinkRouter.Tab.settings)
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}
