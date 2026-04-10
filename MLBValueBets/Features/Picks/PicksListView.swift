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
                    filterBar
                        .padding(.horizontal, Theme.Spacing.lg)
                        .padding(.top, Theme.Spacing.sm)

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(Theme.Font.body(13))
                            .foregroundStyle(Color.lossRed)
                            .padding()
                    } else if vm.filteredPicks.isEmpty && !vm.isLoading {
                        Text("No picks match this filter.")
                            .font(Theme.Font.body(13))
                            .foregroundStyle(Color.brandTextSecondary)
                            .padding(.vertical, Theme.Spacing.xxl)
                    } else {
                        LazyVStack(spacing: Theme.Spacing.md) {
                            ForEach(vm.filteredPicks) { pick in
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
                        .padding(.horizontal, Theme.Spacing.lg)
                    }
                }
                .padding(.bottom, Theme.Spacing.xl)
            }
            .refreshable { await vm.refresh() }

            if vm.isLoading && vm.response == nil {
                ProgressView().tint(Color.brandBlue)
            }
        }
        .navigationTitle("All Picks")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if vm.response == nil { await vm.load() }
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
