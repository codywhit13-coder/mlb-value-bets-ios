//
//  SettingsView.swift
//  MLBValueBets
//
//  Subscriptions are managed on mlbvaluebets.com — upgrade and account
//  management buttons open the website in Safari.
//

import SwiftUI

struct SettingsView: View {
    @Environment(AuthViewModel.self) private var auth
    private var push = PushNotificationService.shared

    var body: some View {
        ZStack {
            BrandBackground()

            List {
                Section {
                    if let user = auth.currentUser {
                        labelRow("EMAIL", value: user.email)
                        HStack {
                            Text("PLAN")
                                .font(Theme.Font.overline(11))
                                .tracking(1.5)
                                .foregroundStyle(Color.brandTextSecondary)
                            Spacer()
                            Text(user.tier.displayName.uppercased())
                                .font(Theme.Font.overline(10))
                                .tracking(1.5)
                                .padding(.horizontal, Theme.Spacing.md)
                                .padding(.vertical, 5)
                                .background(user.isPro ? Color.brandAmber : Color.freeBadge)
                                .foregroundStyle(user.isPro ? Color.black : Color.brandTextPrimary)
                                .clipShape(Capsule())
                        }
                    }
                } header: {
                    sectionHeader("ACCOUNT")
                }
                .listRowBackground(Color.brandSurface)
                .listRowSeparatorTint(Color.brandBorder)

                Section {
                    if auth.currentUser?.isPro != true {
                        Link(destination: Config.upgradeURL) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("UPGRADE TO PRO")
                                        .font(Theme.Font.heading(13, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundStyle(Color.brandAmber)
                                    Text("Unlock every pick, every day")
                                        .font(Theme.Font.body(12))
                                        .foregroundStyle(Color.brandTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundStyle(Color.brandAmber)
                            }
                        }
                    }
                    Link(destination: Config.accountURL) {
                        legalLink("MANAGE ACCOUNT")
                    }
                } header: {
                    sectionHeader("SUBSCRIPTION")
                }
                .listRowBackground(Color.brandSurface)
                .listRowSeparatorTint(Color.brandBorder)

                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("PUSH NOTIFICATIONS")
                                .font(Theme.Font.overline(11))
                                .tracking(1.5)
                                .foregroundStyle(Color.brandTextSecondary)
                            Text(push.statusDescription)
                                .font(Theme.Font.body(12))
                                .foregroundStyle(Color.brandTextMuted)
                        }
                        Spacer()
                        if push.isAuthorized {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.winGreen)
                        } else {
                            Button {
                                Task { await push.requestPermission() }
                            } label: {
                                Text("ENABLE")
                                    .font(Theme.Font.overline(10))
                                    .tracking(1.5)
                                    .foregroundStyle(Color.brandBlue)
                                    .padding(.horizontal, Theme.Spacing.md)
                                    .padding(.vertical, 6)
                                    .background(Color.brandBlue.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    sectionHeader("NOTIFICATIONS")
                }
                .listRowBackground(Color.brandSurface)

                Section {
                    labelRow("VERSION", value: appVersion)
                    labelRow("BUILD", value: buildNumber)
                } header: {
                    sectionHeader("ABOUT")
                }
                .listRowBackground(Color.brandSurface)
                .listRowSeparatorTint(Color.brandBorder)

                Section {
                    Link(destination: Config.privacyURL) {
                        legalLink("PRIVACY POLICY")
                    }
                    Link(destination: Config.termsURL) {
                        legalLink("TERMS OF SERVICE")
                    }
                } header: {
                    sectionHeader("LEGAL")
                }
                .listRowBackground(Color.brandSurface)
                .listRowSeparatorTint(Color.brandBorder)

                Section {
                    Button(role: .destructive) {
                        Task { await auth.signOut() }
                    } label: {
                        Text("SIGN OUT")
                            .font(Theme.Font.heading(13, weight: .bold))
                            .tracking(1.5)
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

    private func sectionHeader(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Rectangle()
                .fill(Color.brandBlue)
                .frame(width: 18, height: 1)
            Text(text)
                .font(Theme.Font.overline(11))
                .tracking(2)
                .foregroundStyle(Color.brandBlue)
        }
        .padding(.bottom, 4)
    }

    private func labelRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.Font.overline(11))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextSecondary)
            Spacer()
            Text(value)
                .font(Theme.Font.data(13, weight: .regular))
                .foregroundStyle(Color.brandTextPrimary)
        }
    }

    private func legalLink(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(Theme.Font.heading(12, weight: .semibold))
                .tracking(1)
                .foregroundStyle(Color.brandTextPrimary)
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.brandBlue)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }
}
