//
//  OnboardingPage.swift
//  MLBValueBets
//
//  Data model for onboarding walkthrough pages. Each page has an
//  SF Symbol, headline, body text, and accent color.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id: Int
    let icon: String          // SF Symbol name
    let headline: String      // Bebas Neue display
    let body: String          // Barlow body text
    let accentColor: Color

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            icon: "chart.line.uptrend.xyaxis",
            headline: "FIND THE BETS\nTHE MARKET GOT WRONG",
            body: "A probability model scans every MLB game, every morning. When the true win probability beats the sportsbook odds — that's a value bet.",
            accentColor: .brandBlue
        ),
        OnboardingPage(
            id: 1,
            icon: "brain",
            headline: "MODEL-BACKED\nPICKS DAILY",
            body: "No gut calls, no touts. Every pick shows the model's math: win probability, implied odds, and the exact edge over the books.",
            accentColor: .brandAmber
        ),
        OnboardingPage(
            id: 2,
            icon: "percent",
            headline: "EDGE, EV\n& KELLY",
            body: "Edge is how much the model disagrees with the books. EV is expected profit per bet. Kelly is the optimal stake size based on your bankroll.",
            accentColor: .brandBlue
        ),
        OnboardingPage(
            id: 3,
            icon: "arrow.right.circle.fill",
            headline: "READY\nTO START",
            body: "66.4% moneyline win rate. +28.3% ROI. Five years of verified backtesting. Sign in with your mlbvaluebets.com account to get started.",
            accentColor: .brandAmber
        ),
    ]
}
