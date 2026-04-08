//
//  Date+Format.swift
//  MLBValueBets
//
//  Helpers for displaying ISO 8601 game times.
//

import Foundation

extension String {
    /// Parses an ISO 8601 date string (e.g. "2026-04-08T17:35:00Z") to Date.
    var iso8601Date: Date? {
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime]
        if let d = iso.date(from: self) { return d }
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return iso.date(from: self)
    }

    /// Displays a game time as "7:35 PM" in the user's local timezone.
    var asLocalGameTime: String {
        guard let date = self.iso8601Date else { return self }
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }

    /// Displays a game time as "Wed 7:35 PM CT" style.
    var asLocalGameTimeFull: String {
        guard let date = self.iso8601Date else { return self }
        let f = DateFormatter()
        f.dateFormat = "EEE h:mm a zzz"
        f.timeZone = TimeZone.current
        return f.string(from: date)
    }
}

extension Date {
    /// Backend-compatible "YYYY-MM-DD" for the /api/picks/{date} endpoint.
    var backendDateString: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(identifier: "America/Chicago")  // backend uses CT
        return f.string(from: self)
    }
}
