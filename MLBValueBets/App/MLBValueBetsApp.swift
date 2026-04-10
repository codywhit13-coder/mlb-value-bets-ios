//
//  MLBValueBetsApp.swift
//  MLBValueBets
//
//  App entry point. Initializes the auth view model and routes between
//  LoginView (signed out) and the main TabView (signed in).
//

import SwiftUI

@main
struct MLBValueBetsApp: App {
    @State private var auth = AuthViewModel()

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
                .preferredColorScheme(.dark)
                .tint(Color.brandBlue)
        }
    }
}

private struct RootView: View {
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        ZStack {
            if auth.isSignedIn {
                MainTabView()
            } else {
                LoginView(vm: auth)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: auth.isSignedIn)
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
            NavigationStack {
                PicksListView()
            }
            .tabItem {
                Label("All Picks", systemImage: "list.bullet.rectangle")
            }
            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
    }
}
