//
//  PickDetailView.swift
//  MLBValueBets
//
//  Expanded view of a single pick. Shows all signals and edge breakdown,
//  rendered with the same visual vocabulary as the web detail panel.
//

import SwiftUI

struct PickDetailView: View {
    let pick: Pick

    var body: some View {
        ZStack {
            BrandBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {

                    // Hero
                    hero

                    // Main pick panel
                    mainPanel

                    // Stats grid
                    stats

                    // Signals
                    if pick.sharpSignal || (pick.pinnacleConfirms ?? false) {
                        signals
                    }

                    // Outcome (if settled)
                    if let outcome = pick.outcome {
                        outcomeSection(outcome: outcome)
                    }
                }
                .padding(Theme.Spacing.lg)
            }
        }
        .navigationTitle("Pick Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    HapticService.medium()
                    SharePickService.share(pick)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(Color.brandTextPrimary)
                }
            }
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text(pick.market.uppercased())
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Spacer()
                if let book = pick.book {
                    Text(book.uppercased())
                        .font(Theme.Font.overline(10))
                        .tracking(1.5)
                        .foregroundStyle(Color.brandTextMuted)
                }
            }
            Text(pick.game)
                .font(Theme.Font.heading(22, weight: .bold))
                .foregroundStyle(Color.brandTextPrimary)
            if let gameTime = pick.gameTime {
                Text(gameTime.asLocalGameTimeFull)
                    .font(Theme.Font.body(13))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
    }

    // MARK: - Main pick panel

    private var mainPanel: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("RECOMMENDED BET")
                .font(Theme.Font.overline(10))
                .tracking(2)
                .foregroundStyle(Color.brandTextMuted)
            HStack(alignment: .firstTextBaseline) {
                Text(pick.side)
                    .font(Theme.Font.heading(22, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(pick.bookOdds.map(formatOdds) ?? "—")
                    .font(Theme.Font.display(40))
                    .foregroundStyle(Color.brandBlue)
                    .tracking(1)
            }
            if let book = pick.book {
                Text("Best price at \(book)")
                    .font(Theme.Font.body(12))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandBlue.opacity(0.30), lineWidth: 1)
        )
        .shadow(color: Color.brandBlue.opacity(0.18), radius: 24, x: 0, y: 0)
    }

    // MARK: - Stats grid

    private var stats: some View {
        let edge = pick.edgePct.map { String(format: "+%.2f%%", $0) } ?? "—"
        let ev   = pick.evPct.map { String(format: "+%.2f%%", $0) } ?? "—"
        let implied = pick.impliedProb.map { String(format: "%.1f%%", $0 * 100) } ?? "—"
        let modelProb = String(format: "%.1f%%", pick.modelProb * 100)

        return VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionLabel("EDGE BREAKDOWN")
            VStack(spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.sm) {
                    statTile(label: "EDGE", value: edge,
                             color: .edgeColor(for: pick.confidenceTier))
                    statTile(label: "EV", value: ev)
                }
                HStack(spacing: Theme.Spacing.sm) {
                    statTile(label: "IMPLIED %", value: implied)
                    statTile(label: "MODEL PROB", value: modelProb)
                }
                if pick.kellyFraction > 0 {
                    HStack(spacing: Theme.Spacing.sm) {
                        statTile(label: "KELLY %",
                                 value: String(format: "%.2f%%", pick.kellyFraction * 100))
                        statTile(label: "CONFIDENCE",
                                 value: (pick.confidence ?? pick.confidenceTier.rawValue).uppercased(),
                                 color: .edgeColor(for: pick.confidenceTier))
                    }
                }
            }
        }
    }

    private func statTile(label: String, value: String, color: Color = .brandTextPrimary) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(Theme.Font.overline(10))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextMuted)
            Text(value)
                .font(Theme.Font.data(20, weight: .semibold))
                .foregroundStyle(color)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.md)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value)")
    }

    // MARK: - Signals

    private var signals: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            sectionLabel("SIGNALS")
            if pick.sharpSignal {
                signalRow(
                    icon: "bolt.fill",
                    title: "SHARP LINE MOVE",
                    detail: "The line moved 5+ pts toward this pick, a strong indicator that sharp money is backing this side.",
                    color: .brandAmber
                )
            }
            if pick.pinnacleConfirms == true {
                signalRow(
                    icon: "diamond.fill",
                    title: "PINNACLE CONFIRMS",
                    detail: "Pinnacle, the sharpest sportsbook in the world, has this side priced more favorably than the book shown above.",
                    color: .brandBlue
                )
            }
        }
    }

    private func signalRow(icon: String, title: String, detail: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                Text(title)
                    .font(Theme.Font.overline(11))
                    .tracking(1.5)
            }
            .foregroundStyle(color)
            Text(detail)
                .font(Theme.Font.body(12))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                .stroke(color.opacity(0.30), lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
    }

    private func outcomeSection(outcome: String) -> some View {
        HStack {
            Circle()
                .fill(Color.outcomeColor(for: outcome))
                .frame(width: 10, height: 10)
            Text("RESULT  ·  \(outcome.uppercased())")
                .font(Theme.Font.overline(11))
                .tracking(1.5)
                .foregroundStyle(Color.outcomeColor(for: outcome))
            Spacer()
            if let clv = pick.clvPct {
                Text(String(format: "CLV %+.2f%%", clv))
                    .font(Theme.Font.data(12, weight: .medium))
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.sm)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        HStack(spacing: Theme.Spacing.sm) {
            Rectangle()
                .fill(Color.brandBlue)
                .frame(width: 18, height: 1)
            Text(text)
                .font(Theme.Font.overline(11))
                .tracking(2)
                .foregroundStyle(Color.brandBlue)
        }
    }

    private func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }
}
