import SwiftUI
import UsageCore
import MeterUI

/// Detail window (STORY-002 + FR-0006): a card per window showing tokens-used%,
/// time-elapsed%, the pace between them, and time-to-reset.
struct UsageDetailView: View {
    let snapshot: UsageSnapshot?
    var status: String = ""
    var fetchedAt: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                GaugeLogo().frame(width: 22, height: 22)
                Text("Claude Code usage").font(.headline)
                Spacer()
                if let at = fetchedAt {
                    Text(at, format: .relative(presentation: .numeric))
                        .font(.caption2).foregroundStyle(.tertiary)
                }
            }

            if let snap = snapshot {
                WindowCard(name: "5-hour", window: snap.fiveHour, span: WindowSpan.fiveHour)
                WindowCard(name: "Weekly", window: snap.sevenDay, span: WindowSpan.sevenDay)
                if !status.isEmpty {
                    // Showing cached numbers while the live call is failing.
                    Label(status, systemImage: "arrow.triangle.2.circlepath")
                        .font(.caption).foregroundStyle(.secondary)
                }
            } else {
                // No reading yet — say why, not a generic "unavailable".
                Label(status.isEmpty ? "Loading…" : status,
                      systemImage: status.contains("Sign in") ? "person.crop.circle.badge.exclamationmark"
                                 : "arrow.triangle.2.circlepath")
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            }
        }
        .padding(14)
        .frame(width: 300)
    }
}

private struct WindowCard: View {
    let name: String
    let window: UsageWindow
    let span: Double

    private var used: Double { window.usedPercentage }
    private var elapsed: Double { Pace.elapsedPercent(spanSeconds: span, resetsAt: window.resetsAt) }
    private var pace: Pace { Pace.status(usedPercent: used, elapsedPercent: elapsed) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name).font(.subheadline.weight(.semibold))
                Spacer()
                PaceBadge(pace: pace)
            }

            PaceBar(usedFraction: used / 100, elapsedFraction: elapsed / 100, color: pace.color)

            HStack(spacing: 6) {
                Text("\(Glance.percent(used)) tokens").foregroundStyle(pace.color)
                Text("·").foregroundStyle(.tertiary)
                Text("\(Glance.percent(elapsed)) time").foregroundStyle(.secondary)
                Spacer()
                Text("resets \(Countdown.timeUntil(window.resetsAt))").foregroundStyle(.secondary)
            }
            .font(.caption)
        }
    }
}

/// Horizontal bar: fill = tokens used, vertical tick = time elapsed.
/// Tick to the right of the fill → spending slower than the clock (good).
private struct PaceBar: View {
    let usedFraction: Double
    let elapsedFraction: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(Color.secondary.opacity(0.22))
                Capsule().fill(color)
                    .frame(width: max(4, w * min(1, max(0, usedFraction))))
                Rectangle().fill(Color.primary.opacity(0.7))
                    .frame(width: 2, height: 16)
                    .offset(x: w * min(1, max(0, elapsedFraction)) - 1)
            }
        }
        .frame(height: 10)
    }
}

private struct PaceBadge: View {
    let pace: Pace
    var body: some View {
        Text(pace.label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(pace.color.opacity(0.18), in: Capsule())
            .foregroundStyle(pace.color)
    }
}

extension Pace {
    var color: Color {
        switch self {
        case .onTrack: return .green
        case .watch:   return .orange
        case .hot:     return .red
        }
    }
}

/// Left-aligned, full-width menu row with a hover highlight — replaces the
/// centered prototype buttons.
struct FooterButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    @State private var hovering = false

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .contentShape(Rectangle())
                .background(hovering ? Color.secondary.opacity(0.18) : .clear,
                            in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .onHover { hovering = $0 }
    }
}
