//
//  LoadingStates.swift
//  MLBValueBets
//
//  Reusable loading / empty / error primitives that every feature screen
//  can drop in. Visual vocabulary matches the design system (atmospheric
//  background, blue overlines, Bebas display, mono data).
//
//  - `PickCardSkeleton`      — shimmering placeholder shaped like a PickCard
//  - `LiveRecordSkeleton`    — shimmering placeholder for the dashboard strip
//  - `EmptyStateView`        — "NO PICKS TODAY" panel + action button
//  - `ErrorStateCard`        — tinted red card with message + "TRY AGAIN"
//
//  All three are pure SwiftUI and deterministic — the shimmer is driven by
//  a single `@State Double` so snapshot tests can fix a phase if needed.
//

import SwiftUI

// MARK: - Shimmer

/// A diagonal sweep that paints across its container. The gradient runs
/// on `Theme.Motion.glow` so the whole app pulses in lockstep.
private struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1.0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    let w = geo.size.width
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.00), location: 0.00),
                            .init(color: .white.opacity(0.08), location: 0.45),
                            .init(color: .white.opacity(0.16), location: 0.50),
                            .init(color: .white.opacity(0.08), location: 0.55),
                            .init(color: .white.opacity(0.00), location: 1.00)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: w * 1.8)
                    .offset(x: phase * w * 1.8)
                    .blendMode(.plusLighter)
                }
                .mask(content)
            )
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

private extension View {
    func shimmering() -> some View { modifier(Shimmer()) }
}

/// A solid dim rectangle used as the base of every skeleton block.
private struct SkeletonBlock: View {
    var height: CGFloat
    var width: CGFloat? = nil
    var radius: CGFloat = Theme.Radius.sm

    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(Color.brandHover)
            .frame(width: width, height: height)
    }
}

// MARK: - PickCardSkeleton

/// A placeholder shaped like `PickCard`. Matches the real card's padding,
/// section rhythm, and overall height so the swap from skeleton → real
/// content doesn't shift the layout.
struct PickCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Overline — blue prefix bar + short label
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue.opacity(0.6))
                    .frame(width: 18, height: 1)
                SkeletonBlock(height: 8, width: 120)
                Spacer()
            }

            // Matchup line
            SkeletonBlock(height: 14, width: 220)

            // Side + odds row
            HStack(alignment: .firstTextBaseline) {
                SkeletonBlock(height: 18, width: 140)
                Spacer()
                SkeletonBlock(height: 22, width: 64)
            }

            // Hairline separator
            Rectangle()
                .fill(Color.brandBorder)
                .frame(height: 1)
                .padding(.vertical, Theme.Spacing.xxs)

            // Stats strip — 3 columns
            HStack(spacing: 0) {
                skeletonStat
                Rectangle()
                    .fill(Color.brandBorder)
                    .frame(width: 1, height: 28)
                skeletonStat
                Rectangle()
                    .fill(Color.brandBorder)
                    .frame(width: 1, height: 28)
                skeletonStat
            }

            // Footer — clock line
            SkeletonBlock(height: 10, width: 90)
                .padding(.top, Theme.Spacing.xxs)
        }
        .padding(Theme.Spacing.lg)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
        .shimmering()
        .accessibilityHidden(true)
    }

    private var skeletonStat: some View {
        VStack(spacing: 4) {
            SkeletonBlock(height: 14, width: 50)
            SkeletonBlock(height: 8, width: 32)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - LiveRecordSkeleton

/// Placeholder for the Dashboard's "LIVE RECORD" strip.
struct LiveRecordSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            HStack(spacing: Theme.Spacing.sm) {
                Circle()
                    .fill(Color.brandBlue.opacity(0.4))
                    .frame(width: 6, height: 6)
                SkeletonBlock(height: 8, width: 90)
                Spacer()
            }
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                skeletonMetric
                Spacer()
                skeletonMetric
                Spacer()
                skeletonMetric
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(Color.brandSurface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
        .shimmering()
        .accessibilityHidden(true)
    }

    private var skeletonMetric: some View {
        VStack(alignment: .leading, spacing: 6) {
            SkeletonBlock(height: 24, width: 72)
            SkeletonBlock(height: 8, width: 40)
        }
    }
}

// MARK: - EmptyStateView

/// Neutral empty state — used when a list has nothing to show but there
/// was no error. The action button is optional; when present it appears
/// as a blue-bordered "REFRESH" / "TRY ANOTHER FILTER" pill.
struct EmptyStateView: View {
    let headline: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Blue overline bar
            HStack(spacing: Theme.Spacing.sm) {
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
                Text("NO DATA")
                    .font(Theme.Font.overline(10))
                    .tracking(2)
                    .foregroundStyle(Color.brandBlue)
                Rectangle()
                    .fill(Color.brandBlue)
                    .frame(width: 24, height: 1)
            }

            // Icon in a tinted circle
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(Color.brandBlue)
                .frame(width: 72, height: 72)
                .background(Color.brandBlue.opacity(0.08))
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.brandBlue.opacity(0.25), lineWidth: 0.5)
                )

            // Headline
            Text(headline.uppercased())
                .font(Theme.Font.display(28))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)
                .multilineTextAlignment(.center)

            // Body copy
            Text(message)
                .font(Theme.Font.body(13))
                .foregroundStyle(Color.brandTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            // Optional action
            if let title = actionTitle, let action = action {
                Button {
                    action()
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .bold))
                        Text(title.uppercased())
                            .font(Theme.Font.heading(12, weight: .bold))
                            .tracking(1.5)
                    }
                    .foregroundStyle(Color.brandBlue)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.sm + 2)
                    .overlay(
                        Capsule().stroke(Color.brandBlue.opacity(0.6), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .background(Color.brandSurface.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.brandBorder, lineWidth: 1)
        )
    }
}

// MARK: - StaleBanner

/// Thin banner showing how old the cached data is. Appears above the
/// content area when the last successful fetch was more than ~30 seconds
/// ago (i.e. the data came from cache or a refresh failed silently).
struct StaleBanner: View {
    let cachedAt: Date

    private static let formatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 10, weight: .medium))
            Text("Last updated \(Self.formatter.localizedString(for: cachedAt, relativeTo: Date()))")
                .font(Theme.Font.overline(10))
                .tracking(0.5)
            Spacer()
        }
        .foregroundStyle(Color.brandTextMuted)
        .padding(.horizontal, Theme.Spacing.lg)
        .padding(.vertical, Theme.Spacing.sm)
        .background(Color.brandSurfaceMid)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
    }
}

// MARK: - ErrorStateCard

/// Red-tinted error panel with a retry button. Used anywhere a request
/// can fail — the message string comes straight from `APIError`.
struct ErrorStateCard: View {
    let message: String
    var icon: String = "exclamationmark.triangle.fill"
    var actionTitle: String = "TRY AGAIN"
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {

            HStack(spacing: Theme.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.lossRed)
                Text("COULDN'T LOAD PICKS")
                    .font(Theme.Font.overline(11))
                    .tracking(2)
                    .foregroundStyle(Color.lossRed)
                Spacer()
            }

            Text(message)
                .font(Theme.Font.body(13))
                .foregroundStyle(Color.brandTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let action = action {
                Button {
                    action()
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12, weight: .bold))
                        Text(actionTitle)
                            .font(Theme.Font.heading(12, weight: .bold))
                            .tracking(1.5)
                    }
                    .foregroundStyle(Color.lossRed)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.vertical, Theme.Spacing.sm)
                    .overlay(
                        Capsule().stroke(Color.lossRed.opacity(0.6), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, Theme.Spacing.xs)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lossRed.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.lg)
                .stroke(Color.lossRed.opacity(0.30), lineWidth: 1)
        )
    }
}
