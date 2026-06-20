import Foundation

/// Time-until-reset formatting for the detail window (FR-0005).
public enum Countdown {
    /// Compact "time remaining" string, e.g. "3d 4h", "2h 14m", "9m".
    /// At or past the reset instant it reads "now".
    public static func timeUntil(_ reset: Date, now: Date = Date()) -> String {
        let secs = Int(reset.timeIntervalSince(now))
        if secs <= 0 { return "now" }
        let d = secs / 86_400
        let h = (secs % 86_400) / 3_600
        let m = (secs % 3_600) / 60
        if d > 0 { return "\(d)d \(h)h" }
        if h > 0 { return "\(h)h \(m)m" }
        if m > 0 { return "\(m)m" }
        return "<1m"
    }
}
