//
//  AuthViewModel.swift
//  MLBValueBets
//
//  Drives the LoginView. Uses the @Observable macro (iOS 17+).
//

import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class AuthViewModel {

    // MARK: - Form state
    var email: String = ""
    var password: String = ""
    var isWorking: Bool = false
    var errorMessage: String? = nil

    // MARK: - Session state
    var isSignedIn: Bool = false
    var currentUser: UserProfile? = nil

    // MARK: - Lifecycle

    init() {
        Task { await self.refreshSession() }
    }

    /// Checks for an existing session on app launch.
    func refreshSession() async {
        if let info = await AuthService.shared.currentUserInfo() {
            self.isSignedIn = true
            await loadProfile(id: info.id, email: info.email)
        } else {
            self.isSignedIn = false
            self.currentUser = nil
        }
    }

    // MARK: - Actions

    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            try await AuthService.shared.signIn(email: email, password: password)
            await refreshSession()
            password = ""   // clear from memory after successful sign-in
            HapticService.success()
        } catch let err as AuthError {
            errorMessage = err.errorDescription
            HapticService.error()
        } catch {
            errorMessage = error.localizedDescription
            HapticService.error()
        }
    }

    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }

        do {
            try await AuthService.shared.signUp(email: email, password: password)
            await refreshSession()
            HapticService.success()
        } catch let err as AuthError {
            errorMessage = err.errorDescription
            HapticService.error()
        } catch {
            errorMessage = error.localizedDescription
            HapticService.error()
        }
    }

    func signOut() async {
        isWorking = true
        defer { isWorking = false }
        do {
            try await AuthService.shared.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
        self.isSignedIn = false
        self.currentUser = nil
        self.email = ""
        self.password = ""
        PicksCacheService.clearAll()
    }

    func sendPasswordReset() async {
        guard !email.isEmpty else {
            errorMessage = "Enter your email first."
            return
        }
        do {
            try await AuthService.shared.sendPasswordReset(email: email)
            errorMessage = "Password reset email sent."
        } catch let err as AuthError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func loadProfile(id: String, email: String) async {
        // Default to free until we learn otherwise
        var tier: UserProfile.Tier = .free
        do {
            let status = try await BillingService.shared.fetchStatus()
            tier = status.isPro ? .pro : .free
        } catch {
            // Non-fatal — stay on free badge if the billing endpoint fails
            #if DEBUG
            print("[AuthViewModel] Could not fetch billing status: \(error)")
            #endif
        }
        self.currentUser = UserProfile(id: id, email: email, tier: tier)
    }
}
