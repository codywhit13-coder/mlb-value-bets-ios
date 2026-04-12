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
    var isPro: Bool = true

    var body: some View {
        HStack(spacing: 0) {
            // Left accent stripe — instant market identification
            Rectangle()
                .fill(marketColor)
                .frame(width: 3)

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

                // 5. Signals chips + confidence pill
                signalsRow
                    .padding(.top, Theme.Spacing.xxs)

                // 5b. Pre-lineup notice (unsettled + lineups not posted)
                if pick.outcome == nil && !(pick.lineupConfirmed ?? true) {
                    preLineupBanner
                }

                // 6. Footer — outcome (if settled) or game time
                footer
                    .padding(.top, Theme.Spacing.xxs)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(
            ZStack {
                Color.brandSurface
                marketColor.opacity(0.03)
            }
        )
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
            stat(
                value: pick.edgePct.map { String(format: "+%.1f%%", $0) } ?? "—",
                label: "EDGE",
                color: Color.edgeColor(for: pick.confidenceTier),
                blurred: !isPro
            )
            divider
            stat(
                value: String(format: "%.1f%%", pick.modelProb * 100),
                label: "MODEL %",
                blurred: !isPro
            )
            divider
            stat(
                value: pick.evPct.map { String(format: "+%.1f%%", $0) } ?? "—",
                label: "EV %",
                blurred: !isPro
            )
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.brandBorder)
            .frame(width: 1, height: 28)
    }

    private func stat(
        value: String,
        label: String,
        color: Color = .brandTextPrimary,
        blurred: Bool = false
    ) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(Theme.Font.data(15, weight: .semibold))
                .foregroundStyle(color)
                .blur(radius: blurred ? 6 : 0)
                .allowsHitTesting(!blurred)
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
            // Confidence pill always first
            confidenceChip
            // Sharp + Pinnacle signals are Pro-only
            if isPro {
                if pick.sharpSignal {
                    chip(text: "SHARP", icon: "bolt.fill", color: .brandAmber)
                }
                if pick.pinnacleConfirms == true {
                    chip(text: "PIN ✓", icon: "diamond.fill", color: .brandBlue)
                }
            }
            Spacer()
        }
    }

    @ViewBuilder
    private var confidenceChip: some View {
        switch pick.confidenceTier {
        case .high:
            // Green gradient "VALUE" badge — matches web's pulsing value badge
            HStack(spacing: 4) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 9, weight: .bold))
                Text("VALUE")
                    .font(Theme.Font.overline(10))
                    .tracking(1)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.133, green: 0.773, blue: 0.369), Color(red: 0.082, green: 0.502, blue: 0.239)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .shadow(color: Color(red: 0.133, green: 0.773, blue: 0.369).opacity(0.40), radius: 8, x: 0, y: 0)

        case .medium:
            // Amber gradient "MEDIUM" badge
            HStack(spacing: 4) {
                Image(systemName: "equal")
                    .font(.system(size: 9, weight: .bold))
                Text("MEDIUM")
                    .font(Theme.Font.overline(10))
                    .tracking(1)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .foregroundStyle(.white)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.961, green: 0.651, blue: 0.137), Color(red: 0.706, green: 0.471, blue: 0.078)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 6))

        case .low:
            // Translucent "LOW" badge — muted like the web
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.right")
                    .font(.system(size: 9, weight: .bold))
                Text("LOW")
                    .font(Theme.Font.overline(10))
                    .tracking(1)
            }
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 4)
            .foregroundStyle(Color.white.opacity(0.55))
            .background(Color.white.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 6))

        case .none:
            EmptyView()
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
        .clipShape(Capsule())
    }

    // MARK: - Pre-lineup banner

    private var preLineupBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 10, weight: .semibold))
            Text("Edge may shift after lineups are posted")
                .font(Theme.Font.data(11, weight: .medium))
        }
        .foregroundStyle(Color.brandAmber)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brandAmber.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
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
