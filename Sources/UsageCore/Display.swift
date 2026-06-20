import Foundation

/// Formats a snapshot (or its absence) for the menu bar glance (FR-0002/0003).
public enum Glance {
    /// The single string shown in the menu bar: the most-urgent window's
    /// percentage, or a clear unavailable marker (NFR-0002).
    public static func menuBarTitle(for snapshot: UsageSnapshot?) -> String {
        guard let snapshot else { return "—" }
        return percent(snapshot.mostUrgent.usedPercentage)
    }

    /// Whole-percent string, clamped to 0...100.
    public static func percent(_ value: Double) -> String {
        let clamped = min(100, max(0, value))
        return "\(Int(clamped.rounded()))%"
    }
}
