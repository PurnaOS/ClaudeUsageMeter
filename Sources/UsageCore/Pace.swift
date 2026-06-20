import Foundation

/// Window durations, in seconds.
public enum WindowSpan {
    public static let fiveHour: Double = 5 * 3600
    public static let sevenDay: Double = 7 * 86_400
}

/// Pace = tokens-used% vs time-elapsed% for a window. If you've spent more of
/// your tokens than of your time, you'll run dry before the window resets.
public enum Pace: Sendable, Equatable {
    case onTrack   // using tokens slower than the clock — headroom
    case watch     // slightly ahead of the clock
    case hot       // burning far faster than time — will run out early

    /// Percent of the window's duration that has elapsed (0…100).
    public static func elapsedPercent(spanSeconds: Double, resetsAt: Date, now: Date = Date()) -> Double {
        let remaining = resetsAt.timeIntervalSince(now)
        let elapsed = spanSeconds - remaining
        return min(100, max(0, elapsed / spanSeconds * 100))
    }

    /// Classify burn = used% − elapsed%.
    public static func status(usedPercent: Double, elapsedPercent: Double) -> Pace {
        let burn = usedPercent - elapsedPercent
        if burn <= 0 { return .onTrack }
        if burn <= 10 { return .watch }
        return .hot
    }

    public var label: String {
        switch self {
        case .onTrack: return "On track"
        case .watch:   return "Watch pace"
        case .hot:     return "Burning hot"
        }
    }
}
