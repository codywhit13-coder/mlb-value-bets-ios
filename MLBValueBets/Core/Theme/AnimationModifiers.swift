//
//  AnimationModifiers.swift
//  MLBValueBets
//
//  Reusable animation modifiers for card entrance transitions and
//  tap feedback. Uses Theme.Motion values for consistent feel.
//

import SwiftUI

// MARK: - Staggered Appearance

/// Fades and slides up a card after a stagger delay based on index.
/// Automatically skips the delay in test environments so snapshot
/// tests capture the final (visible) state.
struct StaggeredAppearance: ViewModifier {
    let index: Int
    @State private var hasAppeared = false

    private var isTest: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .onAppear {
                if isTest {
                    // Immediately visible in snapshot tests
                    hasAppeared = true
                } else {
                    let delay = Double(index) * 0.05
                    withAnimation(Theme.Motion.fadeUp.delay(delay)) {
                        hasAppeared = true
                    }
                }
            }
    }
}

extension View {
    /// Stagger-animates this view into place based on its position in a list.
    func staggeredAppearance(index: Int) -> some View {
        modifier(StaggeredAppearance(index: index))
    }
}

// MARK: - Card Press Style

/// Subtle scale-down on press for NavigationLinks wrapping cards.
/// Replaces `.buttonStyle(.plain)` on card links.
struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.Motion.tap, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == CardPressStyle {
    static var card: CardPressStyle { CardPressStyle() }
}

// MARK: - Pulse Dot

/// A small circle that pulses with the brand glow animation.
/// Used for the "LIVE" indicator on the dashboard record strip.
struct PulseDot: View {
    let color: Color
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 6, height: 6)
            .opacity(isPulsing ? 0.4 : 1.0)
            .onAppear {
                withAnimation(Theme.Motion.glow) {
                    isPulsing = true
                }
            }
    }
}
