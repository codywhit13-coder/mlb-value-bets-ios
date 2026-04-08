//
//  SettingsView.swift
//  MLBValueBets
//
//  App Store Reader App compliant — NO tappable "Upgrade" or payment links.
//  Users manage their subscription on mlbvaluebets.com.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            List {
                Section("Account") {
                    if let user = auth.currentUser {
                        LabeledContent("Email", value: user.email)
                        LabeledContent("Plan") {
                            Text(user.tier.displayName)
                                .font(.system(size: 13, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(user.isPro ? Color.brandAmber : Color.freeBadge)
                                .foregroundStyle(user.isPro ? Color.black : Color.brandTextPrimary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .listRowBackground(Color.brandSurface)

                Section("Manage Subscription") {
                    Text("To change your plan, add a payment method, or cancel, please sign in to your account at mlbvaluebets.com on a web browser.")
                        .font(.footnote)
                        .foregroundStyle(Color.brandTextSecondary)
                }
                .listRowBackground(Color.brandSurface)

                Section("About") {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Build", value: buildNumber)
                }
                .listRowBackground(Color.brandSurface)

                Section("Legal") {
                    Link("Privacy Policy", destination: Config.privacyURL)
                    Link("Terms of Service", destination: Config.termsURL)
                }
                .listRowBackground(Color.brandSurface)

                Section {
                    Button(role: .destructive) {
                        Task { await auth.signOut() }
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listRowBackground(Color.brandSurface)
            }
            .scrollContentBackground(.hidden)
            .foregroundStyle(Color.brandTextPrimary)
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
