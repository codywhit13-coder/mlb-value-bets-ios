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
import UIKit

struct HistoryView: View {
    @State private var vm: HistoryViewModel
    @Namespace private var filterNamespace

    @MainActor
    init(vm: HistoryViewModel? = nil) {
        _vm = State(initialValue: vm ?? HistoryViewModel())
    }

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                    if let cachedAt = vm.lastCachedAt {
                        StaleBanner(cachedAt: cachedAt)
                    }
                    summaryHeader
                    if !vm.allPicks.isEmpty {
                        confidenceFilterBar
                    }
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
                Text("\(vm.totalRecord)  ·  \(vm.filteredPicks.count) PICKS")
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
        } else if vm.filteredPicks.isEmpty {
            EmptyStateView(
                headline: "No \(vm.selectedConfidence.rawValue.lowercased()) confidence picks",
                message: "No settled picks match the \(vm.selectedConfidence.subtitle) range. Try a different confidence tier.",
                actionTitle: "Show High",
                action: {
                    withAnimation(Theme.Motion.spring) {
                        vm.selectedConfidence = .high
                    }
                }
            )
            .padding(.top, Theme.Spacing.lg)
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
                        ForEach(Array(section.picks.enumerated()), id: \.element.id) { index, pick in
                            NavigationLink {
                                PickDetailView(pick: pick)
                            } label: {
                                PickCard(pick: pick)
                            }
                            .buttonStyle(.card)
                            .staggeredAppearance(index: index)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Confidence filter

    private var confidenceFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(HistoryViewModel.ConfidenceFilter.allCases) { filter in
                    confidenceChip(filter)
                }
            }
        }
    }

    private func confidenceChip(_ filter: HistoryViewModel.ConfidenceFilter) -> some View {
        let isActive = vm.selectedConfidence == filter
        let count = vm.count(for: filter)
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(Theme.Motion.spring) {
                vm.selectedConfidence = filter
            }
        } label: {
            VStack(spacing: 2) {
                HStack(spacing: 6) {
                    Text(filter.rawValue.uppercased())
                        .font(Theme.Font.overline(11))
                        .tracking(1.5)

                    if count > 0 {
                        Text("\(count)")
                            .font(Theme.Font.data(10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 1)
                            .background(
                                isActive
                                    ? Color.brandBlue.opacity(0.20)
                                    : Color.white.opacity(0.07)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .foregroundStyle(
                                isActive
                                    ? Color.brandBlue
                                    : Color.brandTextMuted
                            )
                    }
                }

                Text(filter.subtitle)
                    .font(Theme.Font.overline(8))
                    .tracking(0.8)
                    .foregroundStyle(
                        isActive
                            ? Color.brandBlue.opacity(0.70)
                            : Color.brandTextMuted.opacity(0.6)
                    )
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .foregroundStyle(isActive ? Color.white : Color.brandTextSecondary)
            .background(
                ZStack {
                    Capsule()
                        .fill(Color.brandSurface)
                    if isActive {
                        Capsule()
                            .fill(Color.brandBlue)
                            .matchedGeometryEffect(id: "confidencePill", in: filterNamespace)
                            .shadow(color: Color.brandBlue.opacity(0.40), radius: 10, x: 0, y: 0)
                    }
                }
            )
            .overlay(
                Capsule().stroke(
                    isActive ? Color.brandBlue : Color.brandBorder,
                    lineWidth: 0.5
                )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) confidence filter")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    // MARK: - Day section header

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
