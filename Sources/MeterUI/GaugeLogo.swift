import SwiftUI

/// App brand mark: a speedometer dial + needle — the "meter" the app is. Scales
/// from a 1024px icon down to the window header. ponytail: drawn with SwiftUI
/// shapes, no image asset to maintain; render it via the MakeIcon target.
public struct GaugeLogo: View {
    public init() {}
    public var body: some View {
        GeometryReader { geo in
            let s = min(geo.size.width, geo.size.height)
            ZStack {
                RoundedRectangle(cornerRadius: s * 0.22, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 0.36, green: 0.45, blue: 0.95),
                                                  Color(red: 0.55, green: 0.30, blue: 0.92)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                // ~270° dial, open at the bottom
                DialArc()
                    .stroke(.white.opacity(0.85),
                            style: StrokeStyle(lineWidth: s * 0.07, lineCap: .round))
                    .padding(s * 0.26)
                // needle from the hub into the upper-left ("low usage") sweep
                Needle(angle: .degrees(212))
                    .stroke(.white, style: StrokeStyle(lineWidth: s * 0.05, lineCap: .round))
                    .padding(s * 0.26)
                Circle().fill(.white).frame(width: s * 0.12)
            }
            .frame(width: s, height: s)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

/// A dial arc spanning ~270°, open at the bottom (speedometer style).
struct DialArc: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.addArc(center: CGPoint(x: r.midX, y: r.midY),
                 radius: min(r.width, r.height) / 2,
                 startAngle: .degrees(135), endAngle: .degrees(45), clockwise: false)
        return p
    }
}

/// A needle from the dial centre to a point on the dial at `angle`.
struct Needle: Shape {
    var angle: Angle
    func path(in r: CGRect) -> Path {
        let c = CGPoint(x: r.midX, y: r.midY)
        let len = min(r.width, r.height) / 2 * 0.92
        let tip = CGPoint(x: c.x + len * CGFloat(cos(angle.radians)),
                          y: c.y + len * CGFloat(sin(angle.radians)))
        var p = Path(); p.move(to: c); p.addLine(to: tip)
        return p
    }
}
