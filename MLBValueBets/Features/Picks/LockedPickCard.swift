//
//  LockedPickCard.swift
//  MLBValueBets
//
//  Free-tier locked pick. Shows game + market but blurs the pick details.
//  Tapping "UPGRADE" opens the pricing page on mlbvaluebets.com.
//

import SwiftUI

struct LockedPickCard: View {
    let pick: Pick
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {

            // Overline — market-colored to match PickCard, but dimmed since
            // the pick itself is locked. Still gives visual rhythm in a mixed list.
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(MarketBrand.color(for: pick.market).opacity(0.5))
                    .frame(width: 18, height: 1)
                Text(pick.market.uppercased())
                    .font(Theme.Font.overline(10))
                    .tracking(2)
                    .foregroundStyle(MarketBrand.color(for: pick.market).opacity(0.5))
                Spacer()
            }

            // Game
            Text(pick.game)
                .font(Theme.Font.heading(15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .fixedSize(horizontal: false, vertical: true)

            // Locked panel
            ZStack {
                RoundedRectangle(cornerRadius: Theme.Radius.md)
                    .fill(Color.brandBackground.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .stroke(Color.brandBorder, lineWidth: 0.5)
                    )

                VStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color.brandAmber)
                    Text("PRO PICK")
                        .font(Theme.Font.overline(11))
                        .tracking(2)
                        .foregroundStyle(Color.brandTextPrimary)
                    Button {
                        HapticService.medium()
                        openURL(Config.upgradeURL)
                    } label: {
                        Text("UPGRADE")
                            .font(Theme.Font.overline(10))
                            .tracking(1.5)
                            .foregroundStyle(Color.brandAmber)
                            .padding(.horizontal, Theme.Spacing.lg)
                            .padding(.vertical, 6)
                            .background(Color.brandAmber.opacity(0.12))
                            .overlay(
                                Capsule().stroke(Color.brandAmber.opacity(0.40), lineWidth: 0.5)
                            )
                            .clipShape(Capsule())
                    }
                }
                .padding(.vertical, Theme.Spacing.md)
            }
            .frame(maxWidth: .infinity, minHeight: 124)
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
