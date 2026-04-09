//
//  Fixtures.swift
//  MLBValueBetsTests
//
//  Real and hand-crafted JSON payloads for Codable round-trip tests. The
//  three "live*" fixtures were captured from the production backend on
//  2026-04-09 via curl — treat them as the source of truth for what the iOS
//  decoder must accept.
//
//  The picks fixtures are hand-crafted to match the BetCandidate / PicksResponse
//  pydantic schemas in `web/models/schemas.py`, including every optional field
//  we care about (locked picks, settled picks with CLV, totals with modelTotal).
//
//  All fixtures use snake_case field names so they properly exercise the
//  `.convertFromSnakeCase` strategy the real APIClient uses.
//

import Foundation

enum Fixtures {

    // MARK: - Real backend responses (captured 2026-04-09)

    /// Real GET /health response. Simple, but proves status decoding works.
    static let healthJson = """
    {
        "status": "ok",
        "models_loaded": true,
        "scheduler_running": true
    }
    """

    /// Real GET /api/performance/live response.
    /// Note: backend returns several fields the iOS LivePerformance model
    /// doesn't know about (settled, win_rate, by_market, totals_by_side).
    /// The decoder must silently ignore them. It also does NOT return
    /// units_profit, start_date, or end_date — the iOS model marks those
    /// optional so they decode to nil.
    static let performanceLiveJson = """
    {
        "total_bets": 91,
        "settled": 91,
        "wins": 48,
        "losses": 43,
        "pushes": 0,
        "win_rate": 0.527,
        "roi": 0.103,
        "by_market": {
            "moneyline": {"wins": 21, "losses": 22, "pushes": 0, "total_bets": 43, "win_rate": 0.488, "roi": -0.01},
            "total": {"wins": 13, "losses": 8, "pushes": 0, "total_bets": 21, "win_rate": 0.619, "roi": 0.197},
            "runline": {"wins": 14, "losses": 13, "pushes": 0, "total_bets": 27, "win_rate": 0.519, "roi": 0.208}
        },
        "totals_by_side": {
            "over": {"wins": 11, "losses": 6, "pushes": 0, "total_bets": 17, "win_rate": 0.647, "roi": 0.253},
            "under": {"wins": 2, "losses": 2, "pushes": 0, "total_bets": 4, "win_rate": 0.5, "roi": -0.041}
        }
    }
    """

    /// Real GET /api/performance/summary response (backtest stats, 2021-2025).
    static let performanceSummaryJson = """
    {
        "moneyline_win_rate": 0.664,
        "moneyline_roi": 0.281,
        "totals_win_rate": 0.669,
        "totals_roi": 0.282,
        "runline_win_rate": 0.658,
        "runline_roi": 0.288,
        "backtest_period": "2021-2025",
        "kelly_cagr": 1.603,
        "kelly_start": 1000,
        "kelly_end": 119391
    }
    """

    // MARK: - Hand-crafted responses matching the pydantic schema

    /// Free-tier picks response: 2 unlocked picks + 1 locked placeholder,
    /// with 6 more behind the paywall. Exercises the locked-pick decode path
    /// (null optionals) and every BetCandidate field in at least one pick.
    static let picksTodayFreeJson = """
    {
        "date": "2026-04-09",
        "generated_at": "2026-04-09T10:30:00Z",
        "tier": "free",
        "total_bets": 3,
        "total_bets_all": 9,
        "total_bets_5pct": 2,
        "games_today": 12,
        "value_bets": [
            {
                "game": "New York Yankees @ Boston Red Sox",
                "market": "moneyline",
                "side": "New York Yankees",
                "model_prob": 0.604,
                "implied_prob": 0.479,
                "edge_pct": 12.54,
                "fair_odds": -153,
                "book_odds": 108,
                "kelly_fraction": 0.0424,
                "line_move": 7,
                "sharp_signal": true,
                "cross_book_spread": 12.5,
                "pinnacle_edge": 2.1,
                "pinnacle_confirms": true,
                "confidence": "high",
                "book": "FanDuel",
                "outcome": null,
                "locked": false,
                "value_bet": true,
                "game_time": "2026-04-09T23:05:00Z",
                "closing_odds": null,
                "clv_pct": null,
                "ev_pct": 6.18,
                "model_total": null
            },
            {
                "game": "Los Angeles Dodgers @ San Francisco Giants",
                "market": "total",
                "side": "O 8.5",
                "model_prob": 0.538,
                "implied_prob": 0.476,
                "edge_pct": 6.25,
                "fair_odds": -117,
                "book_odds": 105,
                "kelly_fraction": 0.0125,
                "line_move": 2,
                "sharp_signal": false,
                "cross_book_spread": 5.0,
                "pinnacle_edge": 0.8,
                "pinnacle_confirms": false,
                "confidence": "medium",
                "book": "DraftKings",
                "outcome": null,
                "locked": false,
                "value_bet": false,
                "game_time": "2026-04-09T22:40:00Z",
                "closing_odds": null,
                "clv_pct": null,
                "ev_pct": 2.95,
                "model_total": 9.1
            },
            {
                "game": "Philadelphia Phillies @ Atlanta Braves",
                "market": "moneyline",
                "side": "REDACTED",
                "model_prob": 0.0,
                "implied_prob": null,
                "edge_pct": null,
                "fair_odds": 0,
                "book_odds": null,
                "kelly_fraction": 0.0,
                "line_move": null,
                "sharp_signal": false,
                "cross_book_spread": null,
                "pinnacle_edge": null,
                "pinnacle_confirms": null,
                "confidence": null,
                "book": null,
                "outcome": null,
                "locked": true,
                "value_bet": false,
                "game_time": "2026-04-09T23:20:00Z",
                "closing_odds": null,
                "clv_pct": null,
                "ev_pct": null,
                "model_total": null
            }
        ]
    }
    """

    /// Settled-picks history (GET /api/picks/history?days=7). All picks have
    /// an outcome + closing_odds + clv_pct, which the today endpoint never
    /// returns. This exercises the CLV decode path and the settled-pick flag.
    static let picksHistoryJson = """
    [
        {
            "game": "Houston Astros @ Colorado Rockies",
            "market": "runline",
            "side": "Colorado Rockies +1.5",
            "model_prob": 0.657,
            "implied_prob": 0.571,
            "edge_pct": 8.63,
            "fair_odds": -191,
            "book_odds": -135,
            "kelly_fraction": 0.0312,
            "line_move": 4,
            "sharp_signal": true,
            "cross_book_spread": 8.0,
            "pinnacle_edge": 1.5,
            "pinnacle_confirms": true,
            "confidence": "high",
            "book": "BetMGM",
            "outcome": "win",
            "locked": false,
            "value_bet": true,
            "game_time": "2026-04-08T20:10:00Z",
            "closing_odds": -128,
            "clv_pct": 2.73,
            "ev_pct": 4.55,
            "model_total": null
        },
        {
            "game": "Chicago Cubs @ Milwaukee Brewers",
            "market": "moneyline",
            "side": "Chicago Cubs",
            "model_prob": 0.521,
            "implied_prob": 0.488,
            "edge_pct": 3.35,
            "fair_odds": -109,
            "book_odds": 105,
            "kelly_fraction": 0.0082,
            "line_move": -2,
            "sharp_signal": false,
            "cross_book_spread": 4.2,
            "pinnacle_edge": -0.3,
            "pinnacle_confirms": false,
            "confidence": "low",
            "book": "Caesars",
            "outcome": "loss",
            "locked": false,
            "value_bet": false,
            "game_time": "2026-04-07T23:40:00Z",
            "closing_odds": 115,
            "clv_pct": -0.95,
            "ev_pct": 1.34,
            "model_total": null
        },
        {
            "game": "Tampa Bay Rays @ Baltimore Orioles",
            "market": "total",
            "side": "U 7.5",
            "model_prob": 0.563,
            "implied_prob": 0.524,
            "edge_pct": 4.15,
            "fair_odds": -129,
            "book_odds": -110,
            "kelly_fraction": 0.0188,
            "line_move": 1,
            "sharp_signal": false,
            "cross_book_spread": 3.1,
            "pinnacle_edge": 0.6,
            "pinnacle_confirms": true,
            "confidence": "medium",
            "book": "FanDuel",
            "outcome": "push",
            "locked": false,
            "value_bet": false,
            "game_time": "2026-04-06T23:05:00Z",
            "closing_odds": -108,
            "clv_pct": 0.18,
            "ev_pct": 1.88,
            "model_total": 7.2
        }
    ]
    """

    // MARK: - Helper

    /// Decoder configured to match APIClient exactly. Tests that don't go
    /// through APIClient still need to match its behavior byte-for-byte.
    static func makeAPIDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Encoder configured to match APIClient exactly (snake_case keys).
    /// Used for round-trip tests where we re-encode and re-decode.
    static func makeAPIEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    /// Convert a JSON string to Data. Traps on invalid UTF-8, which should
    /// never happen since the strings are source code.
    static func data(_ json: String) -> Data {
        guard let data = json.data(using: .utf8) else {
            fatalError("Fixture JSON is not valid UTF-8")
        }
        return data
    }
}
