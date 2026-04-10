//
//  HistoryView.swift
//  MLBValueBets
//
//  Settled picks browser — 4th tab ("History"). Shows recent settled
//  picks grouped by game date with a mini record strip per day and
//  a 7-day summary header.
//
//  Layout:
//    1. BrandBackground
//    2. Summary header — "LAST 7 DAYS" overline + total record display
//    3. Date sections — date header with mini record, picks list
//    4. Loading / empty / error states (reuses LoadingStates primitives)
//

import SwiftUI

struct HistoryView: View {
    @State private var vm: HistoryViewModel

    @MainActor
    init(vm: HistoryViewModel? = nil) {
        _vm = State(initialValue: vm ?? HistoryViewModel())
    }

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    summaryHeader
                    content
                }
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.top, Theme.Spacing.sm)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .refreshable { await vm.refresh() }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if vm.allPicks.isEmpty && vm.errorMessage == nil {
                await vm.load()
            }
        }
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("LAST 7 DAYS")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
            }

            Text("SETTLED PICKS")
                .font(Theme.Font.display(36))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)

            if !vm.allPicks.isEmpty {
                Text("\(vm.totalRecord)  ·  \(vm.allPicks.count) PICKS")
                    .font(Theme.Font.overline(11))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if let error = vm.errorMessage {
            ErrorStateCard(message: error) {
                Task { await vm.refresh() }
            }
        } else if vm.isLoading && vm.allPicks.isEmpty {
            VStack(spacing: Theme.Spacing.md) {
                PickCardSkeleton()
                PickCardSkeleton()
                PickCardSkeleton()
            }
        } else if vm.allPicks.isEmpty {
            EmptyStateView(
                headline: "No history yet",
                message: "Settled picks from the last 7 days will appear here. Check back after today's games finish.",
                actionTitle: "Refresh",
                action: { Task { await vm.refresh() } }
            )
        } else {
            daySections
        }
    }

    // MARK: - Day sections

    private var daySections: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
            ForEach(vm.sections) { section in
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    daySectionHeader(section)

                    VStack(spacing: Theme.Spacing.md) {
                        ForEach(section.picks) { pick in
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
    }

    private func daySectionHeader(_ section: HistoryViewModel.DaySection) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            // Date overline
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 18, height: 1)
                Text(section.displayDate.uppercased())
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
            }

            // Mini record strip
            HStack(spacing: Theme.Spacing.md) {
                // Record
                Text(section.displayRecord)
                    .font(Theme.Font.data(13, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)

                // Thin divider
                Rectangle()
                    .fill(Color.brandBorder)
                    .frame(width: 1, height: 14)

                // Units +/-
                Text(String(format: "%+.1fu", section.unitsProfit))
                    .font(Theme.Font.data(13, weight: .semibold))
                    .foregroundStyle(
                        section.unitsProfit >= 0 ? Color.winGreen : Color.lossRed
                    )

                Spacer()

                // Pick count
                Text("\(section.picks.count) PICKS")
                    .font(Theme.Font.overline(10))
                    .tracking(1)
                    .foregroundStyle(Color.brandTextMuted)
            }
            .padding(.vertical, Theme.Spacing.xs)
            .padding(.horizontal, Theme.Spacing.md)
            .background(Color.brandSurface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
        }
    }
}
