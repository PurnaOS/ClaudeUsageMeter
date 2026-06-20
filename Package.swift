// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClaudeUsageMeter",
    platforms: [.macOS(.v13)], // MenuBarExtra needs macOS 13+
    targets: [
        // Pure, testable core — no SwiftUI, no live network.
        .target(name: "UsageCore"),
        // assert-based self-check, runnable with `swift run UsageCoreCheck`.
        // ponytail: no XCTest — the Command Line Tools toolchain here ships no
        // test module. One runnable check that exits non-zero on any failure.
        .executableTarget(name: "UsageCoreCheck", dependencies: ["UsageCore"]),
        // Live smoke test: one real call to /api/oauth/usage. Not a unit test.
        .executableTarget(name: "UsageProbe", dependencies: ["UsageCore"]),
        // Shared SwiftUI brand mark — used by the app and the icon renderer.
        .target(name: "MeterUI"),
        // Renders the logo to PNG + builds AppIcon.icns. Run: swift run MakeIcon
        .executableTarget(name: "MakeIcon", dependencies: ["MeterUI"]),
        // Thin menu-bar shell wiring UsageCore to a MenuBarExtra.
        .executableTarget(name: "ClaudeUsageMeter", dependencies: ["UsageCore", "MeterUI"]),
    ]
)
