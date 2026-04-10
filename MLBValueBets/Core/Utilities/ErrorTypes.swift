//
//  ErrorTypes.swift
//  MLBValueBets
//

import Foundation

/// Errors raised by the APIClient when a request fails.
enum APIError: LocalizedError, Equatable {
    case notAuthenticated
    case unauthorized               // 401 from server after a retry
    case forbidden                  // 403 — pro-only endpoint accessed by free user
    case notFound                   // 404
    case rateLimited                // 429
    case serverError(status: Int)   // 5xx
    case badResponse                // non-HTTP response
    case decoding(String)           // JSON decode failure with debug message
    case transport(String)          // URLSession-level failure (offline, DNS, etc.)
    case timeout                    // request timed out
    case offline                    // no internet connection
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to continue."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .forbidden:
            return "This feature requires a Pro subscription."
        case .notFound:
            return "We couldn't find what you were looking for."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(let status):
            return "Server error (\(status)). Please try again shortly."
        case .badResponse:
            return "Received an invalid response from the server."
        case .decoding(let detail):
            return "Could not read server response. (\(detail))"
        case .transport(let detail):
            return "Network error: \(detail)"
        case .timeout:
            return "The request timed out. Please check your connection and try again."
        case .offline:
            return "You appear to be offline. Please check your internet connection."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }

    /// True if the error indicates the user's session is expired and they
    /// need to sign in again. Views can observe this to auto-redirect.
    var isSessionExpired: Bool {
        switch self {
        case .unauthorized, .notAuthenticated: return true
        default: return false
        }
    }

    /// SF Symbol name for the error, used by ErrorStateCard.
    var iconName: String {
        switch self {
        case .offline:  return "wifi.slash"
        case .timeout:  return "clock.badge.exclamationmark"
        default:        return "exclamationmark.triangle.fill"
        }
    }
}

/// Errors raised by AuthService during sign-in / sign-out flows.
enum AuthError: LocalizedError, Equatable {
    case invalidCredentials
    case emailNotConfirmed
    case networkUnavailable
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Incorrect email or password."
        case .emailNotConfirmed:
            return "Please confirm your email address before signing in."
        case .networkUnavailable:
            return "No internet connection."
        case .unknown(let detail):
            return detail
        }
    }
}
