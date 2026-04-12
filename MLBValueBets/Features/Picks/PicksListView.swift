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
    @Namespace private var categoryNamespace

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

                    if let date = vm.displayDate {
                        HStack(spacing: Theme.Spacing.sm) {
                            Rectangle()
                                .fill(Color.brandBlue)
                                .frame(width: 24, height: 1)
                            Text(date)
                                .font(Theme.Font.overline(11))
                                .tracking(2)
                                .foregroundStyle(Color.brandBlue)
                            Spacer()
                            if let total = vm.response?.totalBets {
                                Text("\(vm.filteredPicks.count) OF \(total) PICKS")
                                    .font(Theme.Font.overline(10))
                                    .tracking(1)
                                    .foregroundStyle(Color.brandTextMuted)
                            }
                        }
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, vm.lastCachedAt == nil ? Theme.Spacing.sm : 0)
                    }

                    categoryTabs
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, vm.displayDate == nil && vm.lastCachedAt == nil ? Theme.Spacing.sm : 0)

                    filterBar
                        .padding(.horizontal, Theme.Spacing.lg)

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
                actionTitle: emptyActionTitle,
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
        switch vm.selectedCategory {
        case .valueBets:   return "No value bets found yet"
        case .todaysPicks: return "No picks in this range"
        case .preLineup:   return "All lineups are set"
        }
    }

    private var emptyMessage: String {
        switch vm.selectedCategory {
        case .valueBets:
            if vm.preLineupCount > 0 {
                return "Lineups haven't been posted yet — edges sharpen once confirmed lineups are in. Check the Pre-Lineup tab for early reads."
            }
            return "Today's slate hasn't produced any value bets yet. Pull to refresh or check back closer to first pitch."
        case .todaysPicks:
            return "No picks between 5-10% edge right now. Try the Value Bets tab for stronger signals."
        case .preLineup:
            return "All games have confirmed lineups — check Value Bets and Today's Picks for the latest edges."
        }
    }

    private var emptyActionTitle: String {
        if vm.selectedMarket != .all { return "Show all" }
        switch vm.selectedCategory {
        case .valueBets:   return vm.preLineupCount > 0 ? "Pre-Lineup Picks" : "Refresh"
        case .todaysPicks: return "Value Bets"
        case .preLineup:   return "Value Bets"
        }
    }

    private func emptyAction() {
        if vm.selectedMarket != .all {
            withAnimation(Theme.Motion.spring) { vm.selectedMarket = .all }
            return
        }
        switch vm.selectedCategory {
        case .valueBets:
            if vm.preLineupCount > 0 {
                withAnimation(Theme.Motion.spring) { vm.selectedCategory = .preLineup }
            } else {
                Task { await vm.refresh() }
            }
        case .todaysPicks:
            withAnimation(Theme.Motion.spring) { vm.selectedCategory = .valueBets }
        case .preLineup:
            withAnimation(Theme.Motion.spring) { vm.selectedCategory = .valueBets }
        }
    }

    // MARK: - Category tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(PicksViewModel.Category.allCases) { cat in
                    categoryChip(cat)
                }
            }
            .padding(.vertical, 3)
        }
    }

    private func categoryChip(_ category: PicksViewModel.Category) -> some View {
        let isActive = vm.selectedCategory == category
        let count: Int = {
            switch category {
            case .valueBets:   return vm.valueBetCount
            case .todaysPicks: return vm.todaysPicksCount
            case .preLineup:   return vm.preLineupCount
            }
        }()

        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(Theme.Motion.spring) {
                vm.selectedCategory = category
            }
        } label: {
            HStack(spacing: 6) {
                Text(category.rawValue.uppercased())
                    .font(Theme.Font.overline(11))
                    .tracking(1.2)
                Text("\(count)")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(isActive ? Color.white.opacity(0.20) : Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
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
                            .matchedGeometryEffect(id: "categoryPill", in: categoryNamespace)
                            .shadow(color: Color.brandBlue.opacity(0.40), radius: 10)
                    }
                }
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Market filter

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
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) filter")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}
