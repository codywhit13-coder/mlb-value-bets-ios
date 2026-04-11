//
//  LockedPickCard.swift
//  MLBValueBets
//
//  Free-tier locked pick. Shows the game + market with redacted pick
//  details (side, odds, stats) to tease what Pro unlocks. Tapping the
//  upgrade banner opens the pricing page on mlbvaluebets.com.
//

import SwiftUI

struct LockedPickCard: View {
    let pick: Pick
    @Environment(\.openURL) private var openURL

    private var marketColor: Color {
        MarketBrand.color(for: pick.market)
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left accent stripe — market-colored, dimmed for locked state
            Rectangle()
                .fill(marketColor.opacity(0.4))
                .frame(width: 3)

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {

                // 1. Overline — market-colored, dimmed
                HStack(spacing: Theme.Spacing.sm) {
                    Rectangle()
                        .fill(marketColor.opacity(0.5))
                        .frame(width: 18, height: 1)
                    Text(pick.market.uppercased())
                        .font(Theme.Font.overline(10))
                        .tracking(2)
                        .foregroundStyle(marketColor.opacity(0.5))
                    Spacer()
                    // Lock badge
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8, weight: .bold))
                        Text("PRO")
                            .font(Theme.Font.overline(9))
                            .tracking(1.5)
                    }
                    .foregroundStyle(Color.brandAmber)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 3)
                    .background(Color.brandAmber.opacity(0.12))
                    .clipShape(Capsule())
                }

                // 2. Game matchup (visible)
                Text(pick.game)
                    .font(Theme.Font.heading(15, weight: .semibold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                    .fixedSize(horizontal: false, vertical: true)

                // 3. Redacted side + odds row
                HStack(alignment: .center) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brandTextMuted.opacity(0.12))
                        .frame(width: 120, height: 18)
                    Spacer(minLength: Theme.Spacing.sm)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.brandTextMuted.opacity(0.12))
                        .frame(width: 56, height: 22)
                }

                // Hairline
                Rectangle()
                    .fill(Color.brandBorder)
                    .frame(height: 1)
                    .padding(.vertical, Theme.Spacing.xxs)

                // 4. Redacted stats strip
                HStack(spacing: 0) {
                    redactedStat(label: "EDGE")
                    Rectangle()
                        .fill(Color.brandBorder)
                        .frame(width: 1, height: 24)
                    redactedStat(label: "EV")
                    Rectangle()
                        .fill(Color.brandBorder)
                        .frame(width: 1, height: 24)
                    redactedStat(label: "KELLY")
                }

                // 5. Upgrade banner
                Button {
                    HapticService.medium()
                    openURL(Config.upgradeURL)
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "lock.open.fill")
                            .font(.system(size: 11, weight: .bold))
                        Text("UNLOCK WITH PRO")
                            .font(Theme.Font.heading(12, weight: .bold))
                            .tracking(1.5)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(Color.brandAmber)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm + 2)
                    .background(Color.brandAmber.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.sm)
                            .stroke(Color.brandAmber.opacity(0.25), lineWidth: 0.5)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(
            ZStack {
                Color.brandSurface
                marketColor.opacity(0.02)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandAmber.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: Color.brandAmber.opacity(0.06), radius: 16, x: 0, y: 0)
    }

    // MARK: - Helpers

    private func redactedStat(label: String) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.brandTextMuted.opacity(0.10))
                .frame(width: 40, height: 13)
            Text(label)
                .font(Theme.Font.overline(9))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextMuted.opacity(0.35))
        }
        .frame(maxWidth: .infinity)
    }
}
