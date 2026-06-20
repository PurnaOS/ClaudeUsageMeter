import SwiftUI
import UsageCore

/// Menu-bar shell (FR-0003). ponytail: native MenuBarExtra — no third-party
/// menu-bar lib. The testable logic lives in UsageCore; this is glue: poll on an
/// interval, show the most-urgent percentage, expose an unavailable state.
@main
struct ClaudeUsageMeterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    @StateObject private var model = UsageModel()

    var body: some Scene {
        MenuBarExtra {
            VStack(alignment: .leading, spacing: 8) {
                UsageDetailView(snapshot: model.snapshot,
                                status: model.status,
                                fetchedAt: model.fetchedAt)
                Divider()
                VStack(spacing: 1) {
                    FooterButton(title: LoginItemController.menuTitle, systemImage: "power") {
                        LoginItemController.toggle()
                    }
                    FooterButton(title: "Refresh now", systemImage: "arrow.clockwise") {
                        Task { await model.refresh() }
                    }
                    FooterButton(title: "Quit", systemImage: "xmark.circle") {
                        NSApplication.shared.terminate(nil)
                    }
                }
                .padding(.horizontal, 6).padding(.bottom, 6)
            }
        } label: {
            // The brand mark + glance % in the menu bar. SF Symbol stays crisp
            // and template-tints to the menu bar; color signals a hot window.
            Image(systemName: "gauge.with.dots.needle.50percent")
            Text(model.title)
        }
        .menuBarExtraStyle(.window) // richer detail window, not a plain menu
    }
}

/// FR-0004: run as a background/menu-bar agent with no Dock icon.
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}

@MainActor
final class UsageModel: ObservableObject {
    @Published var snapshot: UsageSnapshot?
    @Published var fetchedAt: Date?       // when `snapshot` was last fetched
    @Published var status: String = ""    // non-empty = current trouble (e.g. rate limited)

    private let client = UsageClient()
    private var timer: Timer?
    private let interval: TimeInterval = 60     // normal poll
    private let retryInterval: TimeInterval = 30 // sooner re-try after an error

    var title: String { Glance.menuBarTitle(for: snapshot) }

    init() {
        // Show the last good reading instantly on launch (NFR-0002), even before
        // the first network call — and survive a cold start during a 429.
        if let cached = UsageCache.load() {
            snapshot = cached.snapshot
            fetchedAt = cached.fetchedAt
        }
        Task { await refresh() }
        schedule(interval)
    }

    private func schedule(_ after: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: after, repeats: false) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    func refresh() async {
        do {
            let snap = try await client.fetch()
            let now = Date()
            snapshot = snap; fetchedAt = now; status = ""
            UsageCache.save(CachedUsage(snapshot: snap, fetchedAt: now))
            schedule(interval)
        } catch {
            // Keep showing the last good value; surface why, retry sooner.
            status = (error as? UsageError)?.userMessage ?? "Offline — retrying"
            schedule(retryInterval)
        }
    }
}
