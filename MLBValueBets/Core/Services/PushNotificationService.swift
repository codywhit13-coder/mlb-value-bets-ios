//
//  PushNotificationService.swift
//  MLBValueBets
//
//  Preparatory APNs token registration. Currently dormant — won't function
//  without a provisioning profile + push entitlement, but the code is ready
//  for when the Apple Developer account is set up.
//
//  Phase 2 TODO:
//    - POST device token to backend (/api/devices/register)
//    - Handle token refresh
//    - Topic-based subscriptions (daily picks, sharp alerts)
//

import Foundation
import UserNotifications
import UIKit

@MainActor
@Observable
final class PushNotificationService {

    // MARK: - State

    /// Whether the user has granted notification permission.
    var isAuthorized = false

    /// Whether a permission request is in flight.
    var isRequesting = false

    /// Human-readable status for the Settings UI.
    var statusDescription: String = "Not determined"

    // MARK: - Singleton

    static let shared = PushNotificationService()
    private init() {
        Task { await checkCurrentStatus() }
    }

    // MARK: - Permission

    /// Requests notification permission and registers for remote notifications.
    /// Returns `true` if permission was granted.
    @discardableResult
    func requestPermission() async -> Bool {
        isRequesting = true
        defer { isRequesting = false }

        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            isAuthorized = granted
            statusDescription = granted ? "Enabled" : "Denied"

            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }

            return granted
        } catch {
            statusDescription = "Error: \(error.localizedDescription)"
            return false
        }
    }

    /// Checks the current authorization status without prompting.
    func checkCurrentStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized:
            isAuthorized = true
            statusDescription = "Enabled"
        case .denied:
            isAuthorized = false
            statusDescription = "Denied — enable in Settings"
        case .provisional:
            isAuthorized = true
            statusDescription = "Provisional"
        case .ephemeral:
            isAuthorized = true
            statusDescription = "Ephemeral"
        case .notDetermined:
            isAuthorized = false
            statusDescription = "Not enabled"
        @unknown default:
            isAuthorized = false
            statusDescription = "Unknown"
        }
    }

    // MARK: - Token handling (called from AppDelegate)

    /// Called when APNs registration succeeds. Hex-encodes the device token.
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        #if DEBUG
        print("[Push] Device token: \(tokenString)")
        #endif

        // Phase 2: POST token to backend
        // Task {
        //     try? await APIClient.shared.registerDeviceToken(tokenString)
        // }
    }

    /// Called when APNs registration fails.
    func didFailToRegisterForRemoteNotifications(error: Error) {
        #if DEBUG
        print("[Push] Registration failed: \(error.localizedDescription)")
        #endif
        statusDescription = "Registration failed"
    }
}
