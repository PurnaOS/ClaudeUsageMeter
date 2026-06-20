import Foundation

/// One rate-limit window as reported by the OAuth usage endpoint.
public struct UsageWindow: Equatable, Sendable {
    public let usedPercentage: Double   // 0...100
    public let resetsAt: Date

    public init(usedPercentage: Double, resetsAt: Date) {
        self.usedPercentage = usedPercentage
        self.resetsAt = resetsAt
    }
}

/// A reading of both subscription windows. There is no 1-hour subscription
/// window — Anthropic's rolling limits are 5-hour and weekly (7-day).
public struct UsageSnapshot: Equatable, Sendable {
    public let fiveHour: UsageWindow
    public let sevenDay: UsageWindow

    public init(fiveHour: UsageWindow, sevenDay: UsageWindow) {
        self.fiveHour = fiveHour
        self.sevenDay = sevenDay
    }

    /// The window the user should worry about first — the higher percentage.
    /// This is what the menu bar glance shows (FR-0003).
    public var mostUrgent: UsageWindow {
        fiveHour.usedPercentage >= sevenDay.usedPercentage ? fiveHour : sevenDay
    }
}

public enum UsageError: Error, Equatable {
    case noOAuthToken        // API-key-only user, or no credentials file
    case http(Int)           // non-200, including 429
    case badResponse         // body did not decode to the expected shape
}
