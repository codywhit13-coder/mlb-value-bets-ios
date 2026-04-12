//
//  DashboardView.swift
//  MLBValueBets
//
//  The home screen and primary job-to-be-done. Layered like the web frontend:
//    1. BrandBackground (radial blue glow + grid + amber accent)
//    2. Hero: huge display title + tier badge
//    3. Live record strip (Bebas Neue numerals)
//    4. Category tabs (Value Bets / Today's Picks / Pre-Lineup) — Pro only
//    5. Market filter (All / ML / Totals / RL) — Pro only
//    6. Picks list
//

import SwiftUI
import UIKit

struct DashboardView: View {
    @State private var vm: DashboardViewModel
    @Environment(AuthViewModel.self) private var auth
    @Namespace private var categoryNamespace
    @Namespace private var marketNamespace

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
                        if let cachedAt = vm.lastCachedAt {
                            StaleBanner(cachedAt: cachedAt)
                        }
                        hero
                        recordSection

                        // Pro users: category tabs + market filter + filtered picks
                        // Free users: just their unlocked picks, no filters
                        if vm.isPro {
                            categoryTabs
                            marketFilter
                            proPicksSection
                        } else {
                            freePicksSection
                        }

                        if !vm.isPro {
                            upgradeBanner
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
                // Only count opens after a successful data load
                if vm.todayResponse != nil {
                    AppReviewService.recordAppOpen()
                }
            }
            .onChange(of: vm.isSessionExpired) { _, expired in
                if expired { Task { await auth.signOut() } }
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
                Text(Date.now.formatted(.dateTime.month(.wide).day(.defaultDigits)))
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                    .textCase(.uppercase)
                Spacer()
                tierBadge
            }

            // Big display title
            Text("VALUE PICKS")
                .font(Theme.Font.display(40))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)

            // Stats subtitle
            if let data = vm.todayResponse {
                HStack(spacing: Theme.Spacing.sm) {
                    Text("\(data.gamesToday) games")
                    Text("·").foregroundStyle(Color.brandTextMuted)
                    Text("\(data.totalBets) picks")
                    Text("·").foregroundStyle(Color.brandTextMuted)
                    Text("\(vm.valueBetCount) value bets")
                }
                .font(Theme.Font.body(12))
                .foregroundStyle(Color.brandTextMuted)
            }
        }
    }

    private var tierBadge: some View {
        let isPro = vm.isPro
        return Text(isPro ? "PRO" : "FREE")
            .font(Theme.Font.overline(10))
            .tracking(1.5)
            .foregroundStyle(isPro ? Color.black : Color.brandTextPrimary)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, 5)
            .background(isPro ? Color.brandAmber : Color.freeBadge)
            .clipShape(Capsule())
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
                    PulseDot(color: .brandBlue)
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
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(live.accessibilityLabel)
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

    // MARK: - Category tabs (Pro only)

    private var categoryTabs: some View {
        HStack(spacing: Theme.Spacing.xs) {
            ForEach(DashboardViewModel.Category.allCases) { cat in
                categoryChip(cat)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func categoryChip(_ category: DashboardViewModel.Category) -> some View {
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
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.sm)
            .frame(maxWidth: .infinity)
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

    // MARK: - Market filter (Pro only)

    private var marketFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(DashboardViewModel.MarketFilter.allCases) { market in
                    marketChip(market)
                }
            }
        }
    }

    private func marketChip(_ market: DashboardViewModel.MarketFilter) -> some View {
        let isActive = vm.selectedMarket == market
        return Button {
            UISelectionFeedbackGenerator().selectionChanged()
            withAnimation(Theme.Motion.spring) {
                vm.selectedMarket = market
            }
        } label: {
            Text(market.rawValue.uppercased())
                .font(Theme.Font.overline(10))
                .tracking(1)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, 6)
                .foregroundStyle(isActive ? Color.brandBlue : Color.brandTextMuted)
                .background(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .fill(isActive ? Color.brandBlue.opacity(0.12) : Color.brandSurface)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.Radius.sm)
                        .stroke(isActive ? Color.brandBlue.opacity(0.40) : Color.brandBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Pro picks section

    private var proPicksSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            proPicksList
        }
    }

    @ViewBuilder
    private var proPicksList: some View {
        if let error = vm.errorMessage {
            ErrorStateCard(message: error) {
                Task { await vm.refresh() }
            }
        } else if vm.isLoading && vm.todayResponse == nil {
            VStack(spacing: Theme.Spacing.md) {
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
        } else {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(Array(vm.filteredPicks.enumerated()), id: \.element.id) { index, pick in
                    NavigationLink {
                        PickDetailView(pick: pick)
                    } label: {
                        PickCard(pick: pick, isPro: true)
                    }
                    .buttonStyle(.card)
                    .staggeredAppearance(index: index)
                }
            }
            .id(vm.selectedCategory)
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
        switch vm.selectedCategory {
        case .valueBets:
            return vm.preLineupCount > 0 ? "Pre-Lineup Picks" : "Refresh"
        case .todaysPicks:
            return "Value Bets"
        case .preLineup:
            return "Value Bets"
        }
    }

    private func emptyAction() {
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

    // MARK: - Free picks section

    private var freePicksSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("YOUR PICKS")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
            }
            freePicksList
        }
    }

    @ViewBuilder
    private var freePicksList: some View {
        if let error = vm.errorMessage {
            ErrorStateCard(message: error) {
                Task { await vm.refresh() }
            }
        } else if vm.isLoading && vm.todayResponse == nil {
            VStack(spacing: Theme.Spacing.md) {
                PickCardSkeleton()
                PickCardSkeleton()
            }
        } else if vm.freePicks.isEmpty {
            EmptyStateView(
                headline: "No picks today",
                message: "Today's slate hasn't produced any value bets yet. Pull to refresh or check back closer to first pitch.",
                actionTitle: "Refresh",
                action: { Task { await vm.refresh() } }
            )
        } else {
            VStack(spacing: Theme.Spacing.md) {
                ForEach(Array(vm.freePicks.enumerated()), id: \.element.id) { index, pick in
                    if pick.locked {
                        LockedPickCard(pick: pick)
                            .staggeredAppearance(index: index)
                    } else {
                        NavigationLink {
                            PickDetailView(pick: pick)
                        } label: {
                            PickCard(pick: pick, isPro: false)
                        }
                        .buttonStyle(.card)
                        .staggeredAppearance(index: index)
                    }
                }
            }
        }
    }

    // MARK: - CTA

    private var upgradeBanner: some View {
        Link(destination: Config.upgradeURL) {
            VStack(spacing: Theme.Spacing.sm) {
                HStack {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 14, weight: .bold))
                    Text("UNLOCK ALL PICKS")
                        .font(Theme.Font.heading(13, weight: .bold))
                        .tracking(1.5)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                }
                Text("Get every pick, every market, every day with Pro")
                    .font(Theme.Font.body(12))
                    .foregroundStyle(Color.brandAmber.opacity(0.70))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .foregroundStyle(Color.brandAmber)
            .padding(Theme.Spacing.lg)
            .background(Color.brandAmber.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .stroke(Color.brandAmber.opacity(0.30), lineWidth: 1)
            )
            .shadow(color: Color.brandAmber.opacity(0.10), radius: 12, x: 0, y: 0)
        }
    }

}
