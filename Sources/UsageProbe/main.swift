import Foundation
import UsageCore

// Live smoke test for FR-0001: one real call to /api/oauth/usage using the
// Keychain/file token. Prints status + parsed snapshot, or the raw body when the
// decoder shape disagrees (so the field names can be corrected). Never prints the
// token. The usage body is just numbers, safe to echo.

let client = UsageClient()
do {
    let (status, body) = try await client.fetchRaw()
    print("HTTP \(status)")
    guard status == 200 else {
        print(String(data: body, encoding: .utf8) ?? "<non-utf8 body>")
        exit(1)
    }
    do {
        let snap = try UsageResponse.parse(body)
        func line(_ name: String, _ w: UsageWindow, _ span: Double) {
            let e = Pace.elapsedPercent(spanSeconds: span, resetsAt: w.resetsAt)
            let p = Pace.status(usedPercent: w.usedPercentage, elapsedPercent: e)
            print("\(name): \(Glance.percent(w.usedPercentage)) tokens · \(Glance.percent(e)) time · \(p.label) · resets \(Countdown.timeUntil(w.resetsAt))")
        }
        line("5-hour", snap.fiveHour, WindowSpan.fiveHour)
        line("weekly", snap.sevenDay, WindowSpan.sevenDay)
        print("glance: \(Glance.menuBarTitle(for: snap))")
        print("ok: decoder matches live response")
    } catch {
        print("DECODER MISMATCH — raw body follows so the field names can be fixed:")
        print(String(data: body, encoding: .utf8) ?? "<non-utf8 body>")
        exit(2)
    }
} catch let e as UsageError {
    print("error: \(e)")
    exit(3)
}
