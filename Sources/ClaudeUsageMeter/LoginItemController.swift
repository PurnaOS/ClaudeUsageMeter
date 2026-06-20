import ServiceManagement
import UsageCore

/// Glue over `SMAppService` for launch-at-login (FR-0004). ponytail: native
/// ServiceManagement — no login helper bundle, no third-party lib.
@MainActor
enum LoginItemController {
    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    static var menuTitle: String { LoginItem.menuTitle(enabled: isEnabled) }

    /// Flip the login-item registration. Errors are non-fatal — worst case the
    /// toggle simply doesn't take, the app keeps running.
    static func toggle() {
        try? (isEnabled ? SMAppService.mainApp.unregister()
                        : SMAppService.mainApp.register())
    }
}
