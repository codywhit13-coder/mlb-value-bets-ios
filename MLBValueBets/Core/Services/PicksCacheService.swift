//
//  PicksCacheService.swift
//  MLBValueBets
//
//  Simple UserDefaults-backed JSON cache so the app shows stale data
//  when offline instead of blank screens. Each cached value is wrapped
//  in a CachedResponse<T> that records when it was stored so the UI
//  can show "Last updated X ago".
//

import Foundation

enum PicksCacheService {

    // MARK: - Keys

    static let todayPicksKey  = "cache.picks.today"
    static let historyKey     = "cache.picks.history"
    static let liveRecordKey  = "cache.performance.live"

    // MARK: - Wrapper

    struct CachedResponse<T: Codable>: Codable {
        let data: T
        let cachedAt: Date
    }

    // MARK: - Encoder / Decoder

    /// Matches APIClient's `.convertFromSnakeCase` strategy so cached
    /// JSON round-trips correctly through the same Codable types.
    private static let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private static let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Public API

    /// Saves a value to UserDefaults, wrapped with the current timestamp.
    static func save<T: Codable>(_ value: T, forKey key: String) {
        let wrapped = CachedResponse(data: value, cachedAt: Date())
        guard let data = try? encoder.encode(wrapped) else {
            #if DEBUG
            print("[Cache] Failed to encode value for key '\(key)'")
            #endif
            return
        }
        UserDefaults.standard.set(data, forKey: key)
    }

    /// Loads a cached value and its timestamp. Returns nil if nothing is
    /// cached or decoding fails (e.g. schema changed between app versions).
    static func load<T: Codable>(_ type: T.Type, forKey key: String) -> CachedResponse<T>? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? decoder.decode(CachedResponse<T>.self, from: data)
    }

    /// Removes a cached value.
    static func clear(forKey key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    /// Clears all cached data. Useful on sign-out so the next user
    /// doesn't see the previous user's picks.
    static func clearAll() {
        clear(forKey: todayPicksKey)
        clear(forKey: historyKey)
        clear(forKey: liveRecordKey)
    }
}
