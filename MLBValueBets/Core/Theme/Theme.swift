//
//  Theme.swift
//  MLBValueBets
//
//  The design system in one place. Everything visual — typography, spacing,
//  corner radii, motion — flows through `Theme.*` so we can tune the look of
//  the whole app by editing this file.
//
//  Colors live in Color+Theme.swift (SwiftUI `Color` extensions) because
//  that's where every existing view imports them from. Keeping colors there
//  is deliberate: `Theme.Color` would fight with SwiftUI's own `Color` type
//  at every use site.
//
//  Source of truth is the web frontend (frontend/src/index.css + tailwind.config.js).
//  The goal is visual parity with mlbvaluebets.com on iOS, not a divergent
//  iOS-specific vocabulary.
//

import SwiftUI

enum Theme {

    // MARK: - Typography
    //
    // Three families:
    //   Bebas Neue (display)  — huge numerals, condensed uppercase titles
    //   Barlow (UI)           — body text, buttons, labels. Barlow Condensed
    //                           is not bundled; Barlow Bold handles condensed
    //                           roles by relying on weight alone.
    //   IBM Plex Mono (data)  — odds, percentages, anything that needs to
    //                           align in columns. Uses `.monospacedDigit()`.
    //
    // Each helper returns a `Font`, not a `Text` modifier, so callers can
    // still compose: `.font(Theme.Font.data(18)).foregroundStyle(.white)`.

    enum Font {
        /// Big poster/display numerals. Bebas Neue is single-weight.
        static func display(_ size: CGFloat) -> SwiftUI.Font {
            .custom("BebasNeue-Regular", size: size)
        }

        /// Section headers, card titles, CTA labels. Default weight .semibold.
        static func heading(
            _ size: CGFloat,
            weight: SwiftUI.Font.Weight = .semibold
        ) -> SwiftUI.Font {
            .custom(barlowFileName(for: weight), size: size)
        }

        /// Body copy, form fields, secondary labels. Default weight .regular.
        static func body(
            _ size: CGFloat,
            weight: SwiftUI.Font.Weight = .regular
        ) -> SwiftUI.Font {
            .custom(barlowFileName(for: weight), size: size)
        }

        /// Numeric data that must align across rows (odds, edge %, ROI).
        /// `.monospacedDigit()` is a no-op on a font that's already mono,
        /// but we keep it for safety in case a caller tweaks the size.
        static func data(
            _ size: CGFloat,
            weight: SwiftUI.Font.Weight = .medium
        ) -> SwiftUI.Font {
            .custom(plexMonoFileName(for: weight), size: size).monospacedDigit()
        }

        /// Section labels — tracked, uppercased, small. Matches the web's
        /// `.section-label` class. Use with `.tracking(2)` at the call site
        /// and wrap your string with `.uppercased()`.
        static func overline(_ size: CGFloat = 11) -> SwiftUI.Font {
            .custom("IBMPlexMono-Medium", size: size)
        }

        // Weight -> PostScript file name mapping. PostScript names for
        // bundled fonts match the filename we ship (no spaces).
        private static func barlowFileName(for weight: SwiftUI.Font.Weight) -> String {
            switch weight {
            case .bold, .heavy, .black:         return "Barlow-Bold"
            case .semibold:                     return "Barlow-SemiBold"
            case .medium:                       return "Barlow-Medium"
            default:                            return "Barlow-Regular"
            }
        }

        private static func plexMonoFileName(for weight: SwiftUI.Font.Weight) -> String {
            switch weight {
            case .bold, .heavy, .black:         return "IBMPlexMono-Bold"
            case .semibold, .medium:            return "IBMPlexMono-Medium"
            default:                            return "IBMPlexMono-Regular"
            }
        }
    }

    // MARK: - Spacing
    //
    // Multiples of 4pt. Match the web's Tailwind spacing scale where possible
    // (Tailwind 1 = 4px, 2 = 8px, 3 = 12px, 4 = 16px, 6 = 24px, 8 = 32px).

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs:  CGFloat = 4
        static let sm:  CGFloat = 8
        static let md:  CGFloat = 12
        static let lg:  CGFloat = 16
        static let xl:  CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Corner radii

    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
    }

    // MARK: - Border widths

    enum Border {
        static let hairline: CGFloat = 0.5
        static let thin: CGFloat = 1
        static let thick: CGFloat = 2
    }

    // MARK: - Motion
    //
    // Centralized animation curves keep the whole app moving in lockstep.
    // The web uses `cubic-bezier(0.22, 1, 0.36, 1)` for its reveal animation
    // (1.1 seconds, staggered). SwiftUI's closest equivalent is a tuned spring.

    enum Motion {
        /// Hero reveal — new content sliding up and fading in. Longer duration
        /// because it's the first thing users see on Dashboard load.
        static let fadeUp: Animation = .spring(response: 0.65, dampingFraction: 0.82, blendDuration: 0)

        /// Snappy interaction response — filter chip selection, tab swap.
        static let spring: Animation = .spring(response: 0.35, dampingFraction: 0.78, blendDuration: 0)

        /// Gentle glow/pulse loops. Used for the live dot and ctaGlow.
        static let glow: Animation = .easeInOut(duration: 1.6).repeatForever(autoreverses: true)

        /// Short-lived state change — tap press, haptic flash. Matches Apple's
        /// default 200ms UI response window.
        static let tap: Animation = .easeInOut(duration: 0.2)
    }
}
