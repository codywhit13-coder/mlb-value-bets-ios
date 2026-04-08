//
//  PickCard.swift
//  MLBValueBets
//
//  Unlocked pick card. Mirrors the design of
//  frontend/src/components/picks/PickCard.tsx
//

import SwiftUI

struct PickCard: View {
    let pick: Pick

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Top row: matchup + market chip
            HStack(alignment: .firstTextBaseline) {
                Text(pick.game)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(pick.market.capitalized)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.brandBorder)
                    .foregroundStyle(Color.brandTextSecondary)
                    .clipShape(Capsule())
            }

            // Badges row: Sharp / Pinnacle
            if pick.sharpSignal || (pick.pinnacleConfirms ?? false) {
                HStack(spacing: 6) {
                    if pick.sharpSignal {
                        badge(text: "⚡ Sharp", color: .brandAmber)
                    }
                    if pick.pinnacleConfirms == true {
                        badge(text: "◆ PIN ✓", color: .brandPurple)
                    }
                    Spacer()
                }
            }

            // Main row: side + odds
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended Bet")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.brandTextMuted)
                    Text(pick.side)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.brandTextPrimary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(pick.bookOdds.map { formatOdds($0) } ?? "—")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brandTextPrimary)
                    if let book = pick.book {
                        Text(book)
                            .font(.system(size: 10))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                }
            }

            // Bottom stats strip
            HStack(spacing: 0) {
                stat(
                    value: pick.edgePct.map { String(format: "+%.2f%%", $0) } ?? "—",
                    label: "Edge",
                    color: .edgeColor(for: pick.confidenceTier)
                )
                Divider().frame(height: 28).background(Color.brandBorder)
                stat(
                    value: pick.evPct.map { String(format: "+%.2f%%", $0) } ?? "—",
                    label: "EV"
                )
                Divider().frame(height: 28).background(Color.brandBorder)
                stat(
                    value: (pick.confidence ?? pick.confidenceTier.rawValue).capitalized,
                    label: "Conf",
                    color: .edgeColor(for: pick.confidenceTier)
                )
            }

            // Outcome footer (only shown when settled)
            if let outcome = pick.outcome {
                HStack {
                    Circle()
                        .fill(Color.outcomeColor(for: outcome))
                        .frame(width: 8, height: 8)
                    Text(outcome.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.outcomeColor(for: outcome))
                    Spacer()
                    if let game_time = pick.gameTime {
                        Text(game_time.asLocalGameTime)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.brandTextSecondary)
                    }
                }
            } else if let gameTime = pick.gameTime {
                HStack {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(gameTime.asLocalGameTime)
                        .font(.system(size: 11))
                    Spacer()
                }
                .foregroundStyle(Color.brandTextSecondary)
            }
        }
        .padding(14)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
    }

    // MARK: - Helpers

    private func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }

    private func badge(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func stat(value: String, label: String, color: Color = .brandTextPrimary) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(Color.brandTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }
}
