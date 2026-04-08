//
//  PickDetailView.swift
//  MLBValueBets
//
//  Expanded view of a single pick. Shows all signals and edge breakdown.
//

import SwiftUI

struct PickDetailView: View {
    let pick: Pick

    var body: some View {
        ZStack {
            Color.brandBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Hero
                    VStack(alignment: .leading, spacing: 6) {
                        Text(pick.market.capitalized)
                            .font(.caption)
                            .foregroundStyle(Color.brandTextSecondary)
                        Text(pick.game)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.brandTextPrimary)
                        if let gameTime = pick.gameTime {
                            Text(gameTime.asLocalGameTimeFull)
                                .font(.footnote)
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                    }

                    // Main pick panel
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Bet")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.brandTextMuted)
                        HStack {
                            Text(pick.side)
                                .font(.system(size: 22, weight: .bold))
                            Spacer()
                            Text(pick.bookOdds.map(formatOdds) ?? "—")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(Color.brandTextPrimary)
                        if let book = pick.book {
                            Text("Best price at \(book)")
                                .font(.footnote)
                                .foregroundStyle(Color.brandTextSecondary)
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.brandSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandBorder))

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
                .padding(16)
            }
        }
        .navigationTitle("Pick Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Subviews

    private var stats: some View {
        let edge = pick.edgePct.map { String(format: "+%.2f%%", $0) } ?? "—"
        let ev   = pick.evPct.map { String(format: "+%.2f%%", $0) } ?? "—"
        let fair = formatOdds(pick.fairOdds)
        let modelProb = String(format: "%.1f%%", pick.modelProb * 100)

        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                statTile(label: "Edge", value: edge,
                         color: .edgeColor(for: pick.confidenceTier))
                statTile(label: "EV", value: ev)
            }
            HStack(spacing: 8) {
                statTile(label: "Fair Odds", value: fair)
                statTile(label: "Model Prob", value: modelProb)
            }
            if let kelly = Optional(pick.kellyFraction), kelly > 0 {
                HStack(spacing: 8) {
                    statTile(label: "Kelly %", value: String(format: "%.2f%%", kelly * 100))
                    statTile(label: "Confidence",
                             value: (pick.confidence ?? pick.confidenceTier.rawValue).capitalized,
                             color: .edgeColor(for: pick.confidenceTier))
                }
            }
        }
    }

    private func statTile(label: String, value: String, color: Color = .brandTextPrimary) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.brandTextMuted)
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.brandBorder, lineWidth: 1))
    }

    private var signals: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Signals")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
            if pick.sharpSignal {
                signalRow(icon: "⚡", title: "Sharp line move",
                          detail: "The line moved 5+ pts toward this pick, a strong indicator that sharp money is backing this side.",
                          color: .brandAmber)
            }
            if pick.pinnacleConfirms == true {
                signalRow(icon: "◆", title: "Pinnacle confirms",
                          detail: "Pinnacle, the sharpest sportsbook in the world, has this side priced more favorably than the book shown above.",
                          color: .brandPurple)
            }
        }
    }

    private func signalRow(icon: String, title: String, detail: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(icon).font(.system(size: 14))
                Text(title).font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(color)
            Text(detail)
                .font(.system(size: 12))
                .foregroundStyle(Color.brandTextSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func outcomeSection(outcome: String) -> some View {
        HStack {
            Circle()
                .fill(Color.outcomeColor(for: outcome))
                .frame(width: 10, height: 10)
            Text("Result: \(outcome.capitalized)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.outcomeColor(for: outcome))
            Spacer()
            if let clv = pick.clvPct {
                Text(String(format: "CLV %+.2f%%", clv))
                    .font(.footnote)
                    .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(12)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }
}
