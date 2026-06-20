import Foundation

/// Decodes the OAuth usage endpoint body into a `UsageSnapshot`.
///
/// Field shape confirmed against a live `GET /api/oauth/usage` 200 (2026-06):
/// top-level `five_hour` / `seven_day` objects, each `utilization` (a 0–100
/// percentage) and `resets_at` (ISO-8601 string). Decoding is tolerant: a missing
/// window is the only failure, and the windows are also accepted nested under a
/// `rate_limits` key.
public enum UsageResponse {
    private struct Window: Decodable {
        let utilization: Double
        let resets_at: String
    }
    private struct Body: Decodable {
        let five_hour: Window
        let seven_day: Window
    }
    private struct Envelope: Decodable {
        let rate_limits: Body?
        let five_hour: Window?
        let seven_day: Window?
    }

    // ponytail: formatters built per call — ISO8601DateFormatter isn't Sendable
    // so it can't be a shared static under Swift 6 concurrency. Date parsing is
    // cold (once per poll), so the allocation is irrelevant.
    static func parseDate(_ s: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return fractional.date(from: s) ?? ISO8601DateFormatter().date(from: s)
    }

    public static func parse(_ data: Data) throws -> UsageSnapshot {
        let env = try? JSONDecoder().decode(Envelope.self, from: data)
        let five = env?.rate_limits?.five_hour ?? env?.five_hour
        let seven = env?.rate_limits?.seven_day ?? env?.seven_day
        guard let five, let seven,
              let fiveReset = parseDate(five.resets_at),
              let sevenReset = parseDate(seven.resets_at)
        else { throw UsageError.badResponse }
        return UsageSnapshot(
            fiveHour: UsageWindow(usedPercentage: five.utilization, resetsAt: fiveReset),
            sevenDay: UsageWindow(usedPercentage: seven.utilization, resetsAt: sevenReset)
        )
    }
}
