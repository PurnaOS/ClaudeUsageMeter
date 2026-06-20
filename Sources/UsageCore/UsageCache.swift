import Foundation

/// A snapshot plus when it was fetched — what the app shows on a cold start and
/// keeps showing through a transient error / 429 (NFR-0002).
public struct CachedUsage: Codable, Equatable, Sendable {
    public let snapshot: UsageSnapshot
    public let fetchedAt: Date
    public init(snapshot: UsageSnapshot, fetchedAt: Date) {
        self.snapshot = snapshot
        self.fetchedAt = fetchedAt
    }
}

/// Persists the last good reading to disk so the meter is never blank when the
/// endpoint is briefly unavailable.
public enum UsageCache {
    public static func defaultURL(
        bundleID: String = "com.sriniraju.claudeusagemeter",
        fm: FileManager = .default
    ) -> URL {
        let base = (try? fm.url(for: .cachesDirectory, in: .userDomainMask,
                                appropriateFor: nil, create: true))
            ?? fm.temporaryDirectory
        let dir = base.appendingPathComponent(bundleID, isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("usage.json")
    }

    public static func save(_ cached: CachedUsage, to url: URL = defaultURL()) {
        guard let data = try? JSONEncoder().encode(cached) else { return }
        try? data.write(to: url, options: .atomic)
    }

    public static func load(from url: URL = defaultURL()) -> CachedUsage? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(CachedUsage.self, from: data)
    }
}
