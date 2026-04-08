//
//  DashboardView.swift
//  MLBValueBets
//

import SwiftUI

struct DashboardView: View {
    @State private var vm = DashboardViewModel()
    @Environment(AuthViewModel.self) private var auth

    var body: some View {
        NavigationStack {
            ZStack {
                Color.brandBackground.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header
                        recordStrip
                        todaysPicksHeader
                        picksList
                        viewAllButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .refreshable {
                    await vm.refresh()
                }

                if vm.isLoading && vm.todayResponse == nil {
                    ProgressView()
                        .tint(Color.brandAmber)
                }
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

    // MARK: - Subviews

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Today's Picks")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                if let date = vm.todayResponse?.date {
                    Text(date)
                        .font(.caption)
                        .foregroundStyle(Color.brandTextSecondary)
                }
            }
            Spacer()
            tierBadge
        }
    }

    private var tierBadge: some View {
        let isPro = vm.todayResponse?.isPro ?? (auth.currentUser?.isPro ?? false)
        return Text(isPro ? "PRO" : "FREE")
            .font(.system(size: 11, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isPro ? Color.brandAmber : Color.freeBadge)
            .foregroundStyle(isPro ? Color.black : Color.brandTextPrimary)
            .clipShape(Capsule())
    }

    @ViewBuilder
    private var recordStrip: some View {
        if let live = vm.liveRecord {
            HStack(spacing: 20) {
                stat(label: "Record", value: live.displayRecord)
                Divider().frame(height: 28).background(Color.brandBorder)
                stat(label: "Units",
                     value: live.unitsProfit.map { String(format: "%+.1f", $0) } ?? "—",
                     color: (live.unitsProfit ?? 0) >= 0 ? .winGreen : .lossRed)
                Divider().frame(height: 28).background(Color.brandBorder)
                stat(label: "ROI",
                     value: live.roi.map { String(format: "%+.1f%%", $0 * 100) } ?? "—",
                     color: (live.roi ?? 0) >= 0 ? .winGreen : .lossRed)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.brandSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBorder, lineWidth: 1)
            )
        }
    }

    private func stat(label: String, value: String, color: Color = .brandTextPrimary) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var todaysPicksHeader: some View {
        HStack {
            Text("Top Picks")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
            Spacer()
            if let total = vm.todayResponse?.totalBets {
                Text("\(vm.valueBetCount) value / \(total) total")
                    .font(.caption)
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
    }

    @ViewBuilder
    private var picksList: some View {
        if let error = vm.errorMessage {
            Text(error)
                .font(.footnote)
                .foregroundStyle(Color.lossRed)
                .padding(.vertical, 8)
        } else if vm.topPicks.isEmpty && !vm.isLoading {
            Text("No picks available yet today. Check back shortly.")
                .font(.footnote)
                .foregroundStyle(Color.brandTextSecondary)
                .padding(.vertical, 20)
        } else {
            VStack(spacing: 12) {
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

    private var viewAllButton: some View {
        NavigationLink {
            PicksListView()
        } label: {
            HStack {
                Text("View All Picks")
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
                Image(systemName: "arrow.right")
            }
            .foregroundStyle(Color.brandTextPrimary)
            .padding(14)
            .background(Color.brandSurface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandBorder, lineWidth: 1)
            )
        }
    }
}
