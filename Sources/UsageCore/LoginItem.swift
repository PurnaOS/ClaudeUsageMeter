import Foundation

/// Pure login-item presentation logic (FR-0004). The actual register/unregister
/// against `SMAppService` is platform glue in the app; this is the decision the
/// menu shows, kept testable on its own.
public enum LoginItem {
    public static func menuTitle(enabled: Bool) -> String {
        enabled ? "Disable launch at login" : "Launch at login"
    }
}
