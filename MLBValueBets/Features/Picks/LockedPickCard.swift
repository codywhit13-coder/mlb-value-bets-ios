//
//  LockedPickCard.swift
//  MLBValueBets
//
//  Free-tier locked pick. Shows game + market but blurs the pick details.
//  NOTE: No tappable upgrade link (App Store Reader App rule).
//

import SwiftUI

struct LockedPickCard: View {
    let pick: Pick
    @State private var showInfo: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // Header row
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

            // Blurred body
            ZStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommended Bet")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(Color.brandTextMuted)
                    Text("████████")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.brandTextPrimary)
                    HStack(spacing: 16) {
                        Text("+██.██%")
                        Text("+██.██%")
                        Text("████")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brandTextMuted)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .blur(radius: 6)

                VStack(spacing: 8) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.brandAmber)
                    Text("Pro pick")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.brandTextPrimary)
                    Button("How to unlock") { showInfo = true }
                        .font(.caption2)
                        .foregroundStyle(Color.brandTextSecondary)
                }
            }
            .padding(.vertical, 6)
        }
        .padding(14)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
        .alert("Unlock More Picks", isPresented: $showInfo) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Full access to every pick, every day is available through your account on mlbvaluebets.com.")
        }
    }
}
