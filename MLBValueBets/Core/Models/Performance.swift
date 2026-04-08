//
//  Performance.swift
//  MLBValueBets
//
//  Response types for /api/performance/* endpoints.
//

import Foundation

// MARK: - /api/performance/summary (backtest stats, public)
struct PerformanceSummary: Codable {
    let moneylineWinRate: Double
    let moneylineRoi: Double
    let totalsWinRate: Double
    let totalsRoi: Double
    let runlineWinRate: Double
    let runlineRoi: Double
    let backtestPeriod: String
    let kellyCagr: Double
    let kellyStart: Int
    let kellyEnd: Int
}

// MARK: - /api/performance/live (season-to-date record, public)
struct LivePerformance: Codable {
    let wins: Int
    let losses: Int
    let pushes: Int
    let roi: Double?
    let unitsProfit: Double?
    let totalBets: Int?
    let startDate: String?
    let endDate: String?

    var totalSettled: Int { wins + losses + pushes }

    var winRate: Double {
        let decisive = wins + losses
        guard decisive > 0 else { return 0 }
        return Double(wins) / Double(decisive)
    }

    var displayRecord: String {
        if pushes > 0 { return "\(wins)-\(losses)-\(pushes)" }
        return "\(wins)-\(losses)"
    }
}

// MARK: - /api/performance/clv (sharpness vs closing line, public)
struct CLVReport: Codable {
    let avgClvPct: Double?
    let positiveClvRate: Double?
    let sampleSize: Int?
}
