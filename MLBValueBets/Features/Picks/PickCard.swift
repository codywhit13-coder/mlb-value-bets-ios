//
//  PickCard.swift
//  MLBValueBets
//
//  Unlocked pick card. Mirrors the design of
//  frontend/src/components/picks/PickCard.tsx
//
//  Layout (top → bottom):
//    1. Section overline:  "MONEYLINE  ·  FANDUEL"        (mono, tracked, blue)
//    2. Matchup line:      "New York Yankees @ Boston Red Sox"
//    3. Side + odds row:   "Yankees ML"           "+108"   (Bebas Neue display)
//    4. Stats strip:       EDGE / EV / KELLY (mono numerals)
//    5. Signals chip row:  Sharp / Pinnacle confirms (only when present)
//    6. Footer:            game time or settled outcome
//

import SwiftUI
import UIKit

struct PickCard: View {
    let pick: Pick

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {

            // 1. Overline — "MONEYLINE · FANDUEL"
            overline

            // 2. Matchup
            Text(pick.game)
                .font(Theme.Font.heading(15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: false, vertical: true)

            // 3. Side + odds — the visual hero of the card
            HStack(alignment: .center) {
                // Team logo (bundled PNG) or abbreviation pill fallback
                if let team = TeamBrand.brand(for: pick.side) {
                    if let uiImage = UIImage(named: team.assetName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Text(team.abbreviation)
                            .font(Theme.Font.overline(9))
                            .tracking(1)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(team.color)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                Text(pick.side)
                    .font(Theme.Font.heading(20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: Theme.Spacing.sm)
                Text(pick.bookOdds.map(formatOdds) ?? "—")
                    .font(Theme.Font.display(28))
                    .foregroundStyle(Color.brandTextPrimary)
                    .tracking(1)
            }

            // Hairline separator
            Rectangle()
                .fill(Color.brandBorder)
                .frame(height: 1)
                .padding(.vertical, Theme.Spacing.xxs)

            // 4. Stats strip
            statsStrip

            // 5. Signals chips (only if at least one is on)
            if pick.sharpSignal || (pick.pinnacleConfirms ?? false) {
                signalsRow
                    .padding(.top, Theme.Spacing.xxs)
            }

            // 6. Footer — outcome (if settled) or game time
            footer
                .padding(.top, Theme.Spacing.xxs)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .shadow(color: highEdgeShadow, radius: 18, x: 0, y: 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(pick.accessibilityLabel)
        .accessibilityHint(pick.accessibilityHint)
    }

    // MARK: - Overline

    private var marketColor: Color {
        MarketBrand.color(for: pick.market)
    }

    private var bookBrand: BookBrand {
        BookBrand.brand(for: pick.book)
    }

    private var overline: some View {
        HStack(spacing: Theme.Spacing.sm) {
            // Prefix bar — market-colored
            Rectangle()
                .fill(marketColor)
                .frame(width: 18, height: 1)

            // Market name in market color
            Text(pick.market.uppercased())
                .font(Theme.Font.overline(10))
                .tracking(2)
                .foregroundStyle(marketColor)

            if pick.book != nil {
                // Dot separator
                Text("·")
                    .font(Theme.Font.overline(10))
                    .foregroundStyle(Color.brandTextMuted)

                // Sportsbook logo (bundled PNG) or SF Symbol fallback
                if let asset = bookBrand.assetName,
                   let uiImage = UIImage(named: asset) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    Image(systemName: bookBrand.icon)
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(bookBrand.color)
                }

                Text(pick.book!.uppercased())
                    .font(Theme.Font.overline(10))
                    .tracking(2)
                    .foregroundStyle(bookBrand.color)
            }

            Spacer()
        }
    }

    // MARK: - Stats strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            edgeStat
            divider
            stat(
                value: pick.evPct.map { String(format: "+%.1f%%", $0) } ?? "—",
                label: "EV"
            )
            divider
            stat(
                value: String(format: "%.1f%%", pick.kellyFraction * 100),
                label: "KELLY"
            )
        }
    }

    /// EDGE stat with confidence-colored background tint to make the
    /// tier visually obvious (blue=high, amber=medium, dim=low).
    private var edgeStat: some View {
        let tierColor = Color.edgeColor(for: pick.confidenceTier)
        return VStack(spacing: 4) {
            Text(pick.edgePct.map { String(format: "+%.1f%%", $0) } ?? "—")
                .font(Theme.Font.data(15, weight: .semibold))
                .foregroundStyle(tierColor)
            Text("EDGE")
                .font(Theme.Font.overline(9))
                .tracking(1.5)
                .foregroundStyle(tierColor.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(tierColor.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.brandBorder)
            .frame(width: 1, height: 28)
    }

    private func stat(
        value: String,
        label: String,
        color: Color = .brandTextPrimary
    ) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Font.data(15, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(Theme.Font.overline(9))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Signals chips

    private var signalsRow: some View {
        HStack(spacing: Theme.Spacing.sm) {
            if pick.sharpSignal {
                chip(text: "SHARP", icon: "bolt.fill", color: .brandAmber)
            }
            if pick.pinnacleConfirms == true {
                chip(text: "PIN ✓", icon: "diamond.fill", color: .brandBlue)
            }
            Spacer()
        }
    }

    private func chip(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(text)
                .font(Theme.Font.overline(10))
                .tracking(1)
        }
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, 4)
        .foregroundStyle(color)
        .background(color.opacity(0.12))
        .overlay(
            Capsule().stroke(color.opacity(0.35), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }

    // MARK: - Footer

    @ViewBuilder
    private var footer: some View {
        if let outcome = pick.outcome {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.outcomeColor(for: outcome))
                    .frame(width: 7, height: 7)
                Text(outcome.uppercased())
                    .font(Theme.Font.overline(10))
                    .tracking(1.5)
                    .foregroundStyle(Color.outcomeColor(for: outcome))
                Spacer()
                if let gameTime = pick.gameTime {
                    Text(gameTime.asLocalGameTime)
                        .font(Theme.Font.data(11, weight: .regular))
                        .foregroundStyle(Color.brandTextMuted)
                }
            }
        } else if let gameTime = pick.gameTime {
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 9, weight: .medium))
                Text(gameTime.asLocalGameTime)
                    .font(Theme.Font.data(11, weight: .regular))
                Spacer()
            }
            .foregroundStyle(Color.brandTextMuted)
        }
    }

    // MARK: - Visual derivations

    /// High-edge picks get a faint blue glow + tinted border to draw the eye.
    /// Mirrors the web's `.high-confidence` rule.
    private var isHighEdge: Bool {
        pick.confidenceTier == .high
    }

    private var borderColor: Color {
        isHighEdge ? marketColor.opacity(0.35) : Color.brandBorder
    }

    private var borderWidth: CGFloat {
        isHighEdge ? 1.0 : 1.0
    }

    private var highEdgeShadow: Color {
        isHighEdge ? marketColor.opacity(0.18) : .clear
    }

    // MARK: - Helpers

    private func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }
}
