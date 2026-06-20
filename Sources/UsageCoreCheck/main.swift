import Foundation
import UsageCore

// Self-check for UsageCore (STORY-001). Asserts exit non-zero on failure, so
// `swift run UsageCoreCheck` is the green/red test command the Test artifact
// (TEST-usage-core) records.

func check(_ cond: Bool, _ msg: String) {
    if !cond { FileHandle.standardError.write(Data("FAIL: \(msg)\n".utf8)); exit(1) }
}

// FR-0001: parse the live endpoint shape (utilization + ISO-8601 resets_at).
let flat = """
{"five_hour":{"utilization":42.0,"resets_at":"2026-06-20T07:40:00.596303+00:00"},
 "seven_day":{"utilization":17.5,"resets_at":"2026-06-26T08:00:00+00:00"}}
""".data(using: .utf8)!
let snap = try UsageResponse.parse(flat)
check(snap.fiveHour.usedPercentage == 42.0, "five_hour percent")
check(snap.sevenDay.usedPercentage == 17.5, "seven_day percent")
// fractional-second ISO and plain ISO both decode to a real instant.
check(snap.fiveHour.resetsAt.timeIntervalSince1970 > 0, "fractional resets_at decode")
check(snap.sevenDay.resetsAt.timeIntervalSince1970 > 0, "plain resets_at decode")

// Tolerant: same data nested under `rate_limits`.
let nested = """
{"rate_limits":{"five_hour":{"utilization":5,"resets_at":"2026-06-20T07:40:00+00:00"},
 "seven_day":{"utilization":6,"resets_at":"2026-06-26T08:00:00+00:00"}}}
""".data(using: .utf8)!
check(try UsageResponse.parse(nested).sevenDay.usedPercentage == 6, "nested parse")

// Garbage → typed error, not a crash (NFR-0002).
do { _ = try UsageResponse.parse(Data("{}".utf8)); check(false, "garbage should throw") }
catch { check(error as? UsageError == .badResponse, "garbage error type") }

// FR-0003: the glance shows the more urgent (higher) window.
let urgent = UsageSnapshot(
    fiveHour: .init(usedPercentage: 30, resetsAt: .distantFuture),
    sevenDay: .init(usedPercentage: 80, resetsAt: .distantFuture))
check(urgent.mostUrgent.usedPercentage == 80, "most urgent picks higher")

// FR-0002 + NFR-0002: formatting and the unavailable marker.
let g = UsageSnapshot(
    fiveHour: .init(usedPercentage: 66.6, resetsAt: .distantFuture),
    sevenDay: .init(usedPercentage: 10, resetsAt: .distantFuture))
check(Glance.menuBarTitle(for: g) == "67%", "glance rounds")
check(Glance.menuBarTitle(for: nil) == "—", "glance unavailable")
check(Glance.percent(150) == "100%", "percent clamps high")
check(Glance.percent(-5) == "0%", "percent clamps low")

// FR-0001: CLAUDE_CONFIG_DIR overrides the default ~/.claude location.
check(UsageClient.credentialsURL(env: ["CLAUDE_CONFIG_DIR": "/tmp/cfg"]).path
      == "/tmp/cfg/.credentials.json", "credentials path env override")

// NFR-0002: missing credentials file → clean typed error.
do { _ = try UsageClient.readToken(at: URL(fileURLWithPath: "/no/such.json")); check(false, "missing token should throw") }
catch { check(error as? UsageError == .noOAuthToken, "missing token error type") }

// Token parsed out of a real credentials file.
let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent("cred-\(UUID().uuidString).json")
defer { try? FileManager.default.removeItem(at: tmp) }
try Data("""
{"claudeAiOauth":{"accessToken":"sk-oauth-xyz"}}
""".utf8).write(to: tmp)
check(try UsageClient.readToken(at: tmp) == "sk-oauth-xyz", "token parsed (file)")

// Same extractor handles a Keychain blob (identical credentials shape).
check(try UsageClient.token(fromCredentials: Data("""
{"claudeAiOauth":{"accessToken":"sk-kc-1"}}
""".utf8)) == "sk-kc-1", "token parsed (keychain blob)")

// FR-0005: time-until-reset formatting, relative to a fixed `now`.
let now = Date(timeIntervalSince1970: 1_000_000)
check(Countdown.timeUntil(now.addingTimeInterval(3 * 86_400 + 4 * 3_600), now: now) == "3d 4h", "days+hours")
check(Countdown.timeUntil(now.addingTimeInterval(2 * 3_600 + 14 * 60), now: now) == "2h 14m", "hours+minutes")
check(Countdown.timeUntil(now.addingTimeInterval(9 * 60), now: now) == "9m", "minutes")
check(Countdown.timeUntil(now.addingTimeInterval(30), now: now) == "<1m", "under a minute")
check(Countdown.timeUntil(now.addingTimeInterval(-5), now: now) == "now", "past reset reads now")

// FR-0006: pace = tokens-used% vs time-elapsed%.
let span = WindowSpan.fiveHour
let resetIn3h27m = Date(timeIntervalSince1970: 1_000_000).addingTimeInterval(3 * 3600 + 27 * 60)
let elapsed = Pace.elapsedPercent(spanSeconds: span, resetsAt: resetIn3h27m,
                                  now: Date(timeIntervalSince1970: 1_000_000))
check(Int(elapsed.rounded()) == 31, "5h elapsed% (~31 at 3h27m left)")
check(Pace.status(usedPercent: 10, elapsedPercent: 31) == .onTrack, "under clock = on track")
check(Pace.status(usedPercent: 36, elapsedPercent: 31) == .watch, "a bit ahead = watch")
check(Pace.status(usedPercent: 80, elapsedPercent: 31) == .hot, "far ahead = hot")
check(Pace.elapsedPercent(spanSeconds: span, resetsAt: Date(timeIntervalSince1970: 0),
                          now: Date(timeIntervalSince1970: 1_000_000)) == 100, "past reset clamps to 100")
check(Pace.hot.label == "Burning hot", "pace label")

// FR-0004: login-item menu title reflects current state.
check(LoginItem.menuTitle(enabled: false) == "Launch at login", "login title off")
check(LoginItem.menuTitle(enabled: true) == "Disable launch at login", "login title on")

// NFR-0002: cache round-trips a snapshot so a cold start isn't blank.
let cacheURL = URL(fileURLWithPath: NSTemporaryDirectory())
    .appendingPathComponent("cache-\(UUID().uuidString).json")
defer { try? FileManager.default.removeItem(at: cacheURL) }
check(UsageCache.load(from: cacheURL) == nil, "missing cache loads nil")
let toCache = CachedUsage(snapshot: g, fetchedAt: Date(timeIntervalSince1970: 1_700_000_000))
UsageCache.save(toCache, to: cacheURL)
let loaded = UsageCache.load(from: cacheURL)
check(loaded == toCache, "cache round-trips snapshot + fetchedAt")
check(loaded?.snapshot.fiveHour.usedPercentage == 66.6, "cached percent intact")

// NFR-0002: errors map to a human line, not a silent blank.
check(UsageError.http(429).userMessage == "Rate limited — retrying", "429 message")
check(UsageError.noOAuthToken.userMessage == "Sign in to Claude Code", "no-token message")

print("ok: all UsageCore checks passed")
