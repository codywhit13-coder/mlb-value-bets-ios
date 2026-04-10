//
//  SharePickView.swift
//  MLBValueBets
//
//  Branded card rendered as an image for social sharing. Simplified layout
//  compared to PickCard — optimized for readability in a 360pt-wide PNG
//  shared to iMessage, Twitter, Instagram stories, etc.
//
//  Layout:
//    1. Header branding — "VALUE BETS" + mlbvaluebets.com
//    2. Matchup — game name + market overline
//    3. Side + odds — the pick itself, large type
//    4. Stats strip — EDGE / EV / KELLY
//    5. Signals chip row (if present)
//    6. Footer — game time + confidence tier badge
//
//  This view is never displayed directly — it's rendered offscreen via
//  SharePickService using ImageRenderer.
//

import SwiftUI

struct SharePickView: View {
    let pick: Pick

    /// Fixed width for consistent image output across devices.
    static let renderWidth: CGFloat = 360

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {

            // 1. Header branding
            header

            // Hairline
            Rectangle()
                .fill(Color.brandBorder)
                .frame(height: 1)

            // 2. Market overline
            HStack(spacing: 6) {
                Rectangle()
                    .fill(marketColor)
                    .frame(width: 18, height: 1)
                Text(pick.market.uppercased())
                    .font(Theme.Font.overline(10))
                    .tracking(2)
                    .foregroundStyle(marketColor)
                if let book = pick.book {
                    Text("·")
                        .font(Theme.Font.overline(10))
                        .foregroundStyle(Color.brandTextMuted)
                    Text(book.uppercased())
                        .font(Theme.Font.overline(10))
                        .tracking(2)
                        .foregroundStyle(Color.brandTextMuted)
                }
                Spacer()
            }

            // 3. Matchup
            Text(pick.game)
                .font(Theme.Font.heading(15, weight: .semibold))
                .foregroundStyle(Color.brandTextPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            // 4. Side + odds
            HStack(alignment: .center) {
                Text(pick.side)
                    .font(Theme.Font.heading(20, weight: .bold))
                    .foregroundStyle(Color.brandTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer(minLength: 8)
                Text(pick.bookOdds.map(formatOdds) ?? "—")
                    .font(Theme.Font.display(32))
                    .foregroundStyle(Color.brandBlue)
                    .tracking(1)
            }

            // Hairline
            Rectangle()
                .fill(Color.brandBorder)
                .frame(height: 1)

            // 5. Stats strip
            statsStrip

            // 6. Signals (if present)
            if pick.sharpSignal || (pick.pinnacleConfirms ?? false) {
                signalsRow
            }

            // 7. Footer
            footer
        }
        .padding(20)
        .frame(width: Self.renderWidth)
        .background(
            ZStack {
                Color.brandBackground
                // Subtle blue glow at top — echoes the full BrandBackground
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.brandBlue.opacity(0.15), location: 0.0),
                        .init(color: Color.clear, location: 1.0),
                    ]),
                    center: UnitPoint(x: 0.5, y: 0.0),
                    startRadius: 0,
                    endRadius: 300
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("VALUE BETS")
                    .font(Theme.Font.display(20))
                    .foregroundStyle(Color.brandTextPrimary)
                    .tracking(1)
                Text("mlbvaluebets.com")
                    .font(Theme.Font.overline(9))
                    .tracking(1)
                    .foregroundStyle(Color.brandBlue)
            }
            Spacer()
            // Confidence tier badge
            Text(tierLabel.uppercased())
                .font(Theme.Font.overline(9))
                .tracking(1.5)
                .foregroundStyle(tierColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(tierColor.opacity(0.15))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(tierColor.opacity(0.40), lineWidth: 0.5)
                )
        }
    }

    // MARK: - Stats strip

    private var statsStrip: some View {
        HStack(spacing: 0) {
            statCell(
                value: pick.edgePct.map { String(format: "+%.1f%%", $0) } ?? "—",
                label: "EDGE",
                color: Color.edgeColor(for: pick.confidenceTier)
            )
            Rectangle()
                .fill(Color.brandBorder)
                .frame(width: 1, height: 28)
            statCell(
                value: pick.evPct.map { String(format: "+%.1f%%", $0) } ?? "—",
                label: "EV"
            )
            Rectangle()
                .fill(Color.brandBorder)
                .frame(width: 1, height: 28)
            statCell(
                value: String(format: "%.1f%%", pick.kellyFraction * 100),
                label: "KELLY"
            )
        }
    }

    private func statCell(
        value: String,
        label: String,
        color: Color = .brandTextPrimary
    ) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(Theme.Font.data(14, weight: .semibold))
                .foregroundStyle(color)
            Text(label)
                .font(Theme.Font.overline(8))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextMuted)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Signals

    private var signalsRow: some View {
        HStack(spacing: 8) {
            if pick.sharpSignal {
                signalChip(text: "SHARP", icon: "bolt.fill", color: .brandAmber)
            }
            if pick.pinnacleConfirms == true {
                signalChip(text: "PIN ✓", icon: "diamond.fill", color: .brandBlue)
            }
            Spacer()
        }
    }

    private func signalChip(text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8, weight: .bold))
            Text(text)
                .font(Theme.Font.overline(9))
                .tracking(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .foregroundStyle(color)
        .background(color.opacity(0.12))
        .overlay(
            Capsule().stroke(color.opacity(0.35), lineWidth: 0.5)
        )
        .clipShape(Capsule())
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            if let gameTime = pick.gameTime {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 8, weight: .medium))
                    Text(gameTime.asLocalGameTime)
                        .font(Theme.Font.data(10, weight: .regular))
                }
                .foregroundStyle(Color.brandTextMuted)
            }
            Spacer()
            Text("Download the app →")
                .font(Theme.Font.overline(8))
                .tracking(1)
                .foregroundStyle(Color.brandBlue)
        }
    }

    // MARK: - Helpers

    private var marketColor: Color {
        MarketBrand.color(for: pick.market)
    }

    private var tierLabel: String {
        (pick.confidence ?? pick.confidenceTier.rawValue)
    }

    private var tierColor: Color {
        Color.edgeColor(for: pick.confidenceTier)
    }

    private func formatOdds(_ odds: Int) -> String {
        odds > 0 ? "+\(odds)" : "\(odds)"
    }
}
