//
//  AuthService.swift
//  MLBValueBets
//
//  Authentication wrapper — sign in, sign out, current user.
//  Uses Supabase Swift SDK under the hood.
//

import Foundation
#if canImport(Supabase)
import Supabase

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // MARK: - Sign in / out

    /// Email + password sign-in.
    func signIn(email: String, password: String) async throws {
        do {
            _ = try await SupabaseManager.shared.client.auth.signIn(
                email: email,
                password: password
            )
        } catch {
            throw mapAuthError(error)
        }
    }

    /// Email + password sign-up (creates new free-tier account).
    func signUp(email: String, password: String) async throws {
        do {
            _ = try await SupabaseManager.shared.client.auth.signUp(
                email: email,
                password: password
            )
        } catch {
            throw mapAuthError(error)
        }
    }

    /// Sign out and clear the local session.
    func signOut() async throws {
        do {
            try await SupabaseManager.shared.client.auth.signOut()
        } catch {
            throw mapAuthError(error)
        }
    }

    /// Send a password-reset email.
    func sendPasswordReset(email: String) async throws {
        do {
            try await SupabaseManager.shared.client.auth.resetPasswordForEmail(email)
        } catch {
            throw mapAuthError(error)
        }
    }

    // MARK: - Current user

    /// Returns the current user's Supabase UUID and email, or nil if signed out.
    func currentUserInfo() async -> (id: String, email: String)? {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let user = session.user
            return (user.id.uuidString, user.email ?? "")
        } catch {
            return nil
        }
    }

    // MARK: - Error mapping

    private func mapAuthError(_ error: Error) -> AuthError {
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid") && message.contains("credentials") {
            return .invalidCredentials
        }
        if message.contains("email") && message.contains("confirm") {
            return .emailNotConfirmed
        }
        if message.contains("offline") || message.contains("network") {
            return .networkUnavailable
        }
        return .unknown(error.localizedDescription)
    }
}
#else
// Stub for Swift-for-Windows compile check (no Supabase package available).
final class AuthService {
    static let shared = AuthService()
    private init() {}
    func signIn(email: String, password: String) async throws {
        throw AuthError.unknown("Supabase package not available in this build target")
    }
    func signUp(email: String, password: String) async throws {
        throw AuthError.unknown("Supabase package not available in this build target")
    }
    func signOut() async throws {}
    func sendPasswordReset(email: String) async throws {}
    func currentUserInfo() async -> (id: String, email: String)? { nil }
}
#endif
