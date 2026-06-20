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
                UsageDetailView(snapshot: model.snapshot)
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
    private let client = UsageClient()
    private var timer: Timer?

    // ponytail: 60s poll. The endpoint is 429-rate-limited; if that bites,
    // back off and serve the last good value (NFR-0002 cache lives here later).
    private let interval: TimeInterval = 60

    var title: String { Glance.menuBarTitle(for: snapshot) }

    init() {
        Task { await refresh() }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { await self?.refresh() }
        }
    }

    func refresh() async {
        // On any error keep the previous value if we had one, else stay nil →
        // the glance shows the unavailable marker.
        snapshot = (try? await client.fetch()) ?? snapshot
    }
}
