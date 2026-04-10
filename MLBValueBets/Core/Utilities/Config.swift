//
//  Config.swift
//  MLBValueBets
//
//  Central configuration for Supabase + backend API.
//  These are all PUBLIC values — the anon key is intentionally shipped
//  to clients (same as the web frontend). Never put the SERVICE_ROLE_KEY here.
//

import Foundation

enum Config {

    // MARK: - Supabase
    /// Supabase project URL (public).
    static let supabaseURL = URL(string: "https://nxmzmrsmvlbibfzsrqyn.supabase.co")!

    /// Supabase anon (public) key.
    /// This is safe to embed in the app — it only allows Row Level Security-governed reads.
    /// It is the SAME key used by the web frontend (`frontend/.env.local`).
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54bXptcnNtdmxiaWJmenNycXluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3MTE0MTQsImV4cCI6MjA4OTI4NzQxNH0.B6dvQuyQvE1tv5ApuN5fLzAM58nUvjAtDTKDzM37mOY"

    // MARK: - Backend API
    /// Render-hosted FastAPI backend URL.
    static let apiBaseURL = URL(string: "https://mlb-betting-agent-e4vs.onrender.com")!

    // MARK: - App metadata
    static let upgradeURL = URL(string: "https://mlbvaluebets.com/pricing")!
    static let accountURL = URL(string: "https://mlbvaluebets.com/account")!
    static let supportURL = URL(string: "https://mlbvaluebets.com/support")!
    static let privacyURL = URL(string: "https://mlbvaluebets.com/privacy")!
    static let termsURL = URL(string: "https://mlbvaluebets.com/terms")!
    static let marketingURL = URL(string: "https://mlbvaluebets.com")!
}
