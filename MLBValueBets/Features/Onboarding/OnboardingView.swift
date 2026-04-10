//
//  OnboardingView.swift
//  MLBValueBets
//
//  First-launch walkthrough — 4 paged screens explaining what the app
//  does, how picks work, what the metrics mean, and a CTA to sign in.
//  Only shown once, gated by @AppStorage("hasSeenOnboarding").
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage: Int = 0
    private let pages = OnboardingPage.pages

    var body: some View {
        ZStack {
            BrandBackground()

            VStack(spacing: 0) {
                // Paged content
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        pageView(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Custom page indicator + button
                bottomBar
                    .padding(.horizontal, Theme.Spacing.lg)
                    .padding(.bottom, Theme.Spacing.xxl)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Page Content

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()

            // Icon in tinted circle
            Image(systemName: page.icon)
                .font(.system(size: 36, weight: .medium))
                .foregroundStyle(page.accentColor)
                .frame(width: 88, height: 88)
                .background(page.accentColor.opacity(0.10))
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(page.accentColor.opacity(0.30), lineWidth: 1)
                )

            // Headline
            Text(page.headline)
                .font(Theme.Font.display(36))
                .tracking(1.5)
                .foregroundStyle(Color.brandTextPrimary)
                .multilineTextAlignment(.center)

            // Body
            Text(page.body)
                .font(Theme.Font.body(15))
                .foregroundStyle(Color.brandTextSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, Theme.Spacing.lg)

            Spacer()
            Spacer()
        }
        .padding(.horizontal, Theme.Spacing.lg)
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: Theme.Spacing.lg) {
            // Page dots
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(pages) { page in
                    Circle()
                        .fill(page.id == currentPage ? Color.brandBlue : Color.brandTextMuted)
                        .frame(
                            width: page.id == currentPage ? 8 : 6,
                            height: page.id == currentPage ? 8 : 6
                        )
                        .animation(.easeInOut(duration: 0.2), value: currentPage)
                }
            }

            // Button: "NEXT" or "SIGN IN" on last page
            if currentPage == pages.count - 1 {
                Button {
                    HapticService.medium()
                    onComplete()
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text("SIGN IN")
                            .font(Theme.Font.heading(14, weight: .bold))
                            .tracking(1.5)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md + 2)
                    .background(Color.brandBlue)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
                }
                .buttonStyle(.plain)
            } else {
                Button {
                    HapticService.light()
                    withAnimation { currentPage += 1 }
                } label: {
                    HStack(spacing: Theme.Spacing.sm) {
                        Text("NEXT")
                            .font(Theme.Font.heading(14, weight: .bold))
                            .tracking(1.5)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(Color.brandBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.md + 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.Radius.md)
                            .stroke(Color.brandBlue.opacity(0.6), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }

            // Skip on non-last pages
            if currentPage < pages.count - 1 {
                Button {
                    HapticService.light()
                    onComplete()
                } label: {
                    Text("SKIP")
                        .font(Theme.Font.overline(11))
                        .tracking(1.5)
                        .foregroundStyle(Color.brandTextMuted)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
