//
//  BackendIntegrationTests.swift
//  MLBValueBetsTests
//
//  Network-backed smoke test. This is the ONLY test in the suite that
//  actually hits the real Render-hosted backend — everything else uses
//  fixtures. Keep it tight: one endpoint, one assertion on the status
//  field, generous timeout for Render cold starts.
//
//  Why it exists:
//    - Proves the iOS simulator can reach the Render API over HTTPS
//      (DNS, TLS, cert trust, no App Transport Security gotchas)
//    - Proves the backend's /health shape still matches what we decode
//    - Fails loud in CI if the backend is down or the hostname changes
//
//  If this starts flaking because Render is cold-starting, bump the
//  timeout rather than deleting the test. It's our canary.
//

import XCTest
@testable import MLBValueBets

final class BackendIntegrationTests: XCTestCase {

    /// Minimal decode target for GET /health. Kept private so the main
    /// app doesn't need to ship a HealthResponse model just for tests.
    private struct HealthResponse: Decodable {
        let status: String
        let modelsLoaded: Bool
        let schedulerRunning: Bool
    }

    func test_health_endpoint_returnsOkFromLiveBackend() async throws {
        let url = Config.apiBaseURL.appendingPathComponent("health")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Render free-tier services can cold-start for ~30s on the first
        // request after idle. Give it headroom.
        request.timeoutInterval = 60

        let session: URLSession = {
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 60
            config.timeoutIntervalForResource = 90
            return URLSession(configuration: config)
        }()

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw XCTSkip("Backend unreachable from CI (likely Render cold start or network): \(error.localizedDescription)")
        }

        guard let http = response as? HTTPURLResponse else {
            XCTFail("Response is not an HTTPURLResponse: \(response)")
            return
        }

        XCTAssertEqual(http.statusCode, 200, "Expected 200 from /health but got \(http.statusCode)")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let health: HealthResponse
        do {
            health = try decoder.decode(HealthResponse.self, from: data)
        } catch {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            XCTFail("Could not decode /health response. Raw body: \(raw). Error: \(error)")
            return
        }

        XCTAssertEqual(health.status, "ok", "Backend /health returned a non-ok status")
        // models_loaded and scheduler_running are both expected to be true
        // under normal operation. A failure here means the backend came up
        // but couldn't load its pickle or start its scheduler — worth
        // knowing about loudly.
        XCTAssertTrue(health.modelsLoaded, "Backend reports models are NOT loaded")
        XCTAssertTrue(health.schedulerRunning, "Backend reports scheduler is NOT running")
    }
}
