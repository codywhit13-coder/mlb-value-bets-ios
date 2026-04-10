//
//  BrandBackground.swift
//  MLBValueBets
//
//  The atmospheric background layer from mlbvaluebets.com, ported 1:1 to
//  SwiftUI. Three stacked layers sit behind every root view:
//
//    1. Navy-deep base fill (#060D1A)
//    2. Radial blue glow at the top — the "light source" that makes the
//       whole site feel cinematic
//    3. Radial amber glow bottom-right at ~8% alpha
//    4. 44pt grid of thin blue lines at ~6% alpha
//
//  This matches the web's `body::before` pseudo-element exactly. Alpha
//  values are tuned to read the same on OLED iPhones as on a laptop screen.
//
//  Usage:
//      ZStack {
//          BrandBackground()
//          // content
//      }
//

import SwiftUI

struct BrandBackground: View {
    var body: some View {
        ZStack {
            // Layer 1 — base color
            Color.brandBackground
                .ignoresSafeArea()

            // Layer 2 — top-center blue glow (the "light source")
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.brandBlue.opacity(0.20), location: 0.0),
                    .init(color: Color.brandBlue.opacity(0.10), location: 0.25),
                    .init(color: Color.brandBlue.opacity(0.03), location: 0.55),
                    .init(color: Color.clear,                    location: 1.0),
                ]),
                center: UnitPoint(x: 0.5, y: -0.05),
                startRadius: 0,
                endRadius: 900
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Layer 3 — bottom-right amber accent
            RadialGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.brandAmber.opacity(0.08), location: 0.0),
                    .init(color: Color.brandAmber.opacity(0.02), location: 0.4),
                    .init(color: Color.clear,                     location: 1.0),
                ]),
                center: UnitPoint(x: 0.85, y: 0.90),
                startRadius: 0,
                endRadius: 420
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // Layer 4 — 44pt blueprint grid
            BrandGrid()
                .stroke(Color.brandBlue.opacity(0.06), lineWidth: 0.5)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

/// 44pt square grid rendered as a single Shape path. Drawn once per layout,
/// cheap to rasterize, and scales with the screen.
private struct BrandGrid: Shape {
    var step: CGFloat = 44

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Vertical lines
        var x: CGFloat = 0
        while x <= rect.maxX {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += step
        }
        // Horizontal lines
        var y: CGFloat = 0
        while y <= rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += step
        }
        return path
    }
}

// MARK: - Convenience modifier

extension View {
    /// Drops a `BrandBackground` behind the receiver. Use at the root of
    /// every top-level screen so the atmosphere is consistent across the app.
    func brandBackground() -> some View {
        ZStack {
            BrandBackground()
            self
        }
    }
}

#Preview("BrandBackground") {
    ZStack {
        BrandBackground()
        VStack(spacing: 12) {
            Text("MLB VALUE BETS")
                .font(Theme.Font.display(32))
                .foregroundStyle(.white)
                .tracking(2)
            Text("12-5  ·  +14.2 units")
                .font(Theme.Font.data(18))
                .foregroundStyle(.white.opacity(0.7))
        }
    }
}
