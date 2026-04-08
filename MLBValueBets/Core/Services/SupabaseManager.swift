//
//  SupabaseManager.swift
//  MLBValueBets
//
//  Thin singleton wrapper around the Supabase Swift SDK.
//  Handles auth session storage, token retrieval, and sign-out.
//
//  IMPORTANT: Add the Supabase Swift package to Xcode before this compiles:
//    File → Add Package Dependencies → https://github.com/supabase/supabase-swift
//    Select: Supabase (includes Auth, PostgREST, Realtime, Storage)
//

import Foundation
#if canImport(Supabase)
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        self.client = SupabaseClient(
            supabaseURL: Config.supabaseURL,
            supabaseKey: Config.supabaseAnonKey
        )
    }

    // MARK: - Session access

    /// Returns the current JWT access token, or nil if the user is signed out.
    /// Refreshes automatically if the token is near expiry.
    func currentAccessToken() async -> String? {
        do {
            let session = try await client.auth.session
            return session.accessToken
        } catch {
            return nil
        }
    }

    /// True when a non-expired session exists.
    func hasValidSession() async -> Bool {
        await currentAccessToken() != nil
    }

    /// Forces a refresh of the access token. Call after a 401 retry.
    func refreshSession() async throws {
        _ = try await client.auth.refreshSession()
    }
}
#else
// Fallback stub so non-UI files can still compile without the Supabase package
// (for Swift-for-Windows compile checks).
final class SupabaseManager {
    static let shared = SupabaseManager()
    private init() {}

    func currentAccessToken() async -> String? { nil }
    func hasValidSession() async -> Bool { false }
    func refreshSession() async throws {}
}
#endif
