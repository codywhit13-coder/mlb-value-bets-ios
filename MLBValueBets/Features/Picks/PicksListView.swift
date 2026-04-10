//
//  PicksListView.swift
//  MLBValueBets
//
//  Full picks browser with market filter chips. Filter chips use a
//  matchedGeometryEffect-driven pill so the active state slides between
//  options instead of hard-cutting. Selecting a filter triggers a
//  selection haptic.
//

import SwiftUI
import UIKit

struct PicksListView: View {
    @State private var vm: PicksViewModel
    @Namespace private var filterNamespace

    @MainActor
    init(vm: PicksViewModel? = nil) {
        _vm = State(initialValue: vm ?? PicksViewModel())
    }

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    if let cachedAt = vm.lastCachedAt {
                        StaleBanner(cachedAt: cachedAt)
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.top, Theme.Spacing.sm)
                    }

                    filterBar
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, vm.lastCachedAt == nil ? Theme.Spacing.sm : 0)

                    content
                        .padding(.horizontal, Theme.Spacing.lg)
                }
                .padding(.bottom, Theme.Spacing.xl)
            }
            .refreshable { await vm.refresh() }
        }
        .navigationTitle("All Picks")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if vm.response == nil { await vm.load() }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let error = vm.errorMessage {
            ErrorStateCard(message: error) {
                Task { await vm.refresh() }
            }
        } else if vm.isLoading && vm.response == nil {
            // First load — 4 skeleton cards for the list shape.
            VStack(spacing: Theme.Spacing.md) {
                PickCardSkeleton()
                PickCardSkeleton()
                PickCardSkeleton()
                PickCardSkeleton()
            }
        } else if vm.filteredPicks.isEmpty {
            EmptyStateView(
                headline: emptyHeadline,
                message: emptyMessage,
                actionTitle: vm.selectedMarket == .all ? "Refresh" : "Show all",
                action: emptyAction
            )
            .padding(.top, Theme.Spacing.lg)
        } else {
            LazyVStack(spacing: Theme.Spacing.md) {
                ForEach(Array(vm.filteredPicks.enumerated()), id: \.element.id) { index, pick in
                    if pick.locked {
                        LockedPickCard(pick: pick)
                            .staggeredAppearance(index: index)
                    } else {
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
            .id(vm.selectedMarket)
        }
    }

    private var emptyHeadline: String {
        vm.selectedMarket == .all ? "No picks today" : "No picks match"
    }

    private var emptyMessage: String {
        switch vm.selectedMarket {
        case .all:
            return "Today's slate hasn't produced any value bets yet. Pull to refresh or check back closer to first pitch."
        case .moneyline:
            return "No moneyline value bets right now. Try another market or show all picks."
        case .total:
            return "No totals value bets right now. Try another market or show all picks."
        case .runline:
            return "No run line value bets right now. Try another market or show all picks."
        }
    }

    private func emptyAction() {
        if vm.selectedMarket == .all {
            Task { await vm.refresh() }
        } else {
            withAnimation(Theme.Motion.spring) {
                vm.selectedMarket = .all
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(PicksViewModel.MarketFilter.allCases) { filter in
                    filterChip(filter)
                }
            }
        }
    }

    private func filterChip(_ filter: PicksViewModel.MarketFilter) -> some View {
        let isActive = vm.selectedMarket == filter
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(Theme.Motion.spring) {
                vm.selectedMarket = filter
            }
        } label: {
            Text(filter.rawValue.uppercased())
                .font(Theme.Font.overline(11))
                .tracking(1.5)
                .padding(.horizontal, Theme.Spacing.lg)
                .padding(.vertical, Theme.Spacing.sm)
                .foregroundStyle(isActive ? Color.white : Color.brandTextSecondary)
                .background(
                    ZStack {
                        // Resting capsule — always present, light surface
                        Capsule()
                            .fill(Color.brandSurface)
                        // Active capsule — slides between filters via
                        // matched geometry, so the highlight feels physical
                        if isActive {
                            Capsule()
                                .fill(Color.brandBlue)
                                .matchedGeometryEffect(id: "filterPill", in: filterNamespace)
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
    }
}
