//
//  DashboardView.swift
//  MLBValueBets
//
//  The home screen and primary job-to-be-done. Layered like the web frontend:
//    1. BrandBackground (radial blue glow + grid + amber accent)
//    2. Hero: huge display title + tier badge
//    3. Live record strip (Bebas Neue numerals)
//    4. Section overline + top picks list
//    5. View All CTA
//

import SwiftUI

struct DashboardView: View {
    @State private var vm: DashboardViewModel
    @Environment(AuthViewModel.self) private var auth

    @MainActor
    init(vm: DashboardViewModel? = nil) {
        _vm = State(initialValue: vm ?? DashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack {
                BrandBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                        hero
                        recordSection
                        topPicksSection
                        if vm.todayResponse != nil && !vm.topPicks.isEmpty {
                            viewAllButton
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.top, Theme.Spacing.sm)
                    .padding(.bottom, Theme.Spacing.xxl)
                }
                .refreshable { await vm.refresh() }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                            .environment(auth)
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(Color.brandTextPrimary)
                    }
                }
            }
            .task {
                if vm.todayResponse == nil {
                    await vm.load()
                }
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            // Section overline
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("TODAY")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
                tierBadge
            }

            // Big display title
            Text("VALUE PICKS")
                .font(Theme.Font.display(40))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)

            // Date subtitle
            if let date = vm.todayResponse?.date {
                Text(date.uppercased())
                    .font(Theme.Font.overline(11))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
    }

    private var tierBadge: some View {
        let isPro = vm.todayResponse?.isPro ?? (auth.currentUser?.isPro ?? false)
        return Text(isPro ? "PRO" : "FREE")
            .font(Theme.Font.overline(10))
            .tracking(1.5)
            .foregroundStyle(isPro ? Color.black : Color.brandTextPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 5)
            .background(isPro ? Color.brandAmber : Color.freeBadge)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(
                    isPro ? Color.brandAmberDim : Color.brandBorder,
                    lineWidth: 0.5
                )
            )
    }

    // MARK: - Record strip

    @ViewBuilder
    private var recordSection: some View {
        if vm.liveRecord == nil && vm.isLoading {
            LiveRecordSkeleton()
        } else {
            recordStrip
        }
    }

    @ViewBuilder
    private var recordStrip: some View {
        if let live = vm.liveRecord {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.sm) {
                    // Pulse dot — small live indicator
                    Circle()
                        .fill(Color.brandBlue)
                        .frame(width: 6, height: 6)
                    Text("2026 LIVE SEASON")
                        .font(Theme.Font.overline(10))
                        .tracking(2)
                        .foregroundStyle(Color.brandTextSecondary)
                    Spacer()
                }
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    metric(
                        value: live.displayRecord,
                        label: "RECORD"
                    )
                    Spacer()
                    metric(
                        value: String(format: "%.1f%%", live.winRate * 100),
                        label: "WIN %",
                        color: live.winRate >= 0.52 ? .winGreen : .brandTextPrimary
                    )
                    Spacer()
                    metric(
                        value: live.roi.map { String(format: "%+.1f%%", $0 * 100) } ?? "—",
                        label: "ROI",
                        color: (live.roi ?? 0) >= 0 ? .winGreen : .lossRed
                    )
                }
            }
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.brandSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.lg)
                    .stroke(Color.brandBorder, lineWidth: 1)
            )
            .shadow(color: Color.brandBlue.opacity(0.08), radius: 24, x: 0, y: 0)
        }
    }

    private func metric(
        value: String,
        label: String,
        color: Color = .brandTextPrimary
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(Theme.Font.display(28))
                .foregroundStyle(color)
                .tracking(0.5)
            Text(label)
                .font(Theme.Font.overline(9))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextMuted)
        }
    }

    // MARK: - Top picks section

    private var topPicksSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("TOP PICKS")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
                if let total = vm.todayResponse?.totalBets {
                    Text("\(vm.valueBetCount) VALUE / \(total) TOTAL")
                        .font(Theme.Font.overline(10))
                        .tracking(1)
                        .foregroundStyle(Color.brandTextMuted)
                }
            }
            picksList
        }
    }

    @ViewBuilder
    private var picksList: some View {
        if let error = vm.errorMessage {
            ErrorStateCard(message: error) {
                Task { await vm.refresh() }
            }
        } else if vm.isLoading && vm.todayResponse == nil {
            // First load — show 3 skeleton cards shaped like PickCard so the
            // layout doesn't jump when the real picks arrive.
            VStack(spacing: Theme.Spacing.md) {
                PickCardSkeleton()
                PickCardSkeleton()
                PickCardSkeleton()
            }
        } else if vm.topPicks.isEmpty {
            EmptyStateView(
                headline: "No picks today",
                message: "Today's slate hasn't produced any value bets yet. Pull to refresh or check back closer to first pitch.",
                actionTitle: "Refresh",
                action: { Task { await vm.refresh() } }
            )
        } else {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(vm.topPicks) { pick in
                    if pick.locked {
                        LockedPickCard(pick: pick)
                    } else {
                        NavigationLink {
                            PickDetailView(pick: pick)
                        } label: {
                            PickCard(pick: pick)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - CTA

    private var viewAllButton: some View {
        NavigationLink {
            PicksListView()
        } label: {
            HStack {
                Text("VIEW ALL PICKS")
                    .font(Theme.Font.heading(13, weight: .bold))
                    .tracking(1.5)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundStyle(Color.brandBlue)
            .padding(Theme.Spacing.lg)
            .background(Color.brandSurface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(Color.brandBlue.opacity(0.40), lineWidth: 1)
            )
            .shadow(color: Color.brandBlue.opacity(0.15), radius: 12, x: 0, y: 0)
        }
    }
}
