import SwiftUI
import MeterUI
import UniformTypeIdentifiers
import ImageIO

// Renders GaugeLogo into a macOS .iconset and builds Branding/AppIcon.icns.
// ponytail: SwiftUI ImageRenderer + iconutil — no design-tool round trip.

@MainActor
func pngData(size: CGFloat) -> Data? {
    let renderer = ImageRenderer(content: GaugeLogo().frame(width: size, height: size))
    renderer.scale = 1
    guard let cg = renderer.cgImage else { return nil }
    let out = NSMutableData()
    guard let dest = CGImageDestinationCreateWithData(out, UTType.png.identifier as CFString, 1, nil)
    else { return nil }
    CGImageDestinationAddImage(dest, cg, nil)
    guard CGImageDestinationFinalize(dest) else { return nil }
    return out as Data
}

@MainActor
func run() {
    let fm = FileManager.default
    let brand = URL(fileURLWithPath: fm.currentDirectoryPath).appendingPathComponent("Branding")
    let iconset = brand.appendingPathComponent("AppIcon.iconset")
    try? fm.createDirectory(at: iconset, withIntermediateDirectories: true)

    // macOS iconset: each logical size at 1x and 2x.
    let specs: [(Int, Int)] = [(16,1),(16,2),(32,1),(32,2),(128,1),(128,2),(256,1),(256,2),(512,1),(512,2)]
    for (pt, scale) in specs {
        let px = pt * scale
        guard let data = pngData(size: CGFloat(px)) else { print("render failed \(px)"); exit(1) }
        let name = scale == 1 ? "icon_\(pt)x\(pt).png" : "icon_\(pt)x\(pt)@2x.png"
        try? data.write(to: iconset.appendingPathComponent(name))
    }
    // Also a standalone 1024 logo.png for general use.
    if let big = pngData(size: 1024) {
        try? big.write(to: brand.appendingPathComponent("logo.png"))
    }

    // Build the .icns.
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
    p.arguments = ["-c", "icns", iconset.path,
                   "-o", brand.appendingPathComponent("AppIcon.icns").path]
    try? p.run(); p.waitUntilExit()
    print(p.terminationStatus == 0
          ? "ok: wrote Branding/logo.png, AppIcon.iconset, AppIcon.icns"
          : "iconset written; iconutil exit \(p.terminationStatus)")
}

MainActor.assumeIsolated { run() }
