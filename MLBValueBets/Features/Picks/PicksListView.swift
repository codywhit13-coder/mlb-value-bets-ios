//
//  PicksListView.swift
//  MLBValueBets
//

import SwiftUI

struct PicksListView: View {
    @State private var vm: PicksViewModel

    init(vm: PicksViewModel = PicksViewModel()) {
        _vm = State(initialValue: vm)
    }

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    filterBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    if let error = vm.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.lossRed)
                            .padding()
                    } else if vm.filteredPicks.isEmpty && !vm.isLoading {
                        Text("No picks match this filter.")
                            .font(.footnote)
                            .foregroundStyle(Color.brandTextSecondary)
                            .padding(.vertical, 40)
                    } else {
                        LazyVStack(spacing: 12) {
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
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .refreshable { await vm.refresh() }

            if vm.isLoading && vm.response == nil {
                ProgressView().tint(Color.brandAmber)
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
            HStack(spacing: 8) {
                ForEach(PicksViewModel.MarketFilter.allCases) { filter in
                    Button {
                        vm.selectedMarket = filter
                    } label: {
                        Text(filter.rawValue)
                            .font(.system(size: 12, weight: .semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(vm.selectedMarket == filter
                                        ? Color.brandAmber
                                        : Color.brandSurface)
                            .foregroundStyle(vm.selectedMarket == filter
                                             ? Color.black
                                             : Color.brandTextPrimary)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.brandBorder, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}
