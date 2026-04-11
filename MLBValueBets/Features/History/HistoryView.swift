//
//  HistoryView.swift
//  MLBValueBets
//
//  Settled picks browser — 3rd tab ("History"). Shows settled picks
//  one date at a time with prev/next navigation and a calendar picker
//  to jump to a specific date.
//
//  Layout:
//    1. BrandBackground
//    2. Summary header — "LAST 7 DAYS" overline + total record display
//    3. Confidence filter bar (High / Medium / Low)
//    4. Date navigator — ← Tue, Apr 8  📅 →
//    5. Day section — record strip + picks for the selected date
//

import SwiftUI
import UIKit

struct HistoryView: View {
    @State private var vm: HistoryViewModel
    @Namespace private var filterNamespace
    @State private var showCalendar = false
    @State private var calendarDate = Date()

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
                        dateNavigator
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
        .sheet(isPresented: $showCalendar) {
            calendarSheet
        }
    }

    // MARK: - Summary header

    private var summaryHeader: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("\(vm.selectedConfidence.rawValue.uppercased()) CONFIDENCE · LAST 7 DAYS")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                    .contentTransition(.numericText())
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
                    .contentTransition(.numericText())
            }
        }
        .animation(Theme.Motion.spring, value: vm.selectedConfidence)
    }

    // MARK: - Date navigator

    private var dateNavigator: some View {
        HStack(spacing: Theme.Spacing.md) {
            Button {
                HapticService.light()
                withAnimation(Theme.Motion.spring) { vm.goToEarlierDate() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(
                        vm.canGoEarlier ? Color.brandBlue : Color.brandTextMuted.opacity(0.3)
                    )
                    .frame(width: 34, height: 34)
                    .background(Color.brandSurface)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            vm.canGoEarlier ? Color.brandBlue.opacity(0.30) : Color.brandBorder,
                            lineWidth: 0.5
                        )
                    )
            }
            .disabled(!vm.canGoEarlier)

            Spacer()

            Text(vm.currentDateDisplay.uppercased())
                .font(Theme.Font.heading(14, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)

            Spacer()

            Button {
                calendarDate = vm.effectiveDateAsDate ?? Date()
                showCalendar = true
            } label: {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.brandBlue)
                    .frame(width: 34, height: 34)
                    .background(Color.brandSurface)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.brandBlue.opacity(0.30), lineWidth: 0.5)
                    )
            }

            Button {
                HapticService.light()
                withAnimation(Theme.Motion.spring) { vm.goToLaterDate() }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(
                        vm.canGoLater ? Color.brandBlue : Color.brandTextMuted.opacity(0.3)
                    )
                    .frame(width: 34, height: 34)
                    .background(Color.brandSurface)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(
                            vm.canGoLater ? Color.brandBlue.opacity(0.30) : Color.brandBorder,
                            lineWidth: 0.5
                        )
                    )
            }
            .disabled(!vm.canGoLater)
        }
        .padding(.vertical, Theme.Spacing.sm)
    }

    // MARK: - Calendar sheet

    private var calendarSheet: some View {
        NavigationStack {
            VStack {
                if let range = vm.calendarDateRange {
                    DatePicker(
                        "",
                        selection: $calendarDate,
                        in: range,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(Color.brandBlue)
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.brandBackground)
            .navigationTitle("Jump to Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { showCalendar = false }
                        .foregroundStyle(Color.brandTextSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Go") {
                        vm.selectDate(calendarDate)
                        showCalendar = false
                    }
                    .font(.headline)
                    .foregroundStyle(Color.brandBlue)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
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
        } else if let section = vm.currentSection {
            selectedDateContent(section)
        } else if vm.effectiveDate != nil {
            EmptyStateView(
                headline: "No \(vm.selectedConfidence.rawValue.lowercased()) confidence picks",
                message: "No picks match the \(vm.selectedConfidence.subtitle) range on this date. Try a different confidence tier or date.",
                actionTitle: "Show High",
                action: {
                    withAnimation(Theme.Motion.spring) {
                        vm.selectedConfidence = .high
                    }
                }
            )
            .padding(.top, Theme.Spacing.lg)
        }
    }

    // MARK: - Selected date content

    private func selectedDateContent(_ section: HistoryViewModel.DaySection) -> some View {
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
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.rawValue) confidence filter")
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    // MARK: - Day section header

    private func daySectionHeader(_ section: HistoryViewModel.DaySection) -> some View {
        let decisive = section.wins + section.losses
        let winPct = decisive > 0 ? Double(section.wins) / Double(decisive) * 100 : 0
        let record = section.pushes > 0
            ? "\(section.wins)-\(section.losses)-\(section.pushes)"
            : "\(section.wins)-\(section.losses)"

        return HStack(spacing: 0) {
            // Record
            VStack(spacing: 4) {
                Text(record)
                    .font(Theme.Font.display(22))
                    .foregroundStyle(Color.brandTextPrimary)
                Text("RECORD")
                    .font(Theme.Font.overline(9))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandTextMuted)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.brandBorder)
                .frame(width: 1, height: 28)

            // Win %
            VStack(spacing: 4) {
                Text(decisive > 0 ? String(format: "%.0f%%", winPct) : "—")
                    .font(Theme.Font.display(22))
                    .foregroundStyle(winPct >= 50 ? Color.winGreen : Color.lossRed)
                Text("WIN %")
                    .font(Theme.Font.overline(9))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandTextMuted)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.brandBorder)
                .frame(width: 1, height: 28)

            // Pick count
            VStack(spacing: 4) {
                Text("\(section.picks.count)")
                    .font(Theme.Font.display(22))
                    .foregroundStyle(Color.brandTextPrimary)
                Text("PICKS")
                    .font(Theme.Font.overline(9))
                    .tracking(1.5)
                    .foregroundStyle(Color.brandTextMuted)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
    }
}
